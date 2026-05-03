const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const Banco = require('../models/bancoModel');
const PDFDocument = require('pdfkit');

// --- MIDDLEWARE ADMIN ---
const esAdmin = (req, res, next) => {
    console.log('SESSION:', req.session ? req.session.usuario : 'No session');
    if (req.session && req.session.usuario && req.session.usuario.rol === 'admin') {
        return next();
    }
    res.redirect('/dashboard');
};

// --- RUTA PRINCIPAL ---
router.get('/', (req, res) => {
    if (req.session && req.session.userId) {
        if (req.session.usuario && req.session.usuario.rol === 'admin') {
            return res.redirect('/admin');
        }
        res.redirect('/dashboard');
    } else {
        res.redirect('/login');
    }
});

// --- RUTAS DE AUTENTICACIÓN ---
router.get('/login', authController.getLogin);
router.post('/login', authController.postLogin);

router.post('/auth/google', authController.postGoogleLogin);

router.get('/register', authController.getRegister);
router.post('/register', authController.postRegister);

router.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/login');
});

// --- DASHBOARD (Tus propios bancos con promedio de estrellas) ---
router.get('/dashboard', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        // Usamos LEFT JOIN para traer el promedio de estrellas y la cantidad de votos de cada banco
        const [misBancos] = await db.execute(`
            SELECT b.*, AVG(c.estrellas) as promedio, COUNT(c.id) as total_votos 
            FROM bancos b 
            LEFT JOIN calificaciones c ON b.id = c.banco_id 
            WHERE b.autor_id = ? 
            GROUP BY b.id`, 
            [req.session.userId]
        );
        res.render('home', { nombre: req.session.userName, bancos: misBancos });
    } catch (error) {
        console.error(error);
        res.render('home', { nombre: req.session.userName, bancos: [] });
    }
});

// --- RUTAS DE BANCOS ---

// Explorar todos los bancos con su calificación promedio y total de votos
router.get('/bancos', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const [todosLosBancos] = await db.execute(`
            SELECT b.*, AVG(c.estrellas) as promedio, COUNT(c.id) as total_votos 
            FROM bancos b 
            LEFT JOIN calificaciones c ON b.id = c.banco_id 
            GROUP BY b.id`);
        res.render('bancos/lista', { bancos: todosLosBancos });
    } catch (error) {
        res.send("Error al cargar la lista");
    }
});

router.get('/bancos/crear', (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    res.render('bancos/crear');
});

router.post('/bancos/crear', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const { titulo, descripcion, categoria } = req.body;
    try {
        await Banco.create(titulo, descripcion, categoria, req.session.userId);
        res.redirect('/dashboard'); 
    } catch (error) {
        res.send("Error al guardar banco");
    }
});

// --- RUTAS DE EDICIÓN Y ELIMINACIÓN DE BANCOS ---
router.get('/bancos/editar/:id', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const bancoId = req.params.id;
    try {
        const db = require('../config/db');
        const [banco] = await db.execute('SELECT * FROM bancos WHERE id = ? AND autor_id = ?', [bancoId, req.session.userId]);
        if (banco.length > 0) {
            res.render('bancos/editar', { banco: banco[0] });
        } else {
            res.status(403).send("No tienes permiso o el banco no existe.");
        }
    } catch (error) {
        res.send("Error al cargar el banco para editar.");
    }
});

router.post('/bancos/editar/:id', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const bancoId = req.params.id;
    const { titulo, descripcion, categoria } = req.body;
    try {
        const db = require('../config/db');
        await db.execute(
            'UPDATE bancos SET titulo = ?, descripcion = ?, categoria = ? WHERE id = ? AND autor_id = ?',
            [titulo, descripcion, categoria, bancoId, req.session.userId]
        );
        res.redirect('/bancos/ver/' + bancoId);
    } catch (error) {
        res.send("Error al editar el banco.");
    }
});

router.post('/bancos/eliminar/:id', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const bancoId = req.params.id;
    try {
        const db = require('../config/db');
        await db.execute('DELETE FROM bancos WHERE id = ? AND autor_id = ?', [bancoId, req.session.userId]);
        res.redirect('/dashboard');
    } catch (error) {
        res.send("Error al eliminar el banco.");
    }
});

// --- RUTA PARA ELIMINAR PREGUNTAS ---
router.post('/preguntas/eliminar/:id', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const preguntaId = req.params.id;
    const { banco_id } = req.body;
    try {
        const db = require('../config/db');
        const [banco] = await db.execute('SELECT autor_id FROM bancos WHERE id = ?', [banco_id]);
        
        if (banco.length > 0 && banco[0].autor_id === req.session.userId) {
            await db.execute('DELETE FROM preguntas WHERE id = ?', [preguntaId]);
            res.redirect('/bancos/ver/' + banco_id);
        } else {
            res.status(403).send("No tienes permiso para eliminar esta pregunta.");
        }
    } catch (error) {
        res.send("Error al eliminar la pregunta.");
    }
});

