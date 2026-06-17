const db = require('../config/db');
const { generarPregunta, generarReporte } = require('../services/geminiService');
const { analizarCV } = require('../services/claudeService');

const TOTAL_PREGUNTAS = 5;

// GET /entrevista/iniciar
exports.getIniciar = (req, res) => {
    const { puesto, nivel } = req.query;
    res.render('entrevista/iniciar', {
        puesto: puesto || '',
        nivel: nivel || 'Junior',
        error: null
    });
};

// POST /entrevista/iniciar
exports.postIniciar = async (req, res) => {
    const { puesto, nivel } = req.body;
    if (!puesto || puesto.trim() === '') {
        return res.redirect('/entrevista/iniciar');
    }

    try {
        // Crear sesión en BD con historial vacío
        const [result] = await db.execute(
            'INSERT INTO sesiones_entrevista (usuario_id, puesto, historial) VALUES (?, ?, ?)',
            [req.session.userId, puesto.trim(), JSON.stringify([])]
        );
        const sesionId = result.insertId;

        // Generar la primera pregunta
        const primeraPregunta = await generarPregunta(puesto, nivel || 'Mid', []);

        // Guardar la primera pregunta pendiente en el historial (respuesta vacía aún)
        // nivel se guarda dentro del historial para usarlo después
        const historial = [{ pregunta: primeraPregunta, respuesta: null, _nivel: nivel || 'Junior', _puesto: puesto.trim() }];
        await db.execute(
            'UPDATE sesiones_entrevista SET historial = ? WHERE id = ?',
            [JSON.stringify(historial), sesionId]
        );

        res.redirect('/entrevista/' + sesionId);
    } catch (err) {
        console.error('Error al iniciar entrevista:', err);
        res.render('entrevista/iniciar', { error: 'Ocurrió un error al iniciar la entrevista. Inténtalo de nuevo.', puesto: '', nivel: 'Junior' });
    }
};

// GET /entrevista/analizar-cv
exports.getAnalizarCV = (req, res) => {
    res.render('entrevista/analizar_cv', { 
        resultado: null, 
        error: null, 
        puesto: '', 
        textoCV: '',
        currentPath: '/entrevista/analizar-cv',
        userName: req.session.userName,
        userId: req.session.userId
    });
};

// POST /entrevista/analizar-cv
exports.postAnalizarCV = async (req, res) => {
    const { puesto, textoCV } = req.body;

    if (!puesto || puesto.trim() === '' || !textoCV || textoCV.trim() === '') {
        return res.render('entrevista/analizar_cv', {
            resultado: null,
            error: 'Por favor completa todos los campos.',
            puesto: puesto || '',
            textoCV: textoCV || '',
            currentPath: '/entrevista/analizar-cv',
            userName: req.session.userName,
            userId: req.session.userId
        });
    }

    try {
        const resultado = await analizarCV(puesto.trim(), textoCV.trim());
        res.render('entrevista/analizar_cv', {
            resultado,
            error: null,
            puesto: puesto.trim(),
            textoCV: textoCV.trim(),
            currentPath: '/entrevista/analizar-cv',
            userName: req.session.userName,
            userId: req.session.userId
        });
    } catch (err) {
        console.error('Error al analizar CV:', err);
        res.render('entrevista/analizar_cv', {
            resultado: null,
            error: err.message || 'Error de conexión con la IA de Claude. Asegúrate de configurar CLAUDE_API_KEY en tu archivo .env.',
            puesto,
            textoCV,
            currentPath: '/entrevista/analizar-cv',
            userName: req.session.userName,
            userId: req.session.userId
        });
    }
};


// GET /entrevista/:id
exports.getSala = async (req, res) => {
    try {
        const [[sesion]] = await db.execute(
            'SELECT * FROM sesiones_entrevista WHERE id = ? AND usuario_id = ?',
            [req.params.id, req.session.userId]
        );

        if (!sesion) return res.redirect('/entrevista/iniciar');
        if (sesion.estado === 'completada') return res.redirect('/entrevista/' + req.params.id + '/reporte');

        const historial = JSON.parse(sesion.historial || '[]');
        const preguntaActual = historial[historial.length - 1];
        const numPreguntaActual = historial.length;
        // Recuperar nivel y puesto desde el primer item del historial
        const nivelSesion = (historial[0] && historial[0]._nivel) || 'Junior';
        sesion.nivel = nivelSesion;

        res.render('entrevista/sala', {
            sesion,
            historial,
            preguntaActual,
            numPreguntaActual,
            totalPreguntas: TOTAL_PREGUNTAS
        });
    } catch (err) {
        console.error('Error en sala de entrevista:', err);
        res.redirect('/entrevista/iniciar');
    }
};

