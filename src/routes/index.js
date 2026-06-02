const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { isAuthenticated, isAdmin } = require('../middlewares/authMiddleware');
const db = require('../config/db');

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

// --- DASHBOARD ---
router.get('/dashboard', isAuthenticated, async (req, res) => {
    try {
        // 1. Mis Bancos
        const [misBancos] = await db.execute(`
            SELECT b.*, AVG(c.estrellas) as promedio, COUNT(c.id) as total_votos 
            FROM bancos b 
            LEFT JOIN calificaciones c ON b.id = c.banco_id 
            WHERE b.autor_id = ? 
            GROUP BY b.id`, 
            [req.session.userId]
        );

        // 2. Radar de Habilidades (Retos resueltos exitosamente agrupados por lenguaje)
        const labelsRadar = ['JavaScript', 'Python', 'Java', 'C++', 'C#', 'SQL'];
        const [dbRadarResult] = await db.execute(`
            SELECT r.lenguaje, COUNT(DISTINCT ir.reto_id) as total
            FROM intentos_retos ir
            JOIN retos r ON ir.reto_id = r.id
            WHERE ir.usuario_id = ? AND ir.resultado = 'Exitoso'
            GROUP BY r.lenguaje`,
            [req.session.userId]
        );
        const radarData = labelsRadar.map(lang => {
            const found = dbRadarResult.find(item => item.lenguaje.toLowerCase() === lang.toLowerCase());
            return found ? found.total : 0;
        });

        // 3. Actividad (Retos resueltos exitosamente en los últimos 7 días)
        const last7Days = [];
        for (let i = 6; i >= 0; i--) {
            const d = new Date();
            d.setDate(d.getDate() - i);
            last7Days.push(d);
        }
        
        const dayNames = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
        const activityLabels = last7Days.map(d => dayNames[d.getDay()]);
        
        const [dbActivityResult] = await db.execute(`
            SELECT DATE(fecha) as fecha_dia, COUNT(*) as total
            FROM intentos_retos
            WHERE usuario_id = ? AND resultado = 'Exitoso' AND fecha >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
            GROUP BY DATE(fecha)`,
            [req.session.userId]
        );

        const activityData = last7Days.map(d => {
            const localDateString = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
            const found = dbActivityResult.find(item => {
                const itemDate = new Date(item.fecha_dia);
                const itemDateString = `${itemDate.getFullYear()}-${String(itemDate.getMonth()+1).padStart(2,'0')}-${String(itemDate.getDate()).padStart(2,'0')}`;
                return itemDateString === localDateString;
            });
            return found ? found.total : 0;
        });

        res.render('home', { 
            nombre: req.session.userName, 
            bancos: misBancos, 
            radarData, 
            activityLabels, 
            activityData 
        });
    } catch (error) {
        console.error(error);
        res.render('home', { 
            nombre: req.session.userName, 
            bancos: [], 
            radarData: [0, 0, 0, 0, 0, 0], 
            activityLabels: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'], 
            activityData: [0, 0, 0, 0, 0, 0, 0] 
        });
    }
});

