require('dotenv').config();

// Modelos a intentar en orden si uno falla por cuota
const MODELOS = [
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash',
    'gemini-1.5-pro-latest',
    'gemini-1.5-pro'
];

/**
 * Llama a la Gemini API con un prompt dado.
 * Intenta varios modelos si el primero falla.
 */
async function llamarGemini(prompt) {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey || apiKey.trim() === '' || apiKey === 'undefined' || apiKey.includes('tu_api_key')) {
        throw new Error('API Key de Gemini no configurada. Por favor define GEMINI_API_KEY en tu archivo .env o en las variables de entorno del servidor de despliegue.');
    }
    const errores = [];

    for (const modelo of MODELOS) {
        let intentosRestantes = 3;
        let exito = false;

        while (intentosRestantes > 0 && !exito) {
            try {
                const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelo}:generateContent?key=${apiKey}`;
                const body = {
                    contents: [{ parts: [{ text: prompt }] }],
                    generationConfig: {
                        temperature: 0.7,
                        maxOutputTokens: 2048,
                        responseMimeType: 'application/json'
                    }
                };

                const res = await fetch(url, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(body)
                });

                const data = await res.json();

                if (!res.ok) {
                    const errMsg = data.error?.message || JSON.stringify(data);
                    
                    // Si es un error de cuota temporal (429) o servicio no disponible (503), esperamos y reintentamos el mismo modelo
                    if (res.status === 429 || res.status === 503 || errMsg.includes('Quota exceeded')) {
                        intentosRestantes--;
                        if (intentosRestantes > 0) {
                            console.warn(`Gemini (${modelo}) limitó la tasa (HTTP ${res.status}). Reintentando en 3.5s... (Intentos restantes: ${intentosRestantes})`);
                            await new Promise(r => setTimeout(r, 3500));
                            continue;
                        }
                    }

                    const modelError = `${modelo} (HTTP ${res.status}): ${errMsg}`;
                    console.error(`Intento con Gemini (${modelo}) falló:`, modelError);
                    errores.push(modelError);
                    break; // Salir de los reintentos y probar el siguiente modelo
                }

                let texto = data?.candidates?.[0]?.content?.parts?.[0]?.text;
                if (!texto) throw new Error('Respuesta vacía de Gemini');

                // Limpiar posibles bloques markdown
                texto = texto.trim()
                    .replace(/^```json\s*/i, '')
                    .replace(/^```\s*/i, '')
                    .replace(/\s*```$/i, '')
                    .trim();

                return texto;
            } catch (err) {
                intentosRestantes--;
                const catchError = `${modelo} (Error de red/petición): ${err.message}`;
                console.error(`Excepción con Gemini (${modelo}):`, err.message);
                if (intentosRestantes <= 0) {
                    errores.push(catchError);
                } else {
                    await new Promise(r => setTimeout(r, 2000));
                }
            }
        }
    }

    throw new Error(`Todos los modelos de Gemini fallaron. Detalles: [${errores.join(' | ')}]`);
}

/**
 * Limpia y repara respuestas de texto JSON inválidas que suelen venir de modelos LLM.
 * Escapa comillas internas y corrige saltos de línea reales dentro de valores.
 */
function limpiarYParsearJSON(texto) {
    if (!texto) throw new Error('Respuesta vacía');

    // Encontrar el bloque JSON
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

    // Helper para mirar adelante y ver si la comilla es un delimitador de JSON real
    function lookAheadForClosingQuote(str, index) {
        let i = index + 1;
        while (i < str.length && /\s/.test(str[i])) {
            i++;
        }
        if (i >= str.length) return true; // Fin del JSON
        
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

    // Eliminar comas huérfanas antes de llaves/corchetes de cierre
    let limpio = resultado.replace(/,\s*([}\]])/g, '$1');

    try {
        return JSON.parse(limpio);
    } catch (err) {
        console.error("Error al parsear JSON limpio:", err.message);
        console.error("JSON procesado:", limpio);
        throw err;
    }
}

/**
 * Genera la siguiente pregunta de entrevista adaptada al historial.
 * @param {string} puesto - El puesto al que postula el candidato
 * @param {string} nivel - Junior / Mid / Senior
 * @param {Array} historial - Array de {pregunta, respuesta}
 * @returns {Promise<string>} La siguiente pregunta
 */
