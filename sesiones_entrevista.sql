-- ============================================================
-- TABLA: sesiones_entrevista
-- Ejecuta este SQL en tu base de datos MySQL
-- ============================================================

CREATE TABLE IF NOT EXISTS sesiones_entrevista (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id  INT NOT NULL,
    puesto      VARCHAR(255) NOT NULL,
    nivel       ENUM('Junior', 'Mid', 'Senior') NOT NULL DEFAULT 'Mid',
    historial   JSON NOT NULL,
    nota_final  DECIMAL(4,1) DEFAULT NULL,
    reporte     JSON DEFAULT NULL,
    estado      ENUM('en_curso', 'completada') DEFAULT 'en_curso',
    fecha       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