// --- RUTA PARA GUARDAR INTENTOS (AJAX) ---
router.post('/intentos/guardar', isAuthenticated, async (req, res) => {
    const { banco_id, puntaje, total, tiempo_segundos } = req.body;
    try {
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

// --- IMPORTAR RUTAS MODULARIZADAS ---
router.use('/bancos', require('./bancosRoutes'));
router.use('/retos', require('./retosRoutes'));
router.use('/preguntas', require('./preguntasRoutes'));
router.use('/admin', require('./adminRoutes'));

// ==========================================
// 1V1 BATALLAS, AMIGOS Y CERTIFICADOS (Sin Modularizar por ahora)
// ==========================================

router.get('/usuarios', isAuthenticated, async (req, res) => {
    try {
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

router.post('/amigos/agregar', isAuthenticated, async (req, res) => {
    try {
        await db.execute('INSERT INTO amigos (usuario_id, amigo_id, estado) VALUES (?, ?, "pendiente")', [req.session.userId, req.body.amigo_id]);
        res.redirect('/usuarios');
    } catch (e) {
        console.error(e);
        res.redirect('/usuarios');
    }
});

router.get('/amigos', isAuthenticated, async (req, res) => {
    try {
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

router.post('/amigos/aceptar/:id', isAuthenticated, async (req, res) => {
    try {
        await db.execute('UPDATE amigos SET estado="aceptado" WHERE id=? AND amigo_id=?', [req.params.id, req.session.userId]);
        res.redirect('/amigos');
    } catch(e) {
        res.redirect('/amigos');
    }
});

router.post('/amigos/rechazar/:id', isAuthenticated, async (req, res) => {
    try {
        await db.execute('DELETE FROM amigos WHERE id=? AND amigo_id=?', [req.params.id, req.session.userId]);
        res.redirect('/amigos');
    } catch(e) {
        res.redirect('/amigos');
    }
});

router.get('/batalla', isAuthenticated, async (req, res) => {
    try {
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

router.post('/batalla/crear', isAuthenticated, async (req, res) => {
    try {
        const codigo = Math.random().toString(36).substring(2,8).toUpperCase();
        await db.execute('INSERT INTO salas_reto (codigo, reto_id, creador_id) VALUES (?, ?, ?)', [codigo, req.body.reto_id, req.session.userId]);
        res.redirect('/batalla/' + codigo);
    } catch (e) {
        console.error(e);
        res.redirect('/batalla');
    }
});

router.post('/batalla/crear-privada', isAuthenticated, async (req, res) => {
    try {
        const codigo = Math.random().toString(36).substring(2,8).toUpperCase();
        await db.execute('INSERT INTO salas_reto (codigo, reto_id, creador_id) VALUES (?, ?, ?)', [codigo, req.body.reto_id, req.session.userId]);
        res.redirect('/batalla/' + codigo + '?invitado=' + req.body.amigo_id);
    } catch (e) {
        console.error(e);
        res.redirect('/batalla');
    }
});

router.post('/batalla/cancelar', isAuthenticated, async (req, res) => {
    try {
        await db.execute('DELETE FROM salas_reto WHERE codigo = ? AND creador_id = ? AND estado = "esperando"', [req.body.codigo, req.session.userId]);
        res.redirect('/batalla');
    } catch (e) {
        console.error(e);
        res.redirect('/batalla');
    }
});

router.get('/batalla/:codigo', isAuthenticated, async (req, res) => {
    try {
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
router.get('/certificados', isAuthenticated, async (req, res) => {
    try {
        const [certificados] = await db.execute('SELECT * FROM certificados WHERE usuario_id = ? ORDER BY fecha DESC', [req.session.userId]);
        res.render('certificados/lista', { certificados, userId: req.session.userId });
    } catch (e) {
        console.error(e);
        res.status(500).send('Error');
    }
});

// Función auxiliar para generar el PDF
async function generarPDF(cert, ganador_nombre, res) {
    const PDFDocument = require('pdfkit');
    const doc = new PDFDocument({ layout: 'landscape', size: 'A4', margins: { top: 0, bottom: 0, left: 0, right: 0 } });
    
    res.setHeader('Content-disposition', 'inline; filename="certificado-'+cert.sala_codigo+'.pdf"');
    res.setHeader('Content-type', 'application/pdf');
    doc.pipe(res);

    doc.rect(0, 0, doc.page.width, doc.page.height).fill('#ffffff');
    doc.rect(20, 20, doc.page.width - 40, doc.page.height - 40).lineWidth(3).strokeColor('#cbd5e1').stroke();
    doc.rect(26, 26, doc.page.width - 52, doc.page.height - 52).lineWidth(1).strokeColor('#6366f1').stroke();

    const watermarkPath = require('path').join(__dirname, '../../public/img/logo_sin_fondo.png');
    if (require('fs').existsSync(watermarkPath)) {
        doc.save();
        doc.opacity(0.12);
        doc.image(watermarkPath, (doc.page.width - 500) / 2, (doc.page.height - 500) / 2, { fit: [500, 500], align: 'center', valign: 'center' });
        doc.restore();
    }

    doc.y = 100;
    doc.fontSize(32).fillColor('#0f172a').text('CERTIFICADO DE EXCELENCIA TÉCNICA', { align: 'center', characterSpacing: 2 });
    
    doc.moveDown(1);
    doc.fontSize(13).fillColor('#64748b').text('El comité de evaluación de TechSim Solutions, respaldado por especialistas del sector,', { align: 'center' });
    doc.fontSize(13).fillColor('#64748b').text('otorga la presente validación de competencias técnicas a:', { align: 'center' });
    
    doc.moveDown(1.5);
    doc.fontSize(34).fillColor('#16a34a').text(ganador_nombre.toUpperCase(), { align: 'center' });
    
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
    
    const startY = doc.page.height - 110;
    
    const firma1Path = require('path').join(__dirname, '../../public/img/firma1.png');
    if (require('fs').existsSync(firma1Path)) {
        doc.image(firma1Path, 80, startY - 45, { fit: [200, 60], align: 'center', valign: 'bottom' });
    }
    doc.moveTo(80, startY + 15).lineTo(280, startY + 15).lineWidth(1).strokeColor('#94a3b8').stroke();
    doc.fontSize(10).fillColor('#64748b').text('DIRECTOR DE EVALUACIÓN TÉCNICA', 80, startY + 25, { width: 200, align: 'center' });
    doc.fillColor('#334155').text('TechSim Solutions', 80, startY + 40, { width: 200, align: 'center' });
    
    const firma2Path = require('path').join(__dirname, '../../public/img/firma2.png');
    if (require('fs').existsSync(firma2Path)) {
        doc.image(firma2Path, doc.page.width - 280, startY - 45, { fit: [200, 60], align: 'center', valign: 'bottom' });
    }
    doc.moveTo(doc.page.width - 280, startY + 15).lineTo(doc.page.width - 80, startY + 15).lineWidth(1).strokeColor('#94a3b8').stroke();
    doc.fontSize(10).fillColor('#64748b').text('VALIDACIÓN DEL SISTEMA', doc.page.width - 280, startY + 25, { width: 200, align: 'center' });
    doc.fillColor('#334155').text(`Código: ${cert.sala_codigo} | Fecha: ${new Date(cert.fecha).toLocaleDateString()}`, doc.page.width - 280, startY + 40, { width: 200, align: 'center' });

    doc.save();
    doc.translate(doc.page.width / 2, startY + 20);
    doc.rotate(-15);
    doc.fontSize(28).fillOpacity(0.1).fillColor('#16a34a').text('VERIFIED', -70, -15);
    doc.restore();

    doc.end();
}

router.get('/c/:id', async (req, res) => {
    try {
        const [[cert]] = await db.execute('SELECT c.*, u.nombre as ganador_nombre FROM certificados c JOIN usuarios u ON c.usuario_id = u.id WHERE c.id = ?', [req.params.id]);
        if (!cert) return res.status(404).send('Certificado no encontrado');
        
        await generarPDF(cert, cert.ganador_nombre, res);
    } catch (e) {
        console.error(e);
        res.status(500).send('Error al generar el certificado público');
    }
});

router.get('/certificados/:id/pdf', isAuthenticated, async (req, res) => {
    try {
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