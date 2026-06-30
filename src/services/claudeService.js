require('dotenv').config();

const CLAUDE_API_KEY = process.env.CLAUDE_API_KEY || process.env.ANTHROPIC_API_KEY;
const CLAUDE_API_URL = process.env.CLAUDE_API_URL || process.env.ANTHROPIC_API_URL || 'https://api.anthropic.com/v1/messages';
const CLAUDE_MODEL_ENV = process.env.CLAUDE_MODEL || process.env.ANTHROPIC_MODEL;

const MODELOS_CLAUDE = CLAUDE_MODEL_ENV ? [CLAUDE_MODEL_ENV] : [
    'claude-sonnet-4-6',
    'claude-haiku-4-5-20251001'
];

/**
 * Limpia y repara respuestas de texto JSON inválidas que suelen venir de modelos LLM.
 */
function limpiarYParsearJSON(texto) {
    if (!texto) throw new Error('Respuesta vacía');

    let jsonStart = texto.indexOf('{');
    let jsonEnd = texto.lastIndexOf('}');

    if (jsonStart === -1 || jsonEnd === -1) {
        jsonStart = texto.indexOf('[');
        jsonEnd = texto.lastIndexOf(']');
    }

    if (jsonStart === -1 || jsonEnd === -1 || jsonEnd < jsonStart) {
        return JSON.parse(texto);
    }

    const jsonStr = texto.substring(jsonStart, jsonEnd + 1);

    function lookAheadForClosingQuote(str, index) {
        let i = index + 1;
        while (i < str.length && /\s/.test(str[i])) {
            i++;
        }
        if (i >= str.length) return true;

        const char = str[i];
        if (char === '}' || char === ']' || char === ':') {
            return true;
        }

        if (char === ',') {
            i++;
            while (i < str.length && /\s/.test(str[i])) {
                i++;
            }
            if (i >= str.length) return true;

            const nextChar = str[i];
            if (nextChar === '"' || nextChar === '{' || nextChar === '[' || nextChar === '-' || (nextChar >= '0' && nextChar <= '9')) {
                return true;
            }

            const rest = str.substring(i);
            if (rest.startsWith('true') || rest.startsWith('false') || rest.startsWith('null')) {
                return true;
            }

            return false;
        }

        return false;
    }

    let inString = false;
    let escaped = false;
    let resultado = '';

    for (let idx = 0; idx < jsonStr.length; idx++) {
        const char = jsonStr[idx];

        if (!inString) {
            if (char === '"') {
                inString = true;
                escaped = false;
                resultado += '"';
            } else {
                resultado += char;
            }
        } else {
            if (escaped) {
                resultado += char;
                escaped = false;
            } else if (char === '\\') {
                escaped = true;
                resultado += '\\';
            } else if (char === '\n') {
                resultado += '\\n';
            } else if (char === '\r') {
                resultado += '\\r';
            } else if (char === '"') {
                if (lookAheadForClosingQuote(jsonStr, idx)) {
                    inString = false;
                    resultado += '"';
                } else {
                    resultado += '\\"';
                }
            } else {
                resultado += char;
            }
        }
    }

    let limpio = resultado.replace(/,\s*([}\]])/g, '$1');

    try {
        return JSON.parse(limpio);
    } catch (err) {
        console.error("Error al parsear JSON limpio de Claude:", err.message);
        console.error("JSON procesado:", limpio);
        throw err;
    }
}

/**
 * Llama a la API de Anthropic Messages.
 */
async function llamarClaude(prompt) {
    if (!CLAUDE_API_KEY) {
        throw new Error('API Key de Claude no configurada. Por favor define CLAUDE_API_KEY o ANTHROPIC_API_KEY en tu archivo .env');
    }

    let ultimoError = '';

    for (const modelo of MODELOS_CLAUDE) {
        try {
            const url = CLAUDE_API_URL;
            const body = {
                model: modelo,
                max_tokens: 2048,
                messages: [
                    { role: 'user', content: prompt }
                ]
            };

            const res = await fetch(url, {
                method: 'POST',
                headers: {
                    'x-api-key': CLAUDE_API_KEY,
                    'anthropic-version': '2023-06-01',
                    'content-type': 'application/json'
                },
                body: JSON.stringify(body)
            });

            const data = await res.json();

            if (!res.ok) {
                ultimoError = `${modelo}: ${res.status} - ${JSON.stringify(data)}`;
                if (res.status === 401 || res.status === 403) {
                    throw new Error(ultimoError);
                }
                if (res.status === 429 || res.status === 503) {
                    await new Promise(r => setTimeout(r, 2000));
                    continue;
                }
                throw new Error(ultimoError);
            }

            let texto = data?.content?.[0]?.text;
            if (!texto) throw new Error('Respuesta vacía de Claude');

            return texto;
        } catch (err) {
            console.error(`Intento con Claude (${modelo}) falló:`, err.message);
            ultimoError = err.message;
            if (err.message.includes('401') || err.message.includes('403') || err.message.toLowerCase().includes('credit') || err.message.toLowerCase().includes('billing')) {
                throw err;
            }
            await new Promise(r => setTimeout(r, 1500));
        }
    }

    throw new Error(`Todos los intentos con Claude fallaron. Último error: ${ultimoError}`);
}

/**
 * Analiza un CV usando Claude basado en el puesto.
 * @param {string} puesto
 * @param {string} textoCV
 * @returns {Promise<Object>} Resultado formateado del análisis
 */
async function analizarCV(puesto, textoCV) {
    const prompt = `Eres un reclutador técnico experto en análisis de CVs para CUALQUIER área de Tecnologías de la Información (Desarrollo de Software, Data Science, Ciberseguridad, DevOps, Redes, QA, UX/UI, Soporte Técnico, etc.)

Analiza el siguiente CV para el puesto de "${puesto}".

CV:
${textoCV}

Primero identifica a qué área de TI pertenece el puesto, y luego evalúa el CV con criterios específicos de esa área (por ejemplo, si es Ciberseguridad evalúa certificaciones y herramientas de seguridad; si es Data Science evalúa estadística y manejo de datos; si es Desarrollo evalúa lenguajes y frameworks).

Responde ÚNICAMENTE con un JSON válido, sin texto adicional, sin markdown, con esta estructura exacta:

{
  "area_detectada": "área de TI a la que pertenece el puesto (ej: Desarrollo Backend, Ciberseguridad, Data Science, DevOps, Redes, QA, UX/UI)",
  "skills_detectadas": ["lista de tecnologías y habilidades que tiene el candidato, relevantes para esa área"],
  "skills_faltantes": ["lista de tecnologías o conocimientos importantes para el puesto que NO tiene"],
  "nivel_estimado": "Junior" | "Mid" | "Senior",
  "fortalezas": "resumen breve de 2 líneas de lo más fuerte del candidato",
  "recomendaciones": "consejo breve de 2-3 líneas para mejorar su perfil, específico al área detectada",
  "temas_practicar": ["lista de 3 a 5 temas que debería reforzar, propios del área detectada"]
}

No inventes información que no esté en el CV. Si el CV es muy corto o ambiguo, indícalo en "recomendaciones". Si el puesto no parece ser de TI, indícalo en "area_detectada" como "No es un puesto de TI" and responde el resto de los campos de forma general.`;

    try {
        if (!CLAUDE_API_KEY || CLAUDE_API_KEY.trim() === '' || CLAUDE_API_KEY.includes('tu_api_key')) {
            throw new Error('API Key de Claude no configurada. Por favor define CLAUDE_API_KEY en las variables de entorno de tu servidor de despliegue para poder realizar el análisis de CV.');
        }

        const respuesta = await llamarClaude(prompt);
        const parsed = limpiarYParsearJSON(respuesta);
        parsed.usandoFallbackGemini = false;
        return parsed;
    } catch (err) {
        console.error("Error al analizar CV con IA:", err);
        throw err;
    }
}

/**
 * Genera la siguiente pregunta de entrevista usando Claude con fallback a Gemini.
 */