router.get('/bancos/ver/:id', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const bancoId = req.params.id;
    try {
        const db = require('../config/db');
        // Traemos el banco con su promedio actual y cantidad total de votos
        const [bancos] = await db.execute(`
            SELECT b.*, AVG(c.estrellas) as promedio, COUNT(c.id) as total_votos 
            FROM bancos b 
            LEFT JOIN calificaciones c ON b.id = c.banco_id 
            WHERE b.id = ? 
            GROUP BY b.id`, [bancoId]);

        const [preguntasDB] = await db.execute('SELECT * FROM preguntas WHERE banco_id = ?', [bancoId]);

        // 4. Mezclador (Randomizer)
        // Mezclamos las preguntas
        let preguntas = preguntasDB.sort(() => Math.random() - 0.5);

        // Para cada pregunta, mezclamos las opciones sin perder la respuesta correcta
        preguntas = preguntas.map(p => {
            let opcionesValidas = [
                { original: 'A', valor: p.opcion_a },
                { original: 'B', valor: p.opcion_b },
                { original: 'C', valor: p.opcion_c },
                { original: 'D', valor: p.opcion_d },
                { original: 'E', valor: p.opcion_e },
                { original: 'F', valor: p.opcion_f }
            ].filter(opt => opt.valor && opt.valor.trim() !== '');

            // Identificar cuál era el valor de la correcta originalmente
            const opcionCorrectaOriginal = opcionesValidas.find(o => o.original === p.respuesta_correcta);

            // Revolvemos las opciones
            opcionesValidas = opcionesValidas.sort(() => Math.random() - 0.5);

            // Re-asignamos letras nuevas A, B, C... a las posiciones ya mezcladas
            const opcionesMezcladas = opcionesValidas.map((opt, i) => {
                const nuevaLetra = String.fromCharCode(65 + i); // 65 es 'A' en ASCII
                // Si esta era la correcta, actualizamos el puntero en la pregunta
                if (opcionCorrectaOriginal && opt.original === opcionCorrectaOriginal.original) {
                    p.respuesta_correcta = nuevaLetra;
                }
                return { letra: nuevaLetra, valor: opt.valor };
            });

            p.opciones_mezcladas = opcionesMezcladas;
            return p;
        });

        // Traemos el Top 5 del Leaderboard
        const [leaderboard] = await db.execute(`
            SELECT i.puntaje, i.total, i.tiempo_segundos, u.nombre, i.fecha
            FROM intentos i
            JOIN usuarios u ON i.usuario_id = u.id
            WHERE i.banco_id = ?
            ORDER BY i.puntaje DESC, i.tiempo_segundos ASC
            LIMIT 5
        `, [bancoId]);

        if (bancos.length > 0) {
            res.render('bancos/ver', { 
                banco: bancos[0], 
                preguntas: preguntas,
                leaderboard: leaderboard,
                user: { id: req.session.userId } 
            });
        } else {
            res.send("El banco no existe.");
        }
    } catch (error) {
        console.error(error);
        res.send("Error al cargar el banco");
    }
});

// --- RUTA PARA GUARDAR INTENTOS (AJAX) ---
router.post('/intentos/guardar', async (req, res) => {
    if (!req.session.userId) return res.status(401).json({ error: "No autorizado" });
    
    const { banco_id, puntaje, total, tiempo_segundos } = req.body;
    
    try {
        const db = require('../config/db');
        await db.execute(
            'INSERT INTO intentos (usuario_id, banco_id, puntaje, total, tiempo_segundos) VALUES (?, ?, ?, ?, ?)',
            [req.session.userId, banco_id, puntaje, total, tiempo_segundos]
        );
        res.json({ success: true });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al guardar el intento" });
    }
});

// --- RUTAS DE PREGUNTAS CON VALIDACIÓN DE AUTOR ---
router.post('/preguntas/crear', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    
    // Capturamos hasta 6 opciones dinámicas
    const { banco_id, enunciado, opcion_a, opcion_b, opcion_c, opcion_d, opcion_e, opcion_f, respuesta_correcta } = req.body;
    const usuario_logueado = req.session.userId;

    try {
        const db = require('../config/db');
        const [banco] = await db.execute('SELECT autor_id FROM bancos WHERE id = ?', [banco_id]);

        if (banco.length > 0 && banco[0].autor_id === usuario_logueado) {
            await db.execute(
                'INSERT INTO preguntas (banco_id, enunciado, opcion_a, opcion_b, opcion_c, opcion_d, opcion_e, opcion_f, respuesta_correcta) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                    banco_id, 
                    enunciado, 
                    opcion_a || null, 
                    opcion_b || null, 
                    opcion_c || null, 
                    opcion_d || null, 
                    opcion_e || null, 
                    opcion_f || null, 
                    respuesta_correcta
                ]
            );
            res.redirect('/bancos/ver/' + banco_id);
        } else {
            res.status(403).send("No tienes permiso para editar este banco.");
        }
    } catch (error) {
        console.error(error);
        res.send("Error al guardar la pregunta");
    }
});