// POST /entrevista/:id/responder (AJAX)
exports.postResponder = async (req, res) => {
    const { respuesta } = req.body;
    const sesionId = req.params.id;

    if (!respuesta || respuesta.trim() === '') {
        return res.json({ success: false, error: 'La respuesta no puede estar vacía.' });
    }

    try {
        const [[sesion]] = await db.execute(
            'SELECT * FROM sesiones_entrevista WHERE id = ? AND usuario_id = ?',
            [sesionId, req.session.userId]
        );

        if (!sesion || sesion.estado === 'completada') {
            return res.json({ success: false, error: 'Sesión no válida.' });
        }

        const historial = JSON.parse(sesion.historial || '[]');
        const nivelSesion = (historial[0] && historial[0]._nivel) || 'Junior';
        const puestoSesion = sesion.puesto;

        // Guardar la respuesta a la última pregunta
        historial[historial.length - 1].respuesta = respuesta.trim();

        const historialCompleto = historial.filter(h => h.respuesta !== null);

        // ¿Es la última pregunta?
        if (historialCompleto.length >= TOTAL_PREGUNTAS) {
            // Generar reporte final
            const reporte = await generarReporte(puestoSesion, nivelSesion, historialCompleto);

            await db.execute(
                'UPDATE sesiones_entrevista SET historial = ?, nota_final = ?, reporte = ?, estado = "completada" WHERE id = ?',
                [JSON.stringify(historial), reporte.nota, JSON.stringify(reporte), sesionId]
            );

            return res.json({ success: true, finalizado: true, redirectUrl: '/entrevista/' + sesionId + '/reporte' });
        }

        // Generar la siguiente pregunta
        const siguientePregunta = await generarPregunta(puestoSesion, nivelSesion, historialCompleto);
        historial.push({ pregunta: siguientePregunta, respuesta: null });

        await db.execute(
            'UPDATE sesiones_entrevista SET historial = ? WHERE id = ?',
            [JSON.stringify(historial), sesionId]
        );

        res.json({
            success: true,
            finalizado: false,
            siguientePregunta,
            numPregunta: historial.length
        });
    } catch (err) {
        console.error('Error al procesar respuesta:', err);
        res.json({ success: false, error: 'Error al procesar tu respuesta. Inténtalo de nuevo.' });
    }
};

// GET /entrevista/:id/reporte
exports.getReporte = async (req, res) => {
    try {
        const [[sesion]] = await db.execute(
            'SELECT * FROM sesiones_entrevista WHERE id = ? AND usuario_id = ?',
            [req.params.id, req.session.userId]
        );

        if (!sesion || sesion.estado !== 'completada') {
            return res.redirect('/entrevista/iniciar');
        }

        const historial = JSON.parse(sesion.historial || '[]');
        const reporte = JSON.parse(sesion.reporte || '{}');
        sesion.nivel = (historial[0] && historial[0]._nivel) || 'Junior';

        res.render('entrevista/reporte', {
            sesion,
            historial: historial.filter(h => h.respuesta !== null),
            reporte,
            nombre: req.session.userName
        });
    } catch (err) {
        console.error('Error al cargar reporte:', err);
        res.redirect('/entrevista/iniciar');
    }
};

