const db = require('../config/db');
const { performance } = require('perf_hooks');

exports.listarRetos = async (req, res) => {
    try {
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
};

exports.getCrearReto = (req, res) => {
    res.render('retos/crear');
};

exports.postCrearReto = async (req, res) => {
    const { titulo, enunciado, codigo_inicial, dificultad, lenguaje, pista, casos_input, casos_output, casos_visible } = req.body;
    
    try {
        let inputs = Array.isArray(casos_input) ? casos_input : [casos_input];
        let outputs = Array.isArray(casos_output) ? casos_output : [casos_output];
        let visibles = Array.isArray(casos_visible) ? casos_visible : [casos_visible];

        inputs = inputs.map(i => i ? i.replace(/^input\s*(ej)?:?\s*/i, '').replace(/^ej:\s*/i, '').trim() : '');
        outputs = outputs.map(o => o ? o.replace(/^output\s*(ej)?:?\s*/i, '').replace(/^ej:\s*/i, '').trim() : '');

        let test_input = inputs.length > 0 && inputs[0] !== '' ? inputs[0] : null;
        let test_output = outputs.length > 0 && outputs[0] !== '' ? outputs[0] : null;

        const [result] = await db.execute(
            'INSERT INTO retos (titulo, enunciado, codigo_inicial, test_input, test_output, dificultad, lenguaje, pista, autor_id, puntos) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [titulo, enunciado, codigo_inicial || '', test_input, test_output, dificultad, lenguaje || 'JavaScript', pista || null, req.session.userId, 10]
        );
        
        const retoId = result.insertId;

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
};

exports.calificarReto = async (req, res) => {
    const { reto_id, estrellas } = req.body;
    try {
        await db.execute(
            'INSERT INTO calificaciones_retos (usuario_id, reto_id, estrellas) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE estrellas = ?',
            [req.session.userId, reto_id, estrellas, estrellas]
        );
        res.redirect('/retos/resolver/' + reto_id);
    } catch (error) {
        console.error(error);
        res.send("Error al calificar el reto");
    }
};

exports.getResolverReto = async (req, res) => {
    const retoId = req.params.id;
    try {
        const [retos] = await db.execute('SELECT * FROM retos WHERE id = ?', [retoId]);
        
        if (retos.length > 0) {
            const [leaderboard] = await db.execute(`
                SELECT u.nombre, ir.fecha
                FROM intentos_retos ir
                JOIN usuarios u ON ir.usuario_id = u.id
                WHERE ir.reto_id = ? AND ir.resultado = 'Exitoso'
                ORDER BY ir.fecha ASC
                LIMIT 5
            `, [retoId]);

            let casosPrueba = [];
            try {
                const [rows] = await db.execute('SELECT * FROM casos_prueba WHERE reto_id = ?', [retoId]);
                casosPrueba = rows;
            } catch (err) {
                console.log("Aviso: tabla casos_prueba no encontrada o error:", err.message);
            }
            
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
};

exports.evaluarRetoEnBackend = async (req, res) => {
    const { reto_id, codigo } = req.body;
    
    try {
        const [retos] = await db.execute('SELECT * FROM retos WHERE id = ?', [reto_id]);
        if (retos.length === 0) return res.status(404).json({ error: "Reto no encontrado" });
        const reto = retos[0];

        let [casosPrueba] = await db.execute('SELECT * FROM casos_prueba WHERE reto_id = ?', [reto_id]);
        
        if (casosPrueba.length === 0 && reto.test_input) {
            casosPrueba = [{ input: reto.test_input, output_esperado: reto.test_output, es_visible: 1 }];
        }

        if (casosPrueba.length === 0) {
            return res.status(400).json({ error: "No hay casos de prueba para evaluar" });
        }

        const lenguajesIds = {
            "JavaScript": 63,
            "Python": 71,
            "Java": 62,
            "C++": 54,
            "C#": 51
        };
        const language_id = lenguajesIds[reto.lenguaje] || 63;

        let allTestsPassed = true;
        let executionOutput = "\n--- RESULTADOS ---\n";
        let visibleCount = 1;
        let hiddenCount = 1;

        const globalStart = performance.now();

        for (const test of casosPrueba) {
            let source_code = codigo;

            if (language_id === 62) { 
                source_code = `import java.util.Scanner;\npublic class Main {\n${codigo}\n    public static void main(String[] args) {\n        Scanner scanner = new Scanner(System.in);\n        if(scanner.hasNextLine()){\n            String input = scanner.nextLine();\n            System.out.println(solucion(input));\n        }\n    }\n}`;
            } else if (language_id === 71) { 
                source_code = `${codigo}\nimport sys\nimport ast\ntry:\n    args = ast.literal_eval('[' + sys.stdin.read().strip() + ']')\nexcept:\n    args = eval('[' + sys.stdin.read().strip().replace('true', 'True').replace('false', 'False') + ']')\nprint(solucion(*args))`;
            } else if (language_id === 63) { 
                source_code = `${codigo}\nconst fs = require('fs');\nconst input = fs.readFileSync(0, 'utf-8').trim();\nlet args;\ntry { args = eval('[' + input + ']'); } catch(e) { args = [input]; }\nconsole.log(solucion(...args));`;
            } else if (language_id === 54) { 
                source_code = `#include <iostream>\nusing namespace std;\n${source_code}\nint main() {\n    int n;\n    cin >> n;\n    cout << (solucion(n) ? "true" : "false") << endl;\n    return 0;\n}`;
            }

            const response = await fetch('https://ce.judge0.com/submissions?wait=true', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    source_code: source_code,
                    language_id: language_id,
                    stdin: test.input
                })
            });

            const data = await response.json();

            if (!data || !data.status) {
                throw new Error('Judge0 no devolvió respuesta válida');
            }

            if (data.status.id !== 3) {
                allTestsPassed = false;
                let errStr = data.compile_output || data.stderr || data.status.description;
                if (test.es_visible === 1) {
                    executionOutput += `❌ Test Visible ${visibleCount} falló: ${errStr}\n`;
                    visibleCount++;
                } else {
                    executionOutput += `❌ Test Oculto ${hiddenCount} falló en ejecución.\n`;
                    hiddenCount++;
                }
                continue;
            }

            let stdoutClear = (data.stdout || '').replace(/\\/g, '').replace(/"/g, '').trim();
            let expectedClear = (test.output_esperado || '').replace(/\\/g, '').replace(/"/g, '').trim();

            const isMatch = stdoutClear === expectedClear;
            if (!isMatch) allTestsPassed = false;

            if (test.es_visible === 1) {
                const icon = isMatch ? "✅" : "❌";
                executionOutput += `${icon} Test ${visibleCount}: Input: ${test.input} | Esperado: ${test.output_esperado} | Obtenido: ${data.stdout ? data.stdout.trim() : 'Vacío'}\n`;
                visibleCount++;
            } else {
                if (!isMatch) {
                    executionOutput += `❌ Test Oculto ${hiddenCount} falló.\n`;
                }
                hiddenCount++;
            }
        }

        const globalEnd = performance.now();
        const totalTime = (globalEnd - globalStart).toFixed(2);

        if (allTestsPassed) {
            executionOutput += `\n🎉 ¡EL CÓDIGO PASÓ TODAS LAS PRUEBAS! (${totalTime}ms) 🎉\n`;
        } else {
            executionOutput += `\n⚠️ Fallaste algunas pruebas. Revisa tu intento.\n`;
        }

        await db.execute(
            'INSERT INTO intentos_retos (usuario_id, reto_id, codigo_enviado, resultado) VALUES (?, ?, ?, ?)',
            [req.session.userId, reto_id, codigo, allTestsPassed ? 'Exitoso' : 'Fallido']
        );
        
        res.json({ success: true, allTestsPassed, executionOutput, totalTime });
    } catch (error) {
        console.error(error);
        
        await db.execute(
            'INSERT INTO intentos_retos (usuario_id, reto_id, codigo_enviado, resultado) VALUES (?, ?, ?, ?)',
            [req.session.userId, reto_id, codigo, 'Fallido']
        );
        
        res.status(500).json({ error: "Error en la evaluación del código.", details: error.message });
    }
};