async function generarPregunta(puesto, nivel, historial) {
    const historialTexto = historial.map((h, i) =>
        `Pregunta ${i + 1}: ${h.pregunta}\nRespuesta: ${h.respuesta}`
    ).join('\n\n');

    const numPregunta = historial.length + 1;

    const ultimaRespuesta = historial.length > 0 ? (historial[historial.length - 1].respuesta || '').toLowerCase().trim() : '';
    const esNoSe = /^(no s[eé]|no tengo idea|no recuerdo|no me acuerdo|desconozco|no lo s[eé]|ni idea|paso|no sé nada|no tengo conocimiento)/.test(ultimaRespuesta) || ultimaRespuesta.length < 10;

    const prompt = `Eres un entrevistador técnico experto, profesional y empático.
El candidato postula al puesto: "${puesto}" (nivel: ${nivel}).
Esta es la pregunta número ${numPregunta} de 5.

${historial.length > 0 ? `HISTORIAL DE LA ENTREVISTA HASTA AHORA:\n${historialTexto}` : 'Esta es la primera pregunta de la entrevista.'}

INSTRUCCIONES IMPORTANTES:
${esNoSe ? `- El candidato acaba de responder que NO SABE la pregunta anterior (o su respuesta fue muy corta/vacía).
  → Da una PISTA BREVE o simplifica el tema en tu siguiente pregunta (no lo abandones aún).
  → Internamente, marca ese tema como debilidad para el reporte final.
  → Sé empático, no agresivo. Ejemplo de transición: "Entiendo, no hay problema. Pasemos a..."
` : `- Si el candidato mostró debilidad en un tema anterior, profundiza o simplifica ahí.
- Si fue sólido, avanza a otra área técnica importante.
`}
- Genera UNA sola pregunta clara, directa y realista (como en una entrevista real).
- Dificultad progresiva: preguntas 1-2 básicas, 3-4 intermedias, 5 avanzada.
- NO repitas temas ya preguntados.
- Adapta al nivel ${nivel}.

Responde ÚNICAMENTE con un JSON con este formato exacto:
{"pregunta": "¿Aquí va la pregunta técnica?"}

IMPORTANTE: No incluyas saltos de línea reales dentro de la pregunta. Si necesitas un salto de línea, escápalo como \\n. No uses comillas dobles sin escapar dentro de la pregunta.`;

    try {
        const respuesta = await llamarClaude(prompt);
        const parsed = limpiarYParsearJSON(respuesta);
        return parsed.pregunta || `Cuéntame sobre tus experiencias previas trabajando con ${puesto} y qué retos has tenido.`;
    } catch (err) {
        console.error("Error al generar pregunta con Claude, intentando fallback a Gemini:", err);
        const { generarPregunta: generarPreguntaGemini } = require('./geminiService');
        return generarPreguntaGemini(puesto, nivel, historial);
    }
}

/**
 * Genera el reporte final de la entrevista usando Claude con fallback a Gemini.
 */
async function generarReporte(puesto, nivel, historial) {
    const historialTexto = historial.map((h, i) =>
        `Pregunta ${i + 1}: ${h.pregunta}\nRespuesta del candidato: ${h.respuesta}`
    ).join('\n\n');

    const temasNoSabe = historial
        .filter(h => {
            const r = (h.respuesta || '').toLowerCase().trim();
            return /^(no s[eé]|no tengo idea|no recuerdo|desconozco|ni idea|paso)/.test(r) || r.length < 10;
        })
        .map((h, idx) => `Pregunta ${historial.indexOf(h) + 1}: "${h.pregunta}" → El candidato respondió que no sabía.`);

    const advertenciaNoSabe = temasNoSabe.length > 0
        ? `\nATENCIÓN — El candidato respondió "no sé" o de forma insuficiente en estos temas:\n${temasNoSabe.join('\n')}\nEstos deben aparecer explícitamente como debilidades en el reporte y penalizar la nota de forma proporcional.\n`
        : '';

    const prompt = `Eres un evaluador técnico experto. Analiza la siguiente entrevista técnica completa.
Puesto: "${puesto}" | Nivel esperado: ${nivel}
${advertenciaNoSabe}
ENTREVISTA COMPLETA:
${historialTexto}

Evalúa al candidato de forma rigurosa, justa y honesta.
- Si respondió "no sé" en alguna pregunta, debe reflejarse en la nota y en las debilidades.
- Si respondió bien en otras, reconócelo en las fortalezas.
- La nota debe ser proporcional a la calidad REAL de las respuestas.

Responde ÚNICAMENTE con un JSON válido con este formato exacto (sin texto adicional, sin markdown):
{
  "nota": 14.5,
  "nivel_alcanzado": "Junior sólido",
  "resumen": "Descripción honesta del desempeño general del candidato (2-3 oraciones)",
  "fortalezas": [
    "Descripción concreta de fortaleza 1",
    "Descripción concreta de fortaleza 2"
  ],
  "debilidades": [
    "No supo responder sobre [tema específico que dijo no saber]",
    "Descripción concreta de debilidad 2"
  ],
  "recomendacion": "Consejo práctico y específico para mejorar, enfocado en los temas donde falló",
  "evaluacion_por_area": [
    {"area": "Conocimiento Técnico", "puntaje": 15, "maximo": 20, "comentario": "..."},
    {"area": "Resolución de Problemas", "puntaje": 13, "maximo": 20, "comentario": "..."},
    {"area": "Comunicación", "puntaje": 16, "maximo": 20, "comentario": "..."},
    {"area": "Experiencia Práctica", "puntaje": 12, "maximo": 20, "comentario": "..."},
    {"area": "Cultura y Actitud", "puntaje": 17, "maximo": 20, "comentario": "..."}
  ],
  "contrataria": true
}

IMPORTANTE: Si usas comillas dobles (") dentro de cualquier texto en el JSON (por ejemplo, en resumen, comentarios o debilidades), DEBES escaparlas como \\\" o usar comillas simples ('). No incluyas saltos de línea reales dentro de los valores de texto del JSON; si requieres saltos de línea, escápala como \\n.`;

    try {
        const respuesta = await llamarClaude(prompt);
        return limpiarYParsearJSON(respuesta);
    } catch (err) {
        console.error("Error al generar reporte con Claude, intentando fallback a Gemini:", err);
        const { generarReporte: generarReporteGemini } = require('./geminiService');
        return generarReporteGemini(puesto, nivel, historial);
    }
}