// --- RUTA DE CALIFICACIÓN ---
router.post('/bancos/calificar', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const { banco_id, estrellas } = req.body;
    const usuario_id = req.session.userId;
    try {
        const db = require('../config/db');
        await db.execute(
            'INSERT INTO calificaciones (usuario_id, banco_id, estrellas) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE estrellas = ?',
            [usuario_id, banco_id, estrellas, estrellas]
        );
        res.redirect('/bancos/ver/' + banco_id);
    } catch (error) {
        res.send("Error al calificar");
    }
});

// --- RUTAS DE RETOS DE CÓDIGO ---
router.get('/retos', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const [retos] = await db.execute(`
            SELECT r.*, 
            (SELECT COUNT(*) FROM intentos_retos ir WHERE ir.reto_id = r.id AND ir.usuario_id = ? AND ir.resultado = 'Exitoso') as resuelto,
            AVG(cr.estrellas) as promedio_estrellas,
            COUNT(cr.id) as total_votos
            FROM retos r
            LEFT JOIN calificaciones_retos cr ON r.id = cr.reto_id
            GROUP BY r.id
        `, [req.session.userId]);
        
        res.render('retos/lista', { retos });
    } catch (error) {
        console.error(error);
        res.send("Error al cargar la lista de retos");
    }
});

// --- RUTA PARA CREAR NUEVO RETO ---
router.get('/retos/crear', (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    res.render('retos/crear');
});

router.post('/retos/crear', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const { titulo, enunciado, codigo_inicial, dificultad, lenguaje, pista, casos_input, casos_output, casos_visible } = req.body;
    
    try {
        const db = require('../config/db');
        
        // Limpiar "Input:" / "Output:" y extraer test_input y test_output del primer caso
        let inputs = Array.isArray(casos_input) ? casos_input : [casos_input];
        let outputs = Array.isArray(casos_output) ? casos_output : [casos_output];
        let visibles = Array.isArray(casos_visible) ? casos_visible : [casos_visible];

        // Quitar cualquier prefijo manual que el usuario haya escrito ("Input:", "Output:")
        inputs = inputs.map(i => i ? i.replace(/^input\s*(ej)?:?\s*/i, '').replace(/^ej:\s*/i, '').trim() : '');
        outputs = outputs.map(o => o ? o.replace(/^output\s*(ej)?:?\s*/i, '').replace(/^ej:\s*/i, '').trim() : '');

        let test_input = inputs.length > 0 && inputs[0] !== '' ? inputs[0] : null;
        let test_output = outputs.length > 0 && outputs[0] !== '' ? outputs[0] : null;

        const [result] = await db.execute(
            'INSERT INTO retos (titulo, enunciado, codigo_inicial, test_input, test_output, dificultad, lenguaje, pista, autor_id, puntos) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [titulo, enunciado, codigo_inicial || '', test_input, test_output, dificultad, lenguaje || 'JavaScript', pista || null, req.session.userId, 10]
        );
        
        const retoId = result.insertId;

        // Validar e insertar los casos de prueba
        for (let i = 0; i < inputs.length; i++) {
            if (inputs[i] && outputs[i]) {
                const es_visible = visibles[i] == '1' || visibles[i] == 'on' ? 1 : 0;
                await db.execute(
                    'INSERT INTO casos_prueba (reto_id, input, output_esperado, es_visible) VALUES (?, ?, ?, ?)',
                    [retoId, inputs[i], outputs[i], es_visible]
                );
            }
        }
        res.redirect('/retos');
    } catch (error) {
        console.error("Error al guardar el reto", error);
        res.send("Error al guardar el reto");
    }
});

// --- RUTA PARA CALIFICAR O EVALUAR RETOS ---
router.post('/retos/calificar', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const { reto_id, estrellas } = req.body;
    try {
        const db = require('../config/db');
        await db.execute(
            'INSERT INTO calificaciones_retos (usuario_id, reto_id, estrellas) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE estrellas = ?',
            [req.session.userId, reto_id, estrellas, estrellas]
        );
        res.redirect('/retos/resolver/' + reto_id);
    } catch (error) {
        console.error(error);
        res.send("Error al calificar el reto");
    }
});

