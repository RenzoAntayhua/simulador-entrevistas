const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const Banco = require('../models/bancoModel');

// --- RUTA PRINCIPAL ---
router.get('/', (req, res) => {
    if (req.session && req.session.userId) {
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

module.exports = router;