const db = require('../config/db');
const Banco = require('../models/bancoModel');

exports.listarBancos = async (req, res) => {
    try {
        const [todosLosBancos] = await db.execute(`
            SELECT b.*, AVG(c.estrellas) as promedio, COUNT(c.id) as total_votos 
            FROM bancos b 
            LEFT JOIN calificaciones c ON b.id = c.banco_id 
            GROUP BY b.id`);
        res.render('bancos/lista', { bancos: todosLosBancos });
    } catch (error) {
        res.send("Error al cargar la lista");
    }
};

exports.getCrearBanco = (req, res) => {
    res.render('bancos/crear');
};

exports.postCrearBanco = async (req, res) => {
    const { titulo, descripcion, categoria } = req.body;
    try {
        await Banco.create(titulo, descripcion, categoria, req.session.userId);
        res.redirect('/dashboard'); 
    } catch (error) {
        res.send("Error al guardar banco");
    }
};

exports.getEditarBanco = async (req, res) => {
    const bancoId = req.params.id;
    try {
        const [banco] = await db.execute('SELECT * FROM bancos WHERE id = ? AND autor_id = ?', [bancoId, req.session.userId]);
        if (banco.length > 0) {
            res.render('bancos/editar', { banco: banco[0] });
        } else {
            res.status(403).send("No tienes permiso o el banco no existe.");
        }
    } catch (error) {
        res.send("Error al cargar el banco para editar.");
    }
};

exports.postEditarBanco = async (req, res) => {
    const bancoId = req.params.id;
    const { titulo, descripcion, categoria } = req.body;
    try {
        await db.execute(
            'UPDATE bancos SET titulo = ?, descripcion = ?, categoria = ? WHERE id = ? AND autor_id = ?',
            [titulo, descripcion, categoria, bancoId, req.session.userId]
        );
        res.redirect('/bancos/ver/' + bancoId);
    } catch (error) {
        res.send("Error al editar el banco.");
    }
};

exports.postEliminarBanco = async (req, res) => {
    const bancoId = req.params.id;
    try {
        await db.execute('DELETE FROM bancos WHERE id = ? AND autor_id = ?', [bancoId, req.session.userId]);
        res.redirect('/dashboard');
    } catch (error) {
        res.send("Error al eliminar el banco.");
    }
};

exports.postEliminarPregunta = async (req, res) => {
    const preguntaId = req.params.id;
    const { banco_id } = req.body;
    try {
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
};

exports.verBanco = async (req, res) => {
    const bancoId = req.params.id;
    try {
        const [bancos] = await db.execute(`
            SELECT b.*, AVG(c.estrellas) as promedio, COUNT(c.id) as total_votos 
            FROM bancos b 
            LEFT JOIN calificaciones c ON b.id = c.banco_id 
            WHERE b.id = ? 
            GROUP BY b.id`, [bancoId]);

        const [preguntasDB] = await db.execute('SELECT * FROM preguntas WHERE banco_id = ?', [bancoId]);

        let preguntas = preguntasDB.sort(() => Math.random() - 0.5);

        preguntas = preguntas.map(p => {
            let opcionesValidas = [
                { original: 'A', valor: p.opcion_a },
                { original: 'B', valor: p.opcion_b },
                { original: 'C', valor: p.opcion_c },
                { original: 'D', valor: p.opcion_d },
                { original: 'E', valor: p.opcion_e },
                { original: 'F', valor: p.opcion_f }
            ].filter(opt => opt.valor && opt.valor.trim() !== '');

            const opcionCorrectaOriginal = opcionesValidas.find(o => o.original === p.respuesta_correcta);
            opcionesValidas = opcionesValidas.sort(() => Math.random() - 0.5);

            const opcionesMezcladas = opcionesValidas.map((opt, i) => {
                const nuevaLetra = String.fromCharCode(65 + i);
                if (opcionCorrectaOriginal && opt.original === opcionCorrectaOriginal.original) {
                    p.respuesta_correcta = nuevaLetra;
                }
                return { letra: nuevaLetra, valor: opt.valor };
            });

            p.opciones_mezcladas = opcionesMezcladas;
            return p;
        });

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
};

exports.postCrearPregunta = async (req, res) => {
    const { banco_id, enunciado, opcion_a, opcion_b, opcion_c, opcion_d, opcion_e, opcion_f, respuesta_correcta } = req.body;
    const usuario_logueado = req.session.userId;

    try {
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
};

exports.calificarBanco = async (req, res) => {
    const { banco_id, estrellas } = req.body;
    const usuario_id = req.session.userId;
    try {
        await db.execute(
            'INSERT INTO calificaciones (usuario_id, banco_id, estrellas) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE estrellas = ?',
            [usuario_id, banco_id, estrellas, estrellas]
        );
        res.redirect('/bancos/ver/' + banco_id);
    } catch (error) {
        res.send("Error al calificar");
    }
};