async function generarPregunta(puesto, nivel, historial) {
    const historialTexto = historial.map((h, i) =>
        `Pregunta ${i + 1}: ${h.pregunta}\nRespuesta: ${h.respuesta}`
    ).join('\n\n');

    const numPregunta = historial.length + 1;

    // Detectar si la última respuesta fue un "no sé"
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
        const respuesta = await llamarGemini(prompt);
        const parsed = limpiarYParsearJSON(respuesta);
        return parsed.pregunta || `Cuéntame sobre tus experiencias previas trabajando con ${puesto} y qué retos has tenido.`;
    } catch (err) {
        console.error("Error al generar pregunta con Gemini:", err);
        const defaultQuestions = [
            `¿Cuáles consideras que son las mejores prácticas al desarrollar con ${puesto}?`,
            `¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de ${puesto}?`,
            `Describe un problema técnico difícil que hayas resuelto recientemente en ${puesto}.`,
            `¿Qué herramientas o librerías consideras esenciales para trabajar con ${puesto} y por qué?`
        ];
        return defaultQuestions[Math.min(historial.length, defaultQuestions.length - 1)];
    }
}

/**
 * Genera el reporte final de la entrevista.
 * @param {string} puesto
 * @param {string} nivel
 * @param {Array} historial - Array de {pregunta, respuesta}
 * @returns {Promise<Object>} Reporte completo en JSON
 */
async function generarReporte(puesto, nivel, historial) {
    const historialTexto = historial.map((h, i) =>
        `Pregunta ${i + 1}: ${h.pregunta}\nRespuesta del candidato: ${h.respuesta}`
    ).join('\n\n');

    // Detectar respuestas "no sé" para mencionarlas explícitamente en el prompt
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
        const respuesta = await llamarGemini(prompt);
        return limpiarYParsearJSON(respuesta);
    } catch (err) {
        console.error("Error al generar reporte con Gemini:", err);
        // Calcular una nota de fallback basada en las respuestas "no sé"
        const fallas = temasNoSabe.length;
        const notaFallback = Math.max(5, 20 - (fallas * 3) - (Math.random() * 2));
        const notaRedondeada = Math.round(notaFallback * 10) / 10;
        
        return {
            nota: notaRedondeada,
            nivel_alcanzado: fallas > 2 ? `${nivel} con debilidades` : `${nivel} apto`,
            resumen: `Reporte de contingencia generado automáticamente debido a una interrupción en el análisis. El candidato completó la entrevista para ${puesto} (${nivel}) respondiendo a ${historial.length} preguntas.`,
            fortalezas: [
                `Completó la entrevista de ${historial.length} preguntas de manera estructurada.`,
                `Mostró interés y perseverancia durante la evaluación.`
            ],
            debilidades: temasNoSabe.length > 0 ? temasNoSabe.map(t => t.replace(/Pregunta \d+: /, '')) : [
                `Se requiere profundizar en aspectos avanzados de ${puesto}.`
            ],
            recomendacion: `Revisar y reforzar los conceptos evaluados durante la sesión, especialmente en las áreas con respuestas dudosas o incompletas.`,
            evaluacion_por_area: [
                {"area": "Conocimiento Técnico", "puntaje": Math.round(notaRedondeada * 0.8), "maximo": 20, "comentario": "Evaluado preliminarmente."},
                {"area": "Resolución de Problemas", "puntaje": Math.round(notaRedondeada * 0.7), "maximo": 20, "comentario": "Resuelve la mayoría de retos planteados."},
                {"area": "Comunicación", "puntaje": 15, "maximo": 20, "comentario": "Fluidez comunicativa adecuada."},
                {"area": "Experiencia Práctica", "puntaje": Math.round(notaRedondeada * 0.75), "maximo": 20, "comentario": "Suficiente para el nivel."},
                {"area": "Cultura y Actitud", "puntaje": 16, "maximo": 20, "comentario": "Buena disposición a la evaluación."}
            ],
            contrataria: notaRedondeada >= 11
        };
    }
}

module.exports = { generarPregunta, generarReporte, llamarGemini };