router.get('/retos/resolver/:id', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    const retoId = req.params.id;
    try {
        const db = require('../config/db');
        const [retos] = await db.execute('SELECT * FROM retos WHERE id = ?', [retoId]);
        
        if (retos.length > 0) {
            // Ranking de este reto
            const [leaderboard] = await db.execute(`
                SELECT u.nombre, ir.fecha
                FROM intentos_retos ir
                JOIN usuarios u ON ir.usuario_id = u.id
                WHERE ir.reto_id = ? AND ir.resultado = 'Exitoso'
                ORDER BY ir.fecha ASC
                LIMIT 5
            `, [retoId]);

            // Casos de prueba
            let casosPrueba = [];
            try {
                const [rows] = await db.execute('SELECT * FROM casos_prueba WHERE reto_id = ?', [retoId]);
                casosPrueba = rows;
            } catch (err) {
                console.log("Aviso: tabla casos_prueba no encontrada o error:", err.message);
            }
            
            // Total de intentos del usuario
            let contadorIntentos = 0;
            const [intentos] = await db.execute('SELECT COUNT(*) as total FROM intentos_retos WHERE reto_id = ? AND usuario_id = ?', [retoId, req.session.userId]);
            if (intentos && intentos.length > 0) {
                contadorIntentos = intentos[0].total || 0;
            }

            res.render('retos/resolver', { 
                reto: retos[0],
                casosPrueba: casosPrueba || [],
                intentosTotales: contadorIntentos,
                leaderboard: leaderboard 
            });
        } else {
            res.send("El reto no existe o fue eliminado.");
        }
    } catch (error) {
        console.error(error);
        res.send("Error al cargar el reto.");
    }
});