/**
 * Genera retos de programación personalizados basados en habilidades faltantes.
 */
async function generarRetosPorHabilidades(puesto, skillsFaltantes) {
    const prompt = `Eres un ingeniero de software senior y creador de problemas estilo LeetCode o HackerRank.
Un candidato para el puesto de "${puesto}" necesita mejorar urgentemente en las siguientes habilidades o temas: ${skillsFaltantes}.

Tu tarea es generar exactamente 3 retos (ejercicios) de programación prácticos que ayuden al candidato a aprender, practicar y dominar estas habilidades específicas.

Restricciones para cada reto:
1. El "lenguaje" sugerido debe ser "JavaScript", a menos que las habilidades faltantes requieran estrictamente "Python", "Java", "C++" o "C#".
2. Debe incluir un "codigo_inicial" válido en ese lenguaje con la firma de una función llamada "solucion" (ej. function solucion(arg1) { ... }).
3. Debe incluir 2 casos de prueba obligatorios. Cada caso debe tener "input" (el valor literal que se pasará, ej: '[1, 2, 3]' o '10, 5') y "output" (el valor esperado, ej: '6' o '"hola"'). 
4. El nivel de dificultad debe ser 1 "Fácil", 1 "Medio", y 1 "Difícil" o "Medio".

Responde ÚNICAMENTE con un JSON válido, sin markdown ni texto extra, con esta estructura exacta:

[
  {
    "titulo": "Título corto del reto",
    "enunciado": "Descripción detallada del problema y lo que se espera que haga la función.",
    "lenguaje": "JavaScript",
    "codigo_inicial": "function solucion(a) {\\n  // Tu código aquí\\n}",
    "pista": "Una pista breve para resolver el problema.",
    "dificultad": "Fácil",
    "casos_prueba": [
      { "input": "...", "output": "..." },
      { "input": "...", "output": "..." }
    ]
  },
  ...
]

IMPORTANTE: Si usas saltos de línea dentro de los strings (como en codigo_inicial o enunciado), asegúrate de escaparlos correctamente como \\n. No uses comillas dobles sin escapar dentro de los strings.`;

    try {
        const respuesta = await llamarClaude(prompt);
        const parsed = limpiarYParsearJSON(respuesta);
        return Array.isArray(parsed) ? parsed : [];
    } catch (err) {
        console.error("Error al generar retos con Claude:", err);
        throw new Error("No se pudieron generar los retos de mejora en este momento.");
    }
}

module.exports = { analizarCV, generarPregunta, generarReporte, generarRetosPorHabilidades };