// GET /entrevista/:id/pdf
exports.getPDF = async (req, res) => {
    try {
        const [[sesion]] = await db.execute(
            'SELECT * FROM sesiones_entrevista WHERE id = ? AND usuario_id = ?',
            [req.params.id, req.session.userId]
        );

        if (!sesion || sesion.estado !== 'completada') {
            return res.status(404).send('Reporte no encontrado.');
        }

        const historialRaw = JSON.parse(sesion.historial || '[]');
        const nivelPdf = (historialRaw[0] && historialRaw[0]._nivel) || 'Junior';
        sesion.nivel = nivelPdf;
        const historial = historialRaw.filter(h => h.respuesta !== null);
        const reporte = JSON.parse(sesion.reporte || '{}');
        const ganador_nombre = req.session.userName || 'Candidato';
        const fecha = new Date(sesion.fecha).toLocaleDateString('es-PE');

        const PDFDocument = require('pdfkit');
        // Usamos bufferPages: true para poder numerar las páginas al final
        const doc = new PDFDocument({ size: 'A4', margins: { top: 50, bottom: 50, left: 60, right: 60 }, bufferPages: true });

        res.setHeader('Content-disposition', `inline; filename="reporte-entrevista-${sesion.id}.pdf"`);
        res.setHeader('Content-type', 'application/pdf');
        doc.pipe(res);

        // Helper para dibujar barra de progreso
        function dibujarBarraProgreso(doc, x, y, ancho, alto, valor, maximo, color) {
            doc.roundedRect(x, y, ancho, alto, alto / 2).fill('#e2e8f0');
            const porcentaje = Math.min(1, Math.max(0, valor / maximo));
            if (porcentaje > 0) {
                doc.roundedRect(x, y, ancho * porcentaje, alto, alto / 2).fill(color);
            }
        }

        // Helper para inicializar nuevas páginas con encabezado minimalista
        function iniciarNuevaPagina(doc, titulo) {
            doc.addPage();
            doc.rect(0, 0, doc.page.width, 55).fill('#0f172a');
            doc.fontSize(12).fillColor('#ffffff').font('Helvetica-Bold').text(titulo, 60, 20, { align: 'left' });
            doc.fontSize(9).fillColor('#94a3b8').font('Helvetica').text('TechSim Solutions — Evaluación IA', doc.page.width - 260, 22, { align: 'right', width: 200 });
            doc.y = 85;
        }

        // ==========================================
        // ── PÁGINA 1: DATOS & RENDIMIENTO GENERAL ──
        // ==========================================
        
        // Encabezado Principal
        doc.rect(0, 0, doc.page.width, 95).fill('#0f172a');
        doc.fontSize(20).fillColor('#ffffff').font('Helvetica-Bold').text('REPORTE DE ENTREVISTA TÉCNICA', 60, 30, { align: 'center' });
        doc.fontSize(10).fillColor('#94a3b8').font('Helvetica').text('TechSim Solutions — Evaluación IA', 60, 58, { align: 'center' });

        // Info Candidato en dos columnas
        doc.y = 120;
        const col1X = 60;
        const col2X = doc.page.width / 2 + 10;
        const infoY = doc.y;

        doc.fillColor('#64748b').fontSize(9).font('Helvetica').text('CANDIDATO', col1X, infoY);
        doc.fillColor('#0f172a').fontSize(11).font('Helvetica-Bold').text(ganador_nombre, col1X, infoY + 13);

        doc.fillColor('#64748b').fontSize(9).font('Helvetica').text('PUESTO EVALUADO', col1X, infoY + 36);
        doc.fillColor('#0f172a').fontSize(11).font('Helvetica-Bold').text(sesion.puesto, col1X, infoY + 49);

        doc.fillColor('#64748b').fontSize(9).font('Helvetica').text('NIVEL REQUERIDO', col2X, infoY);
        doc.fillColor('#0f172a').fontSize(11).font('Helvetica-Bold').text(nivelPdf, col2X, infoY + 13);

        doc.fillColor('#64748b').fontSize(9).font('Helvetica').text('FECHA Y CÓDIGO', col2X, infoY + 36);
        doc.fillColor('#0f172a').fontSize(11).font('Helvetica-Bold').text(`${fecha} | #${sesion.id}`, col2X, infoY + 49);

        doc.y = infoY + 80;

        // Separador sutil
        doc.moveTo(60, doc.y).lineTo(doc.page.width - 60, doc.y).strokeColor('#e2e8f0').lineWidth(1).stroke();
        doc.y += 15;

        // Card de Nota Final
        const cardHeight = 70;
        const cardWidth = doc.page.width - 120;
        const cardX = 60;
        const cardY = doc.y;

        const notaVal = typeof reporte.nota === 'number' ? reporte.nota : parseFloat(reporte.nota) || 0;
        const notaColor = notaVal >= 14 ? '#10b981' : (notaVal >= 11 ? '#f59e0b' : '#ef4444');
        const notaBg = notaVal >= 14 ? '#ecfdf5' : (notaVal >= 11 ? '#fffbeb' : '#fef2f2');

        doc.roundedRect(cardX, cardY, cardWidth, cardHeight, 6).fill(notaBg);
        doc.rect(cardX, cardY, 6, cardHeight).fill(notaColor);

        doc.fillColor(notaColor);
        doc.fontSize(24).font('Helvetica-Bold').text(`${notaVal} / 20`, cardX + 25, cardY + 12);

        const decisionText = `${reporte.nivel_alcanzado || nivelPdf} — ${reporte.contrataria ? 'RECOMENDADO' : 'NO RECOMENDADO'}`;
        doc.fillColor('#1e293b');
        doc.fontSize(11).font('Helvetica-Bold').text(decisionText, cardX + 25, cardY + 42);

        doc.y = cardY + cardHeight + 20;

        // Resumen General
        doc.fillColor('#0f172a').fontSize(12).font('Helvetica-Bold').text('Resumen General');
        doc.y += 5;
        const resumenText = reporte.resumen || '';
        doc.fillColor('#334155').fontSize(10).font('Helvetica').text(resumenText, { lineGap: 3, width: doc.page.width - 120 });
        doc.y += 18;

        // Evaluación por Área
        doc.fillColor('#0f172a').fontSize(12).font('Helvetica-Bold').text('Evaluación por Área');
        doc.y += 10;

        const areas = reporte.evaluacion_por_area || [];
        areas.forEach(area => {
            const startY = doc.y;

            doc.fillColor('#1e293b').fontSize(10.5).font('Helvetica-Bold').text(area.area, 60, startY);
            doc.fillColor('#64748b').fontSize(9).font('Helvetica').text(`${area.puntaje}/${area.maximo}`, 60, startY + 13);
            doc.fillColor('#475569').fontSize(9).font('Helvetica').text(area.comentario || '', 60, startY + 26, { width: doc.page.width - 320 });

            // Barra de Progreso a la derecha
            const barWidth = 180;
            const barHeight = 8;
            const barX = doc.page.width - 60 - barWidth;
            const barY = startY + 5;

            const porc = area.puntaje / area.maximo;
            const barColor = porc >= 0.7 ? '#10b981' : (porc >= 0.5 ? '#f59e0b' : '#ef4444');

            dibujarBarraProgreso(doc, barX, barY, barWidth, barHeight, area.puntaje, area.maximo, barColor);

            doc.y = Math.max(doc.y, startY + 40) + 10;
        });

        // ==========================================
        // ── PÁGINA 2: DETALLES & RECOMENDACIÓN   ──
        // ==========================================
        iniciarNuevaPagina(doc, 'ANÁLISIS DETALLADO Y RECOMENDACIÓN');

        const colWidth = (doc.page.width - 140) / 2;
        const colStartY = doc.y;

        // Fortalezas (Columna Izquierda)
        doc.fillColor('#10b981').fontSize(12).font('Helvetica-Bold').text('Fortalezas Destacadas', col1X, colStartY);
        doc.y = colStartY + 18;

        (reporte.fortalezas || []).forEach(f => {
            const currentY = doc.y;
            // Dibujar viñeta circular verde
            doc.circle(col1X + 4, currentY + 5, 2.5).fill('#10b981');
            doc.fillColor('#334155').fontSize(9.5).font('Helvetica').text(f, col1X + 14, currentY, { width: colWidth - 14, lineGap: 2 });
            doc.y += 10; // Espaciado extra
        });
        const endCol1Y = doc.y;

        // Áreas de Mejora (Columna Derecha)
        doc.fillColor('#ef4444').fontSize(12).font('Helvetica-Bold').text('Áreas de Mejora', col2X, colStartY);
        doc.y = colStartY + 18;

        (reporte.debilidades || []).forEach(d => {
            const currentY = doc.y;
            // Dibujar viñeta cuadrada roja
            doc.rect(col2X + 1.5, currentY + 3, 5, 5).fill('#ef4444');
            doc.fillColor('#334155').fontSize(9.5).font('Helvetica').text(d, col2X + 14, currentY, { width: colWidth - 14, lineGap: 2 });
            doc.y += 10;
        });
        const endCol2Y = doc.y;

        doc.y = Math.max(endCol1Y, endCol2Y) + 25;

        // Card de Recomendación
        const recX = 60;
        const recY = doc.y;
        const recWidth = doc.page.width - 120;

        doc.fontSize(9.5).font('Helvetica');
        const textHeight = doc.heightOfString(reporte.recomendacion || '', { width: recWidth - 40, lineGap: 2 });
        const recCardHeight = textHeight + 40;

        doc.roundedRect(recX, recY, recWidth, recCardHeight, 6).fill('#f0f4ff');
        doc.rect(recX, recY, 6, recCardHeight).fill('#4f46e5');

        doc.fillColor('#4f46e5').fontSize(11).font('Helvetica-Bold').text('Recomendación del Evaluador', recX + 20, recY + 12);
        doc.fillColor('#312e81').fontSize(9.5).font('Helvetica').text(reporte.recomendacion || '', recX + 20, recY + 28, { width: recWidth - 40, lineGap: 2 });

        doc.y = recY + recCardHeight + 20;

        // ==========================================
        // ── PÁGINA 3: HISTORIAL DE PREGUNTAS      ──
        // ==========================================
        iniciarNuevaPagina(doc, 'HISTORIAL COMPLETO DE LA ENTREVISTA');

        historial.forEach((h, i) => {
            const blockWidth = doc.page.width - 120;

            doc.fontSize(10).font('Helvetica-Bold');
            const qHeight = doc.heightOfString(`Pregunta ${i + 1}: ${h.pregunta}`, { width: blockWidth - 20, lineGap: 2 });

            doc.fontSize(9.5).font('Helvetica');
            const aHeight = doc.heightOfString(`Respuesta: ${h.respuesta}`, { width: blockWidth - 20, lineGap: 2 });

            const blockHeight = qHeight + aHeight + 25;

            // Verificar si el bloque cabe en la página actual
            if (doc.y + blockHeight > doc.page.height - 60) {
                iniciarNuevaPagina(doc, 'HISTORIAL COMPLETO DE LA ENTREVISTA (CONTINUACIÓN)');
            }

            const actualY = doc.y;

            // Caja para la pregunta/respuesta
            doc.roundedRect(60, actualY, blockWidth, blockHeight, 4).fill('#f8fafc');
            doc.roundedRect(60, actualY, blockWidth, blockHeight, 4).lineWidth(1).strokeColor('#e2e8f0').stroke();

            // Pregunta
            doc.fillColor('#4f46e5').fontSize(10).font('Helvetica-Bold').text(`Pregunta ${i + 1}: ${h.pregunta}`, 70, actualY + 10, { width: blockWidth - 20, lineGap: 2 });

            // Respuesta
            doc.fillColor('#334155').fontSize(9.5).font('Helvetica').text(`Respuesta: ${h.respuesta}`, 70, actualY + 15 + qHeight, { width: blockWidth - 20, lineGap: 2 });

            doc.y = actualY + blockHeight + 12;
        });

        // ==========================================
        // ── DIBUJAR FOOTERS EN TODAS LAS PÁGINAS  ──
        // ==========================================
        const range = doc.bufferedPageRange();
        for (let i = range.start; i < range.start + range.count; i++) {
            doc.switchToPage(i);

            // Línea de pie de página
            doc.moveTo(60, doc.page.height - 45).lineTo(doc.page.width - 60, doc.page.height - 45).strokeColor('#e2e8f0').lineWidth(0.5).stroke();

            doc.fontSize(8).fillColor('#94a3b8').font('Helvetica');
            // Texto izquierdo
            doc.text('TechSim Solutions — Reporte de Evaluación de Candidato (Confidencial)', 60, doc.page.height - 35);
            // Texto derecho: Página X de Y
            doc.text(`Página ${i + 1} de ${range.count}`, doc.page.width - 160, doc.page.height - 35, { align: 'right', width: 100 });
        }

        doc.end();
    } catch (err) {
        console.error('Error generando PDF:', err);
        res.status(500).send('Error al generar el PDF.');
    }
};

// GET /entrevista (lista de sesiones anteriores)
exports.getMisSesiones = async (req, res) => {
    try {
        const [sesiones] = await db.execute(
            'SELECT id, puesto, nota_final, estado, fecha FROM sesiones_entrevista WHERE usuario_id = ? ORDER BY fecha DESC LIMIT 10',
            [req.session.userId]
        );
        res.render('entrevista/mis_sesiones', { sesiones });
    } catch (err) {
        console.error(err);
        res.redirect('/dashboard');
    }
};