router.post('/retos/enviar', async (req, res) => {
    if (!req.session.userId) return res.status(401).json({ error: "No autorizado" });
    
    const { reto_id, codigo, resultado } = req.body;
    
    try {
        const db = require('../config/db');
        
        // Registrar intento en DB
        await db.execute(
            'INSERT INTO intentos_retos (usuario_id, reto_id, codigo_enviado, resultado) VALUES (?, ?, ?, ?)',
            [req.session.userId, reto_id, codigo, resultado]
        );
        
        res.json({ success: true, message: "Resultado guardado correctamente" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al guardar tu solución" });
    }
});
// --- RUTAS DE ADMINISTRADOR ---
router.get('/admin', esAdmin, async (req, res) => {
    try {
        const db = require('../config/db');
        const [[{total: usuarios}]] = await db.execute('SELECT COUNT(*) as total FROM usuarios');
        const [[{total: retos}]] = await db.execute('SELECT COUNT(*) as total FROM retos');
        const [[{total: bancos}]] = await db.execute('SELECT COUNT(*) as total FROM bancos');
        const [[{total: intentos}]] = await db.execute("SELECT COUNT(*) as total FROM intentos_retos WHERE resultado='Exitoso'");
        
        const [topUsuarios] = await db.execute(`
            SELECT u.nombre, COUNT(ir.id) as total 
            FROM intentos_retos ir 
            JOIN usuarios u ON ir.usuario_id = u.id 
            GROUP BY u.id ORDER BY total DESC LIMIT 5
        `);
        
        const [topRetos] = await db.execute(`
            SELECT r.titulo, COUNT(ir.id) as total 
            FROM intentos_retos ir 
            JOIN retos r ON ir.reto_id = r.id 
            GROUP BY r.id ORDER BY total DESC LIMIT 5
        `);

        res.render('admin/dashboard', {
            layout: false,
            stats: { usuarios, retos, bancos, intentos },
            topUsuarios,
            topRetos
        });
    } catch (error) {
        console.error(error);
        res.status(500).send('Error cargando el dashboard admin');
    }
});

router.get('/admin/usuarios', esAdmin, async (req, res) => {
    try {
        const db = require('../config/db');
        const [usuarios] = await db.execute('SELECT * FROM usuarios');
        res.render('admin/usuarios', { layout: false, usuarios });
    } catch (e) {
        res.status(500).send('Error get usuarios');
    }
});

router.post('/admin/usuarios/:id/toggle', esAdmin, async (req, res) => {
    // Falta campo 'activo' en DB segun prompt, saltamos logica estricta
    res.redirect('/admin/usuarios');
});

router.post('/admin/usuarios/:id/rol', esAdmin, async (req, res) => {
    try {
        const db = require('../config/db');
        const [userDb] = await db.execute('SELECT rol FROM usuarios WHERE id = ?', [req.params.id]);
        if (userDb.length > 0) {
            const nuevoRol = userDb[0].rol === 'admin' ? 'user' : 'admin';
            await db.execute('UPDATE usuarios SET rol = ? WHERE id = ?', [nuevoRol, req.params.id]);
        }
        res.redirect('/admin/usuarios');
    } catch (e) {
        res.status(500).send('Error');
    }
});

router.get('/admin/retos', esAdmin, async (req, res) => {
    try {
        const db = require('../config/db');
        const [retos] = await db.execute('SELECT * FROM retos');
        res.render('admin/retos', { layout: false, retos });
    } catch (e) {
        res.status(500).send('Error get retos');
    }
});

router.post('/admin/retos/:id/delete', esAdmin, async (req, res) => {
    try {
        const db = require('../config/db');
        await db.execute('DELETE FROM retos WHERE id = ?', [req.params.id]);
        res.redirect('/admin/retos');
    } catch (e) {
        res.status(500).send('Error delete r');
    }
});

router.get('/admin/bancos', esAdmin, async (req, res) => {
    try {
        const db = require('../config/db');
        const [bancos] = await db.execute('SELECT * FROM bancos');
        res.render('admin/bancos', { layout: false, bancos });
    } catch (e) {
        res.status(500).send('Error get bancos');
    }
});

router.post('/admin/bancos/:id/delete', esAdmin, async (req, res) => {
    try {
        const db = require('../config/db');
        await db.execute('DELETE FROM bancos WHERE id = ?', [req.params.id]);
        res.redirect('/admin/bancos');
    } catch (e) {
        res.status(500).send('Error delete b');
    }
});

router.get('/admin/reporte/pdf', esAdmin, async (req, res) => {
    try {
        const db = require('../config/db');
        const [[{total: usuarios}]] = await db.execute('SELECT COUNT(*) as total FROM usuarios');
        const [[{total: retos}]] = await db.execute('SELECT COUNT(*) as total FROM retos');
        const [[{total: bancos}]] = await db.execute('SELECT COUNT(*) as total FROM bancos');
        const [[{total: intentos}]] = await db.execute("SELECT COUNT(*) as total FROM intentos_retos WHERE resultado='Exitoso'");
        
        const [topUsuarios] = await db.execute('SELECT u.nombre, COUNT(ir.id) as total FROM intentos_retos ir JOIN usuarios u ON ir.usuario_id = u.id GROUP BY u.id ORDER BY total DESC LIMIT 5');
        const [topRetos] = await db.execute('SELECT r.titulo, COUNT(ir.id) as total FROM intentos_retos ir JOIN retos r ON ir.reto_id = r.id GROUP BY r.id ORDER BY total DESC LIMIT 5');

        const doc = new PDFDocument({ margin: 50, size: 'A4' });
        res.setHeader('Content-disposition', 'attachment; filename="reporte-sistema.pdf"');
        res.setHeader('Content-type', 'application/pdf');
        doc.pipe(res);

        // --- ENCABEZADO (BANNER) ---
        doc.rect(0, 0, 600, 100).fill('#0f172a');
        doc.fillColor('#ffffff')
           .font('Helvetica-Bold')
           .fontSize(28)
           .text('Simulador de Entrevistas', 0, 25, { align: 'center' });
        doc.fontSize(12)
           .fillColor('#94a3b8')
           .text('Reporte Administrativo del Sistema', 0, 60, { align: 'center' });
           
        // --- FECHA ---
        doc.fillColor('#333333')
           .font('Helvetica')
           .fontSize(10)
           .text('Fecha de generación: ' + new Date().toLocaleDateString() + ' ' + new Date().toLocaleTimeString(), 50, 120, { align: 'right' });
        doc.moveDown(2);

        // --- ESTADÍSTICAS GENERALES ---
        doc.font('Helvetica-Bold').fontSize(16).fillColor('#2563eb').text('Estadísticas Generales');
        doc.moveTo(50, doc.y + 5).lineTo(545, doc.y + 5).lineWidth(1).strokeColor('#e2e8f0').stroke();
        doc.moveDown(1.5);
        
        doc.font('Helvetica').fontSize(12).fillColor('#334155');
        const startY = doc.y;
        
        // Bloque 1
        doc.rect(50, startY, 230, 45).fillAndStroke('#f8fafc', '#e2e8f0');
        doc.fillColor('#475569').font('Helvetica-Bold').text('Total Usuarios:', 65, startY + 16);
        doc.fillColor('#10b981').text(usuarios.toString(), 200, startY + 16, { width: 65, align: 'right' });

        // Bloque 2
        doc.rect(315, startY, 230, 45).fillAndStroke('#f8fafc', '#e2e8f0');
        doc.fillColor('#475569').text('Total Retos:', 330, startY + 16);
        doc.fillColor('#10b981').text(retos.toString(), 465, startY + 16, { width: 65, align: 'right' });
        
        // Bloque 3
        doc.rect(50, startY + 60, 230, 45).fillAndStroke('#f8fafc', '#e2e8f0');
        doc.fillColor('#475569').text('Total Bancos:', 65, startY + 76);
        doc.fillColor('#10b981').text(bancos.toString(), 200, startY + 76, { width: 65, align: 'right' });

        // Bloque 4
        doc.rect(315, startY + 60, 230, 45).fillAndStroke('#f8fafc', '#e2e8f0');
        doc.fillColor('#475569').text('Intentos Exitosos:', 330, startY + 76);
        doc.fillColor('#10b981').text(intentos.toString(), 465, startY + 76, { width: 65, align: 'right' });

        doc.y = startY + 140;

        // --- TOP USUARIOS ---
        doc.font('Helvetica-Bold').fontSize(16).fillColor('#2563eb').text('Top 5 Usuarios Más Activos');
        doc.moveTo(50, doc.y + 5).lineTo(545, doc.y + 5).strokeColor('#e2e8f0').stroke();
        doc.moveDown(1.5);
        
        let yPos = doc.y;
        doc.font('Helvetica-Bold').fontSize(10).fillColor('#64748b');
        doc.text('PUESTO', 55, yPos);
        doc.text('NOMBRE DEL USUARIO', 130, yPos);
        doc.text('INTENTOS', 450, yPos, { width: 85, align: 'right' });
        yPos += 20;

        doc.font('Helvetica').fontSize(12);
        topUsuarios.forEach((u, i) => {
            if(i % 2 === 0) doc.rect(50, yPos - 5, 495, 28).fill('#f1f5f9');
            doc.fillColor('#1e293b');
            doc.text('#' + (i+1), 55, yPos);
            doc.text(u.nombre, 130, yPos);
            doc.fillColor('#10b981').font('Helvetica-Bold').text(u.total.toString(), 450, yPos, { width: 85, align: 'right' });
            doc.font('Helvetica');
            yPos += 28;
        });
        
        doc.y = yPos + 35;

        // --- TOP RETOS ---
        doc.font('Helvetica-Bold').fontSize(16).fillColor('#2563eb').text('Top 5 Retos Más Intentados');
        doc.moveTo(50, doc.y + 5).lineTo(545, doc.y + 5).strokeColor('#e2e8f0').stroke();
        doc.moveDown(1.5);
        
        yPos = doc.y;
        doc.font('Helvetica-Bold').fontSize(10).fillColor('#64748b');
        doc.text('RANKING', 55, yPos);
        doc.text('TÍTULO DEL RETO', 130, yPos);
        doc.text('INTENTOS', 450, yPos, { width: 85, align: 'right' });
        yPos += 20;

        doc.font('Helvetica').fontSize(12);
        topRetos.forEach((r, i) => {
            if(i % 2 === 0) doc.rect(50, yPos - 5, 495, 28).fill('#f1f5f9');
            doc.fillColor('#1e293b');
            doc.text('#' + (i+1), 55, yPos);
            doc.text(r.titulo, 130, yPos);
            doc.fillColor('#f59e0b').font('Helvetica-Bold').text(r.total.toString(), 450, yPos, { width: 85, align: 'right' });
            doc.font('Helvetica');
            yPos += 28;
        });

        // --- FOOTER ---
        doc.moveDown(2);
        doc.fillColor('#94a3b8').fontSize(10).text('Simulador de Entrevistas - Reporte Generado Automáticamente', { align: 'center' });

        doc.end();
    } catch (error) {
        console.error(error);
        res.status(500).send('Error generando PDF');
    }
});

// ==========================================
// 1V1 BATALLAS, AMIGOS Y CERTIFICADOS
// ==========================================

// --- AMIGOS ---
router.get('/usuarios', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const [usuarios] = await db.execute(`
            SELECT u.id, u.nombre,
                   (SELECT estado FROM amigos WHERE (usuario_id = ? AND amigo_id = u.id) OR (usuario_id = u.id AND amigo_id = ?) LIMIT 1) as estadoAmistad
            FROM usuarios u
            WHERE u.id != ? AND u.rol != 'admin'
        `, [req.session.userId, req.session.userId, req.session.userId]);
        res.render('amigos/usuarios', { usuarios });
    } catch (e) {
        console.error(e);
        res.status(500).send('Error');
    }
});

