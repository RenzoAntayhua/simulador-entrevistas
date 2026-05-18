const db = require('../config/db');
const PDFDocument = require('pdfkit');
const path = require('path');

exports.getDashboard = async (req, res) => {
    try {
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
};

exports.getUsuarios = async (req, res) => {
    try {
        const [usuarios] = await db.execute('SELECT * FROM usuarios');
        res.render('admin/usuarios', { layout: false, usuarios });
    } catch (e) {
        res.status(500).send('Error get usuarios');
    }
};

exports.toggleUsuario = async (req, res) => {
    res.redirect('/admin/usuarios');
};

exports.cambiarRol = async (req, res) => {
    try {
        const [userDb] = await db.execute('SELECT rol FROM usuarios WHERE id = ?', [req.params.id]);
        if (userDb.length > 0) {
            const nuevoRol = userDb[0].rol === 'admin' ? 'user' : 'admin';
            await db.execute('UPDATE usuarios SET rol = ? WHERE id = ?', [nuevoRol, req.params.id]);
        }
        res.redirect('/admin/usuarios');
    } catch (e) {
        res.status(500).send('Error');
    }
};

exports.getRetos = async (req, res) => {
    try {
        const [retos] = await db.execute('SELECT * FROM retos');
        res.render('admin/retos', { layout: false, retos });
    } catch (e) {
        res.status(500).send('Error get retos');
    }
};

exports.deleteReto = async (req, res) => {
    try {
        await db.execute('DELETE FROM retos WHERE id = ?', [req.params.id]);
        res.redirect('/admin/retos');
    } catch (e) {
        res.status(500).send('Error delete r');
    }
};

exports.getBancos = async (req, res) => {
    try {
        const [bancos] = await db.execute('SELECT * FROM bancos');
        res.render('admin/bancos', { layout: false, bancos });
    } catch (e) {
        res.status(500).send('Error get bancos');
    }
};

exports.deleteBanco = async (req, res) => {
    try {
        await db.execute('DELETE FROM bancos WHERE id = ?', [req.params.id]);
        res.redirect('/admin/bancos');
    } catch (e) {
        res.status(500).send('Error delete b');
    }
};

exports.generarReportePDF = async (req, res) => {
    try {
        const [[{total: usuarios}]] = await db.execute('SELECT COUNT(*) as total FROM usuarios');
        const [[{total: retos}]] = await db.execute('SELECT COUNT(*) as total FROM retos');
        const [[{total: bancos}]] = await db.execute('SELECT COUNT(*) as total FROM bancos');
        const [[{total: intentos}]] = await db.execute("SELECT COUNT(*) as total FROM intentos_retos WHERE resultado='Exitoso'");
        
        const [topUsuarios] = await db.execute('SELECT u.nombre, COUNT(ir.id) as total FROM intentos_retos ir JOIN usuarios u ON ir.usuario_id = u.id GROUP BY u.id ORDER BY total DESC LIMIT 5');
        const [topRetos] = await db.execute('SELECT r.titulo, COUNT(ir.id) as total FROM intentos_retos ir JOIN retos r ON ir.reto_id = r.id GROUP BY r.id ORDER BY total DESC LIMIT 5');

        const doc = new PDFDocument({ margin: 50, size: 'A4', autoFirstPage: true });
        doc.info['Title'] = 'Reporte Administrativo';
        
        res.setHeader('Content-disposition', 'attachment; filename="reporte-sistema.pdf"');
        res.setHeader('Content-type', 'application/pdf');
        doc.pipe(res);

        doc.rect(0, 0, doc.page.width, 100).fill('#0f172a');
        doc.fillColor('#ffffff')
           .font('Helvetica-Bold')
           .fontSize(28)
           .text('Simulador de Entrevistas', 0, 25, { align: 'center', width: doc.page.width });
        doc.fontSize(12)
           .fillColor('#94a3b8')
           .text('Reporte Administrativo del Sistema', 0, 60, { align: 'center', width: doc.page.width });
           
        doc.fillColor('#333333')
           .font('Helvetica')
           .fontSize(10)
           .text('Fecha de generación: ' + new Date().toLocaleDateString() + ' ' + new Date().toLocaleTimeString(), 50, 120, { align: 'right' });
        doc.moveDown(2);

        doc.font('Helvetica-Bold').fontSize(16).fillColor('#2563eb').text('Estadísticas Generales');
        doc.moveTo(50, doc.y + 5).lineTo(545, doc.y + 5).lineWidth(1).strokeColor('#e2e8f0').stroke();
        doc.moveDown(1.5);
        
        doc.font('Helvetica').fontSize(12).fillColor('#334155');
        const startY = doc.y;
        
        doc.rect(50, startY, 230, 45).fillAndStroke('#f8fafc', '#e2e8f0');
        doc.fillColor('#475569').font('Helvetica-Bold').text('Total Usuarios:', 65, startY + 16);
        doc.fillColor('#10b981').text(usuarios.toString(), 200, startY + 16, { width: 65, align: 'right' });

        doc.rect(315, startY, 230, 45).fillAndStroke('#f8fafc', '#e2e8f0');
        doc.fillColor('#475569').text('Total Retos:', 330, startY + 16);
        doc.fillColor('#10b981').text(retos.toString(), 465, startY + 16, { width: 65, align: 'right' });
        
        doc.rect(50, startY + 60, 230, 45).fillAndStroke('#f8fafc', '#e2e8f0');
        doc.fillColor('#475569').text('Total Bancos:', 65, startY + 76);
        doc.fillColor('#10b981').text(bancos.toString(), 200, startY + 76, { width: 65, align: 'right' });

        doc.rect(315, startY + 60, 230, 45).fillAndStroke('#f8fafc', '#e2e8f0');
        doc.fillColor('#475569').text('Intentos Exitosos:', 330, startY + 76);
        doc.fillColor('#10b981').text(intentos.toString(), 465, startY + 76, { width: 65, align: 'right' });

        doc.y = startY + 140;
        doc.x = 50;

        doc.font('Helvetica-Bold').fontSize(16).fillColor('#2563eb').text('Top 5 Usuarios Más Activos', 50, doc.y);
        doc.moveTo(50, doc.y + 5).lineTo(545, doc.y + 5).strokeColor('#e2e8f0').stroke();
        
        let yPos = doc.y + 15;
        doc.font('Helvetica-Bold').fontSize(10).fillColor('#64748b');
        doc.text('PUESTO', 55, yPos, { lineBreak: false });
        doc.text('NOMBRE DEL USUARIO', 130, yPos, { lineBreak: false });
        doc.text('INTENTOS', 450, yPos, { width: 85, align: 'right', lineBreak: false });
        yPos += 20;

        doc.font('Helvetica').fontSize(12);
        topUsuarios.forEach((u, i) => {
            if(i % 2 === 0) doc.rect(50, yPos - 5, 495, 28).fill('#f1f5f9');
            doc.fillColor('#1e293b');
            doc.text('#' + (i+1), 55, yPos, { lineBreak: false });
            doc.text(u.nombre, 130, yPos, { lineBreak: false });
            doc.fillColor('#10b981').font('Helvetica-Bold').text(u.total.toString(), 450, yPos, { width: 85, align: 'right', lineBreak: false });
            doc.font('Helvetica');
            yPos += 28;
        });
        
        yPos += 20;

        doc.font('Helvetica-Bold').fontSize(16).fillColor('#2563eb').text('Top 5 Retos Más Intentados', 50, yPos);
        doc.moveTo(50, doc.y + 5).lineTo(545, doc.y + 5).strokeColor('#e2e8f0').stroke();
        
        yPos = doc.y + 15;
        doc.font('Helvetica-Bold').fontSize(10).fillColor('#64748b');
        doc.text('RANKING', 55, yPos, { lineBreak: false });
        doc.text('TÍTULO DEL RETO', 130, yPos, { lineBreak: false });
        doc.text('INTENTOS', 450, yPos, { width: 85, align: 'right', lineBreak: false });
        yPos += 20;

        doc.font('Helvetica').fontSize(12);
        topRetos.forEach((r, i) => {
            let limitTitulo = r.titulo.length > 50 ? r.titulo.substring(0, 47) + '...' : r.titulo;
            if(i % 2 === 0) doc.rect(50, yPos - 5, 495, 28).fill('#f1f5f9');
            doc.fillColor('#1e293b');
            doc.text('#' + (i+1), 55, yPos, { lineBreak: false });
            doc.text(limitTitulo, 130, yPos, { lineBreak: false });
            doc.fillColor('#f59e0b').font('Helvetica-Bold').text(r.total.toString(), 450, yPos, { width: 85, align: 'right', lineBreak: false });
            doc.font('Helvetica');
            yPos += 28;
        });

        doc.x = 50; 
        doc.y = yPos;

        doc.fillColor('#94a3b8').fontSize(10)
           .text('Simulador de Entrevistas - Reporte Generado Automáticamente', 50, 780, { align: 'center', width: 495, lineBreak: false });

        doc.end();
    } catch (error) {
        console.error(error);
        res.status(500).send('Error generando PDF');
    }
};