router.post('/amigos/agregar', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        await db.execute('INSERT INTO amigos (usuario_id, amigo_id, estado) VALUES (?, ?, "pendiente")', [req.session.userId, req.body.amigo_id]);
        res.redirect('/usuarios');
    } catch (e) {
        console.error(e);
        res.redirect('/usuarios');
    }
});

router.get('/amigos', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const [solicitudes] = await db.execute(`
            SELECT a.id as relacion_id, u.nombre, u.id as usuario_id 
            FROM amigos a JOIN usuarios u ON a.usuario_id = u.id 
            WHERE a.amigo_id = ? AND a.estado = 'pendiente'
        `, [req.session.userId]);
        
        const [amigos] = await db.execute(`
            SELECT u.id, u.nombre 
            FROM amigos a JOIN usuarios u ON (a.usuario_id = u.id OR a.amigo_id = u.id)
            WHERE (a.usuario_id = ? OR a.amigo_id = ?) AND a.estado = 'aceptado' AND u.id != ?
        `, [req.session.userId, req.session.userId, req.session.userId]);
        const [retos] = await db.execute('SELECT id, titulo, dificultad FROM retos');
        res.render('amigos/lista', { solicitudes, amigos, retos });
    } catch (e) {
        console.error(e);
        res.status(500).send('Error');
    }
});

router.post('/amigos/aceptar/:id', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        await db.execute('UPDATE amigos SET estado="aceptado" WHERE id=? AND amigo_id=?', [req.params.id, req.session.userId]);
        res.redirect('/amigos');
    } catch(e) {
        res.redirect('/amigos');
    }
});

router.post('/amigos/rechazar/:id', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        await db.execute('DELETE FROM amigos WHERE id=? AND amigo_id=?', [req.params.id, req.session.userId]);
        res.redirect('/amigos');
    } catch(e) {
        res.redirect('/amigos');
    }
});

// --- BATALLAS (SALAS DE RETO) ---
router.get('/batalla', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const [salas] = await db.execute(`
            SELECT s.codigo, r.titulo as reto_titulo, u.nombre as creador_nombre, r.dificultad
            FROM salas_reto s
            JOIN retos r ON s.reto_id = r.id
            JOIN usuarios u ON s.creador_id = u.id
            WHERE s.estado = 'esperando'
        `);
        const [retos] = await db.execute('SELECT id, titulo, dificultad FROM retos');
        res.render('batalla/lobby', { salas, retos });
    } catch (e) {
        console.error(e);
        res.status(500).send('Error');
    }
});

router.post('/batalla/crear', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const codigo = Math.random().toString(36).substring(2,8).toUpperCase();
        await db.execute('INSERT INTO salas_reto (codigo, reto_id, creador_id) VALUES (?, ?, ?)', [codigo, req.body.reto_id, req.session.userId]);
        res.redirect('/batalla/' + codigo);
    } catch (e) {
        console.error(e);
        res.redirect('/batalla');
    }
});

router.post('/batalla/crear-privada', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const codigo = Math.random().toString(36).substring(2,8).toUpperCase();
        await db.execute('INSERT INTO salas_reto (codigo, reto_id, creador_id) VALUES (?, ?, ?)', [codigo, req.body.reto_id, req.session.userId]);
        res.redirect('/batalla/' + codigo + '?invitado=' + req.body.amigo_id);
    } catch (e) {
        console.error(e);
        res.redirect('/batalla');
    }
});

router.post('/batalla/cancelar', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        await db.execute('DELETE FROM salas_reto WHERE codigo = ? AND creador_id = ? AND estado = "esperando"', [req.body.codigo, req.session.userId]);
        res.redirect('/batalla');
    } catch (e) {
        console.error(e);
        res.redirect('/batalla');
    }
});

router.get('/batalla/:codigo', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const codigo = req.params.codigo;
        const [[sala]] = await db.execute(`
            SELECT s.*, u.nombre as creador_nombre 
            FROM salas_reto s JOIN usuarios u ON s.creador_id = u.id 
            WHERE s.codigo = ? AND s.estado != 'finalizado'
        `, [codigo]);
        
        if (!sala) return res.send('Sala no encontrada o ya finalizada.');
        
        const [[reto]] = await db.execute('SELECT * FROM retos WHERE id = ?', [sala.reto_id]);
        const [casosPrueba] = await db.execute('SELECT * FROM casos_prueba WHERE reto_id = ?', [sala.reto_id]);
        
        res.render('batalla/sala', { sala, reto, casosPrueba, invitado: req.query.invitado || null });
    } catch (e) {
        console.error(e);
        res.status(500).send('Error');
    }
});

// --- CERTIFICADOS ---
router.get('/certificados', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const [certificados] = await db.execute('SELECT * FROM certificados WHERE usuario_id = ? ORDER BY fecha DESC', [req.session.userId]);
        res.render('certificados/lista', { certificados, userId: req.session.userId });
    } catch (e) {
        console.error(e);
        res.status(500).send('Error');
    }
});

// Función auxiliar para generar el PDF (sin el logo, como se solicitó)
async function generarPDF(cert, ganador_nombre, res) {
    const PDFDocument = require('pdfkit');
    const doc = new PDFDocument({ layout: 'landscape', size: 'A4', margins: { top: 0, bottom: 0, left: 0, right: 0 } });
    
    res.setHeader('Content-disposition', 'inline; filename="certificado-'+cert.sala_codigo+'.pdf"');
    res.setHeader('Content-type', 'application/pdf');
    doc.pipe(res);

    // Fondo blanco
    doc.rect(0, 0, doc.page.width, doc.page.height).fill('#ffffff');
    
    // Borde exterior e interior (claros)
    doc.rect(20, 20, doc.page.width - 40, doc.page.height - 40).lineWidth(3).strokeColor('#cbd5e1').stroke();
    doc.rect(26, 26, doc.page.width - 52, doc.page.height - 52).lineWidth(1).strokeColor('#6366f1').stroke();

    // Marca de agua central (Logo sin fondo difuminado)
    const watermarkPath = require('path').join(__dirname, '../../public/img/logo_sin_fondo.png');
    if (require('fs').existsSync(watermarkPath)) {
        doc.save();
        doc.opacity(0.12);
        doc.image(watermarkPath, (doc.page.width - 500) / 2, (doc.page.height - 500) / 2, { fit: [500, 500], align: 'center', valign: 'center' });
        doc.restore();
    }

    // Título principal centrado (ajustado Y=100 al no haber logo)
    doc.y = 100;
    doc.fontSize(32).fillColor('#0f172a').text('CERTIFICADO DE EXCELENCIA TÉCNICA', { align: 'center', characterSpacing: 2 });
    
    doc.moveDown(1);
    doc.fontSize(13).fillColor('#64748b').text('El comité de evaluación de TechSim Solutions, respaldado por especialistas del sector,', { align: 'center' });
    doc.fontSize(13).fillColor('#64748b').text('otorga la presente validación de competencias técnicas a:', { align: 'center' });
    
    doc.moveDown(1.5);
    doc.fontSize(34).fillColor('#16a34a').text(ganador_nombre.toUpperCase(), { align: 'center' });
    
    // Línea divisoria
    doc.moveTo(doc.page.width / 2 - 220, doc.y + 20)
       .lineTo(doc.page.width / 2 + 220, doc.y + 20)
       .lineWidth(1.5).strokeColor('#94a3b8').stroke();

    doc.moveDown(2.5);
    doc.fontSize(14).fillColor('#475569').text('Por haber acreditado habilidades excepcionales de ingeniería y lógica, superando la evaluación técnica contra:', { align: 'center' });
    doc.moveDown(0.5);
    doc.fontSize(22).fillColor('#dc2626').text(cert.oponente_nombre, { align: 'center' });
    doc.moveDown(0.5);
    doc.fontSize(14).fillColor('#475569').text('en el escenario de prueba oficial:', { align: 'center' });
    
    doc.moveDown(1);
    doc.fontSize(26).fillColor('#4f46e5').text(cert.reto_titulo, { align: 'center' });
    
    // Zona de firmas y sellos
    const startY = doc.page.height - 110;
    
    // Firma izquierda
    const firma1Path = require('path').join(__dirname, '../../public/img/firma1.png');
    if (require('fs').existsSync(firma1Path)) {
        doc.image(firma1Path, 80, startY - 45, { fit: [200, 60], align: 'center', valign: 'bottom' });
    }
    doc.moveTo(80, startY + 15).lineTo(280, startY + 15).lineWidth(1).strokeColor('#94a3b8').stroke();
    doc.fontSize(10).fillColor('#64748b').text('DIRECTOR DE EVALUACIÓN TÉCNICA', 80, startY + 25, { width: 200, align: 'center' });
    doc.fillColor('#334155').text('TechSim Solutions', 80, startY + 40, { width: 200, align: 'center' });
    
    // Firma derecha
    const firma2Path = require('path').join(__dirname, '../../public/img/firma2.png');
    if (require('fs').existsSync(firma2Path)) {
        doc.image(firma2Path, doc.page.width - 280, startY - 45, { fit: [200, 60], align: 'center', valign: 'bottom' });
    }
    doc.moveTo(doc.page.width - 280, startY + 15).lineTo(doc.page.width - 80, startY + 15).lineWidth(1).strokeColor('#94a3b8').stroke();
    doc.fontSize(10).fillColor('#64748b').text('VALIDACIÓN DEL SISTEMA', doc.page.width - 280, startY + 25, { width: 200, align: 'center' });
    doc.fillColor('#334155').text(`Código: ${cert.sala_codigo} | Fecha: ${new Date(cert.fecha).toLocaleDateString()}`, doc.page.width - 280, startY + 40, { width: 200, align: 'center' });

    // Sello central "VERIFIED"
    doc.save();
    doc.translate(doc.page.width / 2, startY + 20);
    doc.rotate(-15);
    doc.fontSize(28).fillOpacity(0.1).fillColor('#16a34a').text('VERIFIED', -70, -15);
    doc.restore();

    doc.end();
}

// Ruta pública de UN SOLO certificado (Renderiza el PDF directo en el navegador)
router.get('/c/:id', async (req, res) => {
    try {
        const db = require('../config/db');
        const [[cert]] = await db.execute('SELECT c.*, u.nombre as ganador_nombre FROM certificados c JOIN usuarios u ON c.usuario_id = u.id WHERE c.id = ?', [req.params.id]);
        if (!cert) return res.status(404).send('Certificado no encontrado');
        
        await generarPDF(cert, cert.ganador_nombre, res);
    } catch (e) {
        console.error(e);
        res.status(500).send('Error al generar el certificado público');
    }
});

// Ruta privada original (descargar PDF desde la cuenta)
router.get('/certificados/:id/pdf', async (req, res) => {
    if (!req.session.userId) return res.redirect('/login');
    try {
        const db = require('../config/db');
        const [[cert]] = await db.execute('SELECT * FROM certificados WHERE id = ? AND usuario_id = ?', [req.params.id, req.session.userId]);
        if (!cert) return res.status(404).send('Certificado no encontrado');

        const [[user]] = await db.execute('SELECT nombre FROM usuarios WHERE id = ?', [req.session.userId]);

        await generarPDF(cert, user.nombre, res);
    } catch (e) {
        console.error(e);
        res.status(500).send('Error generando PDF de certificado');
    }
});

module.exports = router;