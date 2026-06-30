-- --------------------------------------------------------
-- Host:                         0c5ena.h.filess.io
-- Versión del servidor:         11.6.2-MariaDB-ubu2404 - mariadb.org binary distribution
-- SO del servidor:              debian-linux-gnu
-- HeidiSQL Versión:             12.17.0.7270
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para simulador_db_highwaydid
CREATE DATABASE IF NOT EXISTS `simulador_db_highwaydid` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `simulador_db_highwaydid`;

-- Volcando estructura para tabla simulador_db_highwaydid.bancos
CREATE TABLE IF NOT EXISTS `bancos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `categoria` varchar(50) DEFAULT NULL,
  `autor_id` int(11) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `autor_id` (`autor_id`),
  CONSTRAINT `bancos_ibfk_1` FOREIGN KEY (`autor_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.bancos: ~8 rows (aproximadamente)
INSERT INTO `bancos` (`id`, `titulo`, `descripcion`, `categoria`, `autor_id`, `fecha_creacion`) VALUES
	(1, 'JavaScript Avanzado', 'Preguntas sobre closures, promesas, event loop y patrones modernos de JS.', 'Programación', 1, '2026-04-12 03:21:52'),
	(2, 'SQL y Bases de Datos', 'Consultas SQL, optimización, índices, transacciones y modelado relacional.', 'Bases de Datos', 1, '2026-04-12 03:21:52'),
	(3, 'Python para Backend', 'Decoradores, OOP, manejo de errores, librerías y buenas prácticas en Python.', 'Programación', 2, '2026-04-12 03:21:52'),
	(4, 'Algoritmos y Estructuras', 'Complejidad algorítmica, ordenamiento, búsqueda, grafos y estructuras de datos.', 'Algoritmos', 2, '2026-04-12 03:21:52'),
	(5, 'HTML, CSS y Frontend', 'Responsive design, flexbox, grid, accesibilidad y rendimiento web.', 'Frontend', 3, '2026-04-12 03:21:52'),
	(6, 'Git y DevOps', 'Control de versiones, ramas, CI/CD, Docker y flujos de trabajo profesionales.', 'DevOps', 3, '2026-04-12 03:21:52'),
	(7, 'GAA', 'GAA', 'GAA', 6, '2026-04-29 05:37:59'),
	(8, 'A', 'A', 'A', 11, '2026-05-03 00:03:37');

-- Volcando estructura para tabla simulador_db_highwaydid.calificaciones
CREATE TABLE IF NOT EXISTS `calificaciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `banco_id` int(11) DEFAULT NULL,
  `estrellas` tinyint(4) NOT NULL CHECK (`estrellas` between 1 and 5),
  `comentario` text DEFAULT NULL,
  `fecha_calificacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario_id` (`usuario_id`,`banco_id`),
  KEY `banco_id` (`banco_id`),
  CONSTRAINT `calificaciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `calificaciones_ibfk_2` FOREIGN KEY (`banco_id`) REFERENCES `bancos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.calificaciones: ~15 rows (aproximadamente)
INSERT INTO `calificaciones` (`id`, `usuario_id`, `banco_id`, `estrellas`, `comentario`, `fecha_calificacion`) VALUES
	(1, 1, 3, 5, 'Excelentes preguntas de Python, muy completo para preparar entrevistas.', '2026-04-12 03:21:55'),
	(2, 1, 4, 4, 'Buenas preguntas de algoritmos, me ayudaron a repasar complejidad.', '2026-04-12 03:21:55'),
	(3, 1, 5, 5, 'Perfecto para repasar CSS antes de una entrevista frontend.', '2026-04-12 03:21:55'),
	(4, 1, 6, 4, 'Muy útil el banco de Git, cubre los temas que siempre preguntan.', '2026-04-12 03:21:55'),
	(5, 2, 1, 5, 'El banco de JavaScript está muy bien hecho, cubre closures y async.', '2026-04-12 03:21:55'),
	(6, 2, 2, 5, 'Las preguntas de SQL son muy prácticas y realistas.', '2026-04-12 03:21:55'),
	(7, 2, 4, 3, 'Bien, pero le faltan más preguntas de grafos avanzados.', '2026-04-12 03:21:55'),
	(8, 2, 6, 5, 'El banco de DevOps es justo lo que necesitaba para mi entrevista.', '2026-04-12 03:21:55'),
	(9, 3, 1, 4, 'Muy buen repaso de JavaScript moderno.', '2026-04-12 03:21:55'),
	(10, 3, 2, 5, 'SQL muy completo, incluye ACID y optimización que siempre preguntan.', '2026-04-12 03:21:55'),
	(11, 3, 3, 4, 'Python bien cubierto, especialmente decoradores y GIL.', '2026-04-12 03:21:55'),
	(12, 3, 5, 5, 'El banco de HTML/CSS es mi favorito, muy práctico.', '2026-04-12 03:21:55'),
	(13, 1, 1, 4, NULL, '2026-04-12 03:33:17'),
	(16, 5, 7, 1, NULL, '2026-04-29 05:38:36'),
	(17, 6, 2, 5, NULL, '2026-04-30 02:41:51');

-- Volcando estructura para tabla simulador_db_highwaydid.calificaciones_retos
CREATE TABLE IF NOT EXISTS `calificaciones_retos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `reto_id` int(11) DEFAULT NULL,
  `estrellas` tinyint(4) DEFAULT NULL CHECK (`estrellas` between 1 and 5),
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario_id` (`usuario_id`,`reto_id`),
  KEY `reto_id` (`reto_id`),
  CONSTRAINT `calificaciones_retos_ibfk_1` FOREIGN KEY (`reto_id`) REFERENCES `retos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.calificaciones_retos: ~1 rows (aproximadamente)
INSERT INTO `calificaciones_retos` (`id`, `usuario_id`, `reto_id`, `estrellas`) VALUES
	(1, 1, 1, 5);

-- Volcando estructura para tabla simulador_db_highwaydid.casos_prueba
CREATE TABLE IF NOT EXISTS `casos_prueba` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reto_id` int(11) NOT NULL,
  `input` varchar(500) NOT NULL,
  `output_esperado` varchar(500) NOT NULL,
  `es_visible` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `reto_id` (`reto_id`),
  CONSTRAINT `casos_prueba_ibfk_1` FOREIGN KEY (`reto_id`) REFERENCES `retos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.casos_prueba: ~58 rows (aproximadamente)
INSERT INTO `casos_prueba` (`id`, `reto_id`, `input`, `output_esperado`, `es_visible`) VALUES
	(1, 1, '70, 1.75', '22.9', 1),
	(2, 1, '90, 1.80', '27.8', 1),
	(3, 1, '60, 1.60', '23.4', 0),
	(4, 1, '50, 1.55', '20.8', 0),
	(5, 2, '7', 'true', 1),
	(6, 2, '4', 'false', 1),
	(7, 2, '13', 'true', 0),
	(8, 2, '1', 'false', 0),
	(9, 3, '130', '"2h 10m"', 1),
	(10, 3, '60', '"1h 0m"', 1),
	(11, 3, '90', '"1h 30m"', 0),
	(12, 3, '45', '"0h 45m"', 0),
	(13, 4, '[10, 5, 20, 1]', '1', 1),
	(14, 4, '[3, 3, 3]', '3', 1),
	(15, 4, '[-5, 0, 5]', '-5', 0),
	(16, 4, '[100]', '100', 0),
	(17, 5, '"Diego Castillo"', '"DC"', 1),
	(18, 5, '"Ana Torres"', '"AT"', 1),
	(19, 5, '"Carlos Ayala"', '"CA"', 0),
	(20, 5, '"Joan Medina"', '"JM"', 0),
	(21, 6, '10', '23', 1),
	(22, 6, '20', '78', 1),
	(23, 6, '15', '45', 0),
	(24, 6, '1', '0', 0),
	(25, 7, '"roma", "amor"', 'true', 1),
	(26, 7, '"hola", "adios"', 'false', 1),
	(27, 7, '"listen", "silent"', 'true', 0),
	(28, 7, '"hello", "world"', 'false', 0),
	(29, 8, '" U P T "', '"UPT"', 1),
	(30, 8, '"hola mundo"', '"holamundo"', 1),
	(31, 8, '"  espacios  "', '"espacios"', 0),
	(32, 8, '"sinEspacios"', '"sinEspacios"', 0),
	(33, 9, '2024', 'true', 1),
	(34, 9, '1900', 'false', 1),
	(35, 9, '2000', 'true', 0),
	(36, 9, '2023', 'false', 0),
	(37, 10, '2, 3', '8', 1),
	(38, 10, '5, 0', '1', 1),
	(39, 10, '3, 4', '81', 0),
	(40, 10, '10, 2', '100', 0),
	(41, 11, '"Bienvenidos a la UPT"', '4', 1),
	(42, 11, '"Hola"', '1', 1),
	(43, 11, '"uno dos tres"', '3', 0),
	(44, 11, '"   espacios   "', '1', 0),
	(45, 12, '[1, 2, 3]', '[3, 2, 1]', 1),
	(46, 12, '[5]', '[5]', 1),
	(47, 12, '[10, 20, 30, 40]', '[40, 30, 20, 10]', 0),
	(48, 12, '[]', '[]', 0),
	(49, 13, '"ana"', '"true"', 1),
	(50, 13, '"Hola"', '"false"', 0),
	(51, 14, '2, 3', '5', 1),
	(52, 14, '-1, 5', '4', 1),
	(53, 15, '2, 3', '5', 1),
	(54, 15, '-1, 5', '4', 0),
	(55, 16, '6', 'true', 1),
	(56, 16, '12', 'false', 0),
	(57, 17, 'GA', 'GA', 1),
	(58, 17, 'GA', 'GA', 0);

-- Volcando estructura para tabla simulador_db_highwaydid.intentos
CREATE TABLE IF NOT EXISTS `intentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `banco_id` int(11) NOT NULL,
  `puntaje` int(11) NOT NULL,
  `total` int(11) NOT NULL,
  `tiempo_segundos` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `banco_id` (`banco_id`),
  CONSTRAINT `intentos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `intentos_ibfk_2` FOREIGN KEY (`banco_id`) REFERENCES `bancos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.intentos: ~4 rows (aproximadamente)
INSERT INTO `intentos` (`id`, `usuario_id`, `banco_id`, `puntaje`, `total`, `tiempo_segundos`, `fecha`) VALUES
	(1, 1, 1, 1, 10, 11, '2026-04-12 04:21:48'),
	(2, 1, 2, 2, 10, 28, '2026-04-13 21:14:14'),
	(3, 5, 1, 6, 10, 13, '2026-04-29 05:36:31'),
	(4, 5, 7, 1, 1, 2, '2026-04-29 05:38:31');

-- Volcando estructura para tabla simulador_db_highwaydid.intentos_retos
CREATE TABLE IF NOT EXISTS `intentos_retos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `reto_id` int(11) NOT NULL,
  `codigo_enviado` text NOT NULL,
  `resultado` enum('Exitoso','Fallido') NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `reto_id` (`reto_id`),
  CONSTRAINT `intentos_retos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `intentos_retos_ibfk_2` FOREIGN KEY (`reto_id`) REFERENCES `retos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.intentos_retos: ~117 rows (aproximadamente)
INSERT INTO `intentos_retos` (`id`, `usuario_id`, `reto_id`, `codigo_enviado`, `resultado`, `fecha`) VALUES
	(1, 1, 1, 'function solucion(n) { return 30; }', 'Exitoso', '2026-04-15 05:05:46'),
	(2, 1, 2, 'function solucion(t) { return "aloh"; }', 'Exitoso', '2026-04-15 05:05:46'),
	(3, 2, 1, 'function solucion(n) { return 0; }', 'Fallido', '2026-04-15 05:05:46'),
	(4, 3, 3, 'function solucion(c) { return 6; }', 'Exitoso', '2026-04-15 05:05:46'),
	(5, 4, 5, 'function solucion(p) { return true; }', 'Exitoso', '2026-04-15 05:05:46'),
	(6, 1, 1, 'function solucion(peso, altura) {\n  // IMC = peso / (altura * altura)\n}', 'Fallido', '2026-04-15 05:16:37'),
	(7, 1, 1, 'function solucion(peso, altura) {\n  // IMC = peso / (altura * altura)\n  let imc = peso / (altura * altura);\n  return imc;\n}', 'Fallido', '2026-04-15 05:17:13'),
	(8, 1, 1, 'function solucion(peso, altura) {\n  let imc = peso / (altura * altura);\n  return parseFloat(imc.toFixed(1));\n}', 'Exitoso', '2026-04-15 05:17:27'),
	(9, 1, 1, 'function solucion(peso, altura) {\n  let imc = peso / (altura * altura);\n  return parseFloat(imc.toFixed(1));\n}', 'Exitoso', '2026-04-15 05:37:53'),
	(10, 1, 1, 'function solucion(peso, altura) {\n  // IMC = peso / (altura * altura)\n}d', 'Fallido', '2026-04-15 05:38:09'),
	(11, 1, 1, 'function solucion(peso, altura) {\n  // IMC = peso / (altura * altura)\n}dasdd', 'Fallido', '2026-04-15 05:38:12'),
	(12, 1, 1, 'function solucion(peso, altura) {\n  let imc = peso / (altura * altura);\n  return parseFloat(imc.toFixed(1));\n}', 'Exitoso', '2026-04-15 05:39:39'),
	(13, 1, 3, 'function solucion(min) {\n  // Ejemplo: 130 -> "2h 10m"\n}dasd', 'Fallido', '2026-04-15 05:42:28'),
	(14, 1, 3, 'function solucion(min) {\n  let horas = Math.floor(min / 60);\n  let minutos = min % 60;\n  return `${horas}h ${minutos}m`;\n}', 'Exitoso', '2026-04-15 05:43:00'),
	(15, 1, 13, 'public class Main {\n    public static String solucion(String texto) {\n        texto = texto.toLowerCase();\n        String invertido = new StringBuilder(texto).reverse().toString();\n        \n        if (texto.equals(invertido)) {\n            return "true";\n        } else {\n            return "false";\n        }\n    }\n}', 'Fallido', '2026-04-15 05:54:27'),
	(16, 1, 13, 'String solucion(String texto) {\n    texto = texto.toLowerCase();\n    String invertido = new StringBuilder(texto).reverse().toString();\n    \n    if (texto.equals(invertido)) {\n        return "true";\n    } else {\n        return "false";\n    }\n}', 'Fallido', '2026-04-15 05:54:50'),
	(17, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  let invertido = texto.split(\'\').reverse().join(\'\');\n  \n  if (texto === invertido) {\n    return "true";\n  } else {\n    return "false";\n  }\n}', 'Fallido', '2026-04-15 05:55:12'),
	(18, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  let invertido = texto.split(\'\').reverse().join(\'\');\n  \n  if (texto === invertido) {\n    return \'Output: "true"\';\n  } else {\n    return \'Output: "false"\';\n  }\n}', 'Fallido', '2026-04-15 05:55:31'),
	(19, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  let invertido = texto.split(\'\').reverse().join(\'\');\n  \n  if (texto === invertido) {\n    return \'Output: "true"\';\n  } else {\n    return \'Output: "false"\';\n  }\n}', 'Fallido', '2026-04-15 05:55:33'),
	(20, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  let invertido = texto.split(\'\').reverse().join(\'\');\n  \n  if (texto === invertido) {\n    return \'Output: "true"\';\n  } else {\n    return \'Output: "false"\';\n  }\n}', 'Fallido', '2026-04-15 05:55:37'),
	(21, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  \n  for (let i = 0; i < texto.length / 2; i++) {\n    if (texto[i] !== texto[texto.length - 1 - i]) {\n      return "false";\n    }\n  }\n  \n  return "true";\n}', 'Fallido', '2026-04-15 05:56:10'),
	(22, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  \n  for (let i = 0; i < texto.length / 2; i++) {\n    if (texto[i] !== texto[texto.length - 1 - i]) {\n      return "false";\n    }\n  }\n  \n  return "true";\n}', 'Fallido', '2026-04-15 05:56:12'),
	(23, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  \n  for (let i = 0; i < texto.length / 2; i++) {\n    if (texto[i] !== texto[texto.length - 1 - i]) {\n      return "false";\n    }\n  }\n  \n  return "true";\n}', 'Fallido', '2026-04-15 05:56:16'),
	(24, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  \n  for (let i = 0; i < texto.length / 2; i++) {\n    if (texto[i] !== texto[texto.length - 1 - i]) {\n      return "false";\n    }\n  }\n  \n  return "true";\n}', 'Fallido', '2026-04-15 05:57:57'),
	(25, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  \n  for (let i = 0; i < texto.length / 2; i++) {\n    if (texto[i] !== texto[texto.length - 1 - i]) {\n      return "false";\n    }\n  }\n  \n  return "true";\n}', 'Exitoso', '2026-04-15 05:58:19'),
	(26, 1, 13, 'function solucion(texto) {\n  texto = texto.toLowerCase();\n  \n  for (let i = 0; i < texto.length / 2; i++) {\n    if (texto[i] !== texto[texto.length - 1 - i]) {\n      return "false";\n    }\n  }\n  \n  return "true";\n}', 'Exitoso', '2026-04-15 05:58:26'),
	(27, 1, 14, 'int solucion(int a, int b) {\n  // Tu lógica aquí\n}', 'Fallido', '2026-04-15 06:10:10'),
	(28, 1, 14, 'int solucion(int a, int b) {\n    return a + b;\n}', 'Fallido', '2026-04-15 06:10:21'),
	(29, 1, 14, 'int solucion(int a, int b) {\n    return a + b;\n}', 'Fallido', '2026-04-15 06:10:31'),
	(30, 1, 14, 'function solucion(a, b) {\n  return a + b;\n}', 'Exitoso', '2026-04-15 06:10:47'),
	(31, 1, 13, 'public static String esPalindromo(String cadena) {\n    String invertida = new StringBuilder(cadena).reverse().toString();\n    return String.valueOf(cadena.equals(invertida));\n}', 'Fallido', '2026-04-18 17:32:58'),
	(32, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 17:55:52'),
	(33, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 17:56:28'),
	(34, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 17:56:33'),
	(35, 1, 15, 'def solucion(a, b):\n    # Tu lógica aquíasdad', 'Fallido', '2026-04-18 17:56:51'),
	(36, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:01:29'),
	(37, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:02:41'),
	(38, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:02:41'),
	(39, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:02:42'),
	(40, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:02:42'),
	(41, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:02:42'),
	(42, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:02:43'),
	(43, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:02'),
	(44, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:03'),
	(45, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:04'),
	(46, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:04'),
	(47, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:09'),
	(48, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:09'),
	(49, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:09'),
	(50, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:09'),
	(51, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:06:09'),
	(52, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:09:34'),
	(53, 1, 15, 'def solucion(a, b):\n    # Tu lógica aquí', 'Fallido', '2026-04-18 18:09:46'),
	(54, 1, 15, 'def solucion(a, b):\n    # Tu lógica aquí', 'Fallido', '2026-04-18 18:09:52'),
	(55, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:14:04'),
	(56, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:16:35'),
	(57, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:16:56'),
	(58, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:18:53'),
	(59, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:19:29'),
	(60, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:23:37'),
	(61, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:25:32'),
	(62, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:26:07'),
	(63, 1, 15, 'def solucion(a, b):\n    return a + b', 'Fallido', '2026-04-18 18:28:09'),
	(64, 1, 15, 'def solucion(a, b):\n    return a + bDASDASD', 'Fallido', '2026-04-18 18:28:37'),
	(65, 1, 15, 'def solucion(a, b):\n    return a + bDASDASD', 'Fallido', '2026-04-18 18:28:53'),
	(66, 1, 13, 'public static String esPalindromo(String cadena) {\n    String invertida = new StringBuilder(cadena).reverse().toString();\n    return String.valueOf(cadena.equals(invertida));\n}', 'Fallido', '2026-04-18 18:31:49'),
	(67, 1, 13, 'import java.util.Scanner;\npublic class Main {\n    [CÓDIGO DEL USUARIO AQUÍ]\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        String input = sc.nextLine();\n        System.out.println(solucion(input));\n    }\n}', 'Fallido', '2026-04-18 18:32:32'),
	(68, 1, 13, 'import java.util.Scanner;\npublic class Main {\n    [CÓDIGO DEL USUARIO AQUÍ]\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        String input = sc.nextLine();\n        System.out.println(solucion(input));\n    }\n}', 'Fallido', '2026-04-18 18:32:41'),
	(69, 1, 13, 'import java.util.Scanner;\npublic class Main {\n    [CÓDIGO DEL USUARIO AQUÍ]\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        String input = sc.nextLine();\n        System.out.println(solucion(input));\n    }\n}', 'Fallido', '2026-04-18 18:34:18'),
	(70, 1, 13, 'import java.util.Scanner;\npublic class Main {\n    [CÓDIGO DEL USUARIO AQUÍ]\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        String input = sc.nextLine();\n        System.out.println(solucion(input));\n    }\n}', 'Fallido', '2026-04-18 18:37:15'),
	(71, 1, 13, 'public static String solucion(String cadena) {\n    String invertida = new StringBuilder(cadena).reverse().toString();\n    return String.valueOf(cadena.equals(invertida));\n}', 'Fallido', '2026-04-18 18:39:25'),
	(72, 1, 13, 'public static String solucion(String cadena) {\n    String invertida = new StringBuilder(cadena).reverse().toString();\n    return String.valueOf(cadena.equals(invertida));\n}', 'Fallido', '2026-04-18 18:41:20'),
	(73, 1, 13, 'public static String solucion(String cadena) {\n    String invertida = new StringBuilder(cadena).reverse().toString();\n    return String.valueOf(cadena.equals(invertida));\n}', 'Exitoso', '2026-04-18 18:46:06'),
	(74, 4, 13, 'public static String solucion(String cadena) {\n    return "hola";\n}', 'Fallido', '2026-04-18 18:48:59'),
	(75, 4, 13, 'public static String solucion(String cadena) {\n    String invertida = new StringBuilder(cadena).reverse().toString();\n    return String.valueOf(cadena.equals(invertida));\n}', 'Exitoso', '2026-04-18 18:49:25'),
	(76, 4, 15, 'def solucion(a, b):\n    return a - b', 'Fallido', '2026-04-18 18:50:26'),
	(77, 4, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-18 18:50:39'),
	(78, 1, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-26 23:42:45'),
	(79, 1, 15, 'def solucion(a, b):\n    # Tu lógica aquísdsada', 'Fallido', '2026-04-26 23:43:25'),
	(80, 1, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-26 23:43:45'),
	(81, 1, 15, 'def solucion(a, b):\n    # Tu lógica aquí', 'Fallido', '2026-04-26 23:44:02'),
	(82, 1, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-26 23:44:19'),
	(83, 1, 16, 'int solucion(int n) {\n  int suma = 0;\n  for (int i = 1; i <= n/2; i++) {\n    if (n % i == 0) suma += i;\n  }\n  return suma == n;\n}', 'Fallido', '2026-04-27 01:11:58'),
	(84, 1, 16, '#include <iostream>\nusing namespace std;\n[CÓDIGO DEL USUARIO]\nint main() {\n    int n;\n    cin >> n;\n    cout << (solucion(n) ? "true" : "false") << endl;\n    return 0;\n}', 'Fallido', '2026-04-27 01:12:45'),
	(85, 1, 16, 'int solucion(int n) {\n  int suma = 0;\n  for (int i = 1; i <= n/2; i++) {\n    if (n % i == 0) suma += i;\n  }\n  return suma == n;\n}', 'Fallido', '2026-04-27 01:30:59'),
	(86, 1, 16, 'int solucion(int n) {\n  int suma = 0;\n  for (int i = 1; i <= n/2; i++) {\n    if (n % i == 0) suma += i;\n  }\n  return suma == n;\n}', 'Exitoso', '2026-04-27 01:32:16'),
	(87, 1, 16, 'int solucion(int n) {\n  int suma = 0;\n  for (int i = 1; i <= n/2; i++) {\n    if (n % i == 0) suma += i;\n  }\n  return suma == n;\n}', 'Exitoso', '2026-04-27 01:32:46'),
	(88, 1, 1, 'function solucion(peso, altura) {\n  // IMC = peso / (altura * altura)\n}', 'Fallido', '2026-04-27 18:34:39'),
	(89, 5, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-29 05:39:50'),
	(90, 5, 17, 'GA', 'Fallido', '2026-04-29 05:41:56'),
	(91, 7, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-29 06:08:36'),
	(92, 6, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-29 06:28:51'),
	(93, 6, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-29 06:29:06'),
	(94, 5, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-29 06:36:18'),
	(95, 6, 1, 'function solucion(peso, altura) {\n  // IMC = peso / (altura * altura)\n}', 'Fallido', '2026-04-29 21:50:14'),
	(96, 6, 14, 'int solucion(int a, int b) {\n  // Tu lógica aquí\n  return a + b;\n\n}', 'Fallido', '2026-04-29 21:51:05'),
	(97, 6, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-29 21:52:38'),
	(98, 6, 14, 'int solucion(int a, int b) {\n  // Tu lógica aquí\n  return a + b;\n}', 'Fallido', '2026-04-29 21:53:24'),
	(99, 6, 14, '#include<iostream>\n\nusing namespace std;\n\nint solucion(int a, int b) {\n  // Tu lógica aquí\nreturn a + b;\n}\n\nint main(){\ncout >> solucion(1+2);\nreturn 0;\n}', 'Fallido', '2026-04-29 21:55:13'),
	(100, 6, 13, 'public class Main {\n    public static String esPalindromo(String texto) {\n        String limpio = texto.toLowerCase().replaceAll("[^a-z0-9]", "");\n        String invertido = new StringBuilder(limpio).reverse().toString();\n        return String.valueOf(limpio.equals(invertido));\n    }\n\n    public static void main(String[] args) {\n        System.out.println(esPalindromo("ana"));      // true\n        System.out.println(esPalindromo("hello"));    // false\n        System.out.println(esPalindromo("reconocer")); // true\n    }\n}', 'Fallido', '2026-04-29 21:56:07'),
	(101, 6, 13, 'public static String solucion(String texto) {\n    String limpio = texto.toLowerCase().replaceAll("[^a-z0-9]", "");\n    String invertido = new StringBuilder(limpio).reverse().toString();\n    return String.valueOf(limpio.equals(invertido));\n}', 'Exitoso', '2026-04-29 21:56:25'),
	(102, 6, 13, 'public static String solucion(String texto) {\n    String limpio = texto.toLowerCase().replaceAll("[^a-z0-9]", "");\n    String invertido = new StringBuilder(limpio).reverse().toString();\n    return String.valueOf(limpio.equals(invertido));\n}\n', 'Exitoso', '2026-04-30 02:29:58'),
	(103, 8, 1, 'function solucion(peso, altura) {\n\n\n  IMC = peso / (altura * altura)\n}', 'Fallido', '2026-04-30 02:30:04'),
	(104, 8, 1, 'function solucion(peso, altura) {\n\n\n  IMC = peso / (altura * altura)\n  return IMC\n\n}', 'Fallido', '2026-04-30 02:30:26'),
	(105, 8, 1, 'function solucion(peso, altura) {\n\n\n  int IMC = peso / (altura * altura)\n  return IMC\n\n}', 'Fallido', '2026-04-30 02:30:41'),
	(106, 8, 1, 'function solucion(peso, altura) {\n\n\n  int IMC = peso / (altura * altura)\n  return IMC\n\n}', 'Fallido', '2026-04-30 02:30:52'),
	(107, 8, 1, 'function solucion(peso, altura) {\n\n\n  IMC = peso / (altura * altura)\n  return IMC\n\n}', 'Fallido', '2026-04-30 02:31:02'),
	(108, 8, 1, 'function solucion(peso, altura) {\n\n\n  IMC = peso / (altura * altura)\n  return MathRound(IMC)\n\n}', 'Fallido', '2026-04-30 02:31:29'),
	(109, 8, 1, 'function solucion(peso, altura) {\n\n\n  IMC = peso / (altura * altura)\n  return Math.round(IMC)\n\n}', 'Fallido', '2026-04-30 02:31:39'),
	(110, 6, 13, 'public static String solucion(String texto) {\n    String invertido = new StringBuilder(texto).reverse().toString();\n    return String.valueOf(texto == invertido);\n}', 'Fallido', '2026-04-30 02:32:16'),
	(111, 8, 1, 'function solucion(peso, altura) {\n  IMC = peso / (altura * altura)\n  return IMC.toFixed(2)\n}', 'Fallido', '2026-04-30 02:32:46'),
	(112, 6, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-04-30 02:32:53'),
	(113, 8, 1, 'function solucion(peso, altura) {\n  IMC = peso / (altura * altura)\n  return IMC\n}', 'Fallido', '2026-04-30 02:33:01'),
	(114, 8, 1, 'function solucion(peso, altura) {\n  IMC = peso / (altura * altura)\n  return IMC.toFixed(1)\n}', 'Exitoso', '2026-04-30 02:33:18'),
	(115, 6, 13, 'public static String solucion(String texto) {\n    String invertido = new StringBuilder(texto).reverse().toString();\n    return String.valueOf(texto == invertido);\n}', 'Fallido', '2026-04-30 02:38:25'),
	(116, 6, 13, 'public static String solucion(String texto) {\n    String limpio = texto.toLowerCase().replaceAll("[^a-z0-9]", "");\n    String invertido = new StringBuilder(limpio).reverse().toString();\n    return String.valueOf(limpio.equals(invertido));\n}', 'Exitoso', '2026-04-30 02:38:39'),
	(117, 6, 15, 'def solucion(a, b):\n    # Tu lógica aquí\n return a + b', 'Exitoso', '2026-04-30 02:39:12');

-- Volcando estructura para tabla simulador_db_highwaydid.preguntas
CREATE TABLE IF NOT EXISTS `preguntas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `banco_id` int(11) DEFAULT NULL,
  `enunciado` text NOT NULL,
  `opcion_a` varchar(255) NOT NULL,
  `opcion_b` varchar(255) NOT NULL,
  `opcion_c` varchar(255) DEFAULT NULL,
  `opcion_d` varchar(255) DEFAULT NULL,
  `opcion_e` varchar(255) DEFAULT NULL,
  `opcion_f` varchar(255) DEFAULT NULL,
  `respuesta_correcta` char(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `banco_id` (`banco_id`),
  CONSTRAINT `preguntas_ibfk_1` FOREIGN KEY (`banco_id`) REFERENCES `bancos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.preguntas: ~62 rows (aproximadamente)
INSERT INTO `preguntas` (`id`, `banco_id`, `enunciado`, `opcion_a`, `opcion_b`, `opcion_c`, `opcion_d`, `opcion_e`, `opcion_f`, `respuesta_correcta`) VALUES
	(1, 1, '¿Qué es un closure en JavaScript?', 'Una función sin parámetros', 'Una función que recuerda el scope donde fue creada aunque ese scope ya no esté activo', 'Un método especial de los arrays', 'Una variable global compartida entre funciones', NULL, NULL, 'B'),
	(2, 1, '¿Cuál es la salida de: console.log(typeof null)?', '"null"', '"undefined"', '"object"', '"string"', NULL, NULL, 'C'),
	(3, 1, '¿Qué hace Promise.all()?', 'Ejecuta promesas en secuencia una por una', 'Espera a que todas las promesas resuelvan; rechaza si alguna falla', 'Devuelve solo la primera promesa que resuelva', 'Ignora los rechazos y devuelve las que resuelven', NULL, NULL, 'B'),
	(4, 1, '¿Cuál es la diferencia entre var, let y const?', 'No hay diferencia funcional', 'var tiene scope de función y hoisting; let y const tienen scope de bloque', 'const no puede usarse en loops', 'let y var son idénticos', NULL, NULL, 'B'),
	(5, 1, '¿Qué es el Event Loop en JavaScript?', 'Un bucle for especial para eventos del DOM', 'Una librería de manejo de eventos', 'El mecanismo que permite ejecutar código asíncrono en un entorno de un solo hilo', 'La cola de microtareas del navegador', NULL, NULL, 'C'),
	(6, 1, '¿Qué devuelve [1,2,3].map(x => x * 2).filter(x => x > 3)?', '[4, 6]', '[2, 4, 6]', '[6]', '[4]', NULL, NULL, 'A'),
	(7, 1, '¿Qué es el operador spread (...) en JS?', 'Multiplica los elementos de un array', 'Expande un iterable en sus elementos individuales', 'Crea una copia profunda de un objeto', 'Elimina duplicados de un array', NULL, NULL, 'B'),
	(8, 1, '¿Cuál es la diferencia entre == y ===?', 'No hay diferencia práctica', '=== es más lento', '== realiza coerción de tipos; === compara tipo y valor sin coerción', '== solo funciona con strings', NULL, NULL, 'C'),
	(9, 1, '¿Qué es async/await en JavaScript?', 'Una nueva sintaxis para crear clases', 'Sintaxis que permite escribir código asíncrono de forma síncrona usando Promesas', 'Un reemplazo de los callbacks que no usa Promesas', 'Solo funciona en Node.js, no en navegadores', NULL, NULL, 'B'),
	(10, 1, '¿Qué hace Object.freeze()?', 'Congela la ejecución del programa', 'Convierte un objeto a JSON', 'Impide añadir, eliminar o modificar propiedades de un objeto', 'Hace una copia profunda del objeto', NULL, NULL, 'C'),
	(11, 2, '¿Qué diferencia hay entre INNER JOIN y LEFT JOIN?', 'Son equivalentes en resultado', 'INNER JOIN devuelve solo filas con coincidencia en ambas tablas; LEFT JOIN devuelve todas las de la izquierda', 'LEFT JOIN es más rápido siempre', 'INNER JOIN incluye NULLs automáticamente', NULL, NULL, 'B'),
	(12, 2, '¿Qué hace la cláusula GROUP BY?', 'Ordena los resultados por una columna', 'Filtra filas duplicadas de la consulta', 'Agrupa filas con el mismo valor para aplicar funciones de agregación', 'Limita la cantidad de resultados', NULL, NULL, 'C'),
	(13, 2, '¿Cuál es la diferencia entre DELETE y TRUNCATE?', 'No hay diferencia', 'DELETE puede filtrar filas con WHERE y es DML; TRUNCATE elimina todo sin WHERE y es DDL', 'TRUNCATE es más lento', 'DELETE no se puede deshacer con ROLLBACK', NULL, NULL, 'B'),
	(14, 2, '¿Qué es un índice en una base de datos?', 'Una clave foránea especial', 'Una vista de la tabla principal', 'Estructura que acelera búsquedas a costa de mayor espacio en disco', 'Un tipo de constraint de unicidad', NULL, NULL, 'C'),
	(15, 2, '¿Qué significan las propiedades ACID?', 'Atomicidad, Concurrencia, Integridad, Durabilidad', 'Atomicidad, Consistencia, Aislamiento, Durabilidad', 'Acceso, Control, Índice, Datos', 'Asincronía, Consistencia, Integración, Disponibilidad', NULL, NULL, 'B'),
	(16, 2, '¿Cuándo usarías HAVING en lugar de WHERE?', 'Cuando quieres filtrar antes del JOIN', 'HAVING filtra sobre grupos creados por GROUP BY; WHERE filtra filas antes de agrupar', 'Son intercambiables', 'HAVING solo funciona con COUNT()', NULL, NULL, 'B'),
	(17, 2, '¿Qué es una subconsulta correlacionada?', 'Una consulta que se ejecuta antes del FROM', 'Una subconsulta que referencia columnas de la consulta exterior y se ejecuta por cada fila', 'Un JOIN escrito como subconsulta', 'Una vista temporal sin nombre', NULL, NULL, 'B'),
	(18, 2, '¿Qué hace el índice UNIQUE?', 'Acelera las búsquedas igual que un índice normal', 'Garantiza que no haya valores duplicados en la columna indexada', 'Crea una clave primaria automáticamente', 'Solo funciona con columnas de tipo VARCHAR', NULL, NULL, 'B'),
	(19, 2, '¿Qué es una vista (VIEW) en SQL?', 'Una copia física de una tabla', 'Un procedimiento almacenado sin parámetros', 'Una consulta almacenada que se puede tratar como tabla virtual', 'Un tipo especial de índice', NULL, NULL, 'C'),
	(20, 2, '¿Qué diferencia hay entre UNION y UNION ALL?', 'Son idénticos en resultado', 'UNION elimina duplicados; UNION ALL incluye todos los resultados incluyendo duplicados', 'UNION ALL es más lento', 'UNION solo funciona con dos tablas', NULL, NULL, 'B'),
	(21, 3, '¿Qué es un decorador en Python?', 'Un tipo especial de variable', 'Una función que envuelve y extiende el comportamiento de otra función sin modificarla', 'Un módulo de diseño visual', 'Una clase abstracta', NULL, NULL, 'B'),
	(22, 3, '¿Cuál es la diferencia entre list y tuple?', 'No hay diferencia práctica', 'Las listas son mutables; las tuplas son inmutables', 'Las tuplas permiten duplicados; las listas no', 'Solo las listas soportan índices', NULL, NULL, 'B'),
	(23, 3, '¿Qué es el GIL en CPython?', 'Un gestor de paquetes alternativo a pip', 'Global Interpreter Lock: mutex que impide ejecutar bytecodes Python en paralelo real', 'Una librería de concurrencia', 'Un tipo de excepción del sistema', NULL, NULL, 'B'),
	(24, 3, '¿Qué hace __init__ en una clase Python?', 'Destruye la instancia al terminar', 'Define métodos de clase estáticos', 'Es el constructor: se llama al crear una instancia e inicializa sus atributos', 'Hereda automáticamente de object', NULL, NULL, 'C'),
	(25, 3, '¿Cuál es la diferencia entre is y == en Python?', 'Son completamente equivalentes', 'is compara identidad de objeto en memoria; == compara valores', '== es más estricto que is', 'is solo funciona con None y True/False', NULL, NULL, 'B'),
	(26, 3, '¿Qué es un generador en Python?', 'Una función que retorna una lista completa', 'Una clase que genera números aleatorios', 'Una función que usa yield para devolver valores uno a uno sin cargar todo en memoria', 'Un tipo especial de diccionario', NULL, NULL, 'C'),
	(27, 3, '¿Qué hace el método __str__ en una clase?', 'Convierte la clase a bytes', 'Define la representación legible del objeto al usar print() o str()', 'Inicializa los atributos de cadena', 'Es un método privado para uso interno', NULL, NULL, 'B'),
	(28, 3, '¿Qué es la herencia múltiple en Python?', 'No existe en Python', 'Heredar de una sola clase base', 'Una clase puede heredar de varias clases padre al mismo tiempo', 'Usar mixins externos', NULL, NULL, 'C'),
	(29, 3, '¿Para qué sirve el bloque try/except/finally?', 'Solo para capturar errores de sintaxis', 'Manejar excepciones; finally siempre se ejecuta sin importar si hubo error', 'Reemplazar los if/else en validaciones', 'Funciona igual que un assert', NULL, NULL, 'B'),
	(30, 3, '¿Qué es un context manager (with statement) en Python?', 'Un gestor de paquetes de entornos virtuales', 'Un patrón que garantiza la liberación de recursos automáticamente', 'Una forma de crear loops controlados', 'Un tipo de decorador de clase', NULL, NULL, 'B'),
	(31, 4, '¿Cuál es la complejidad temporal de Binary Search?', 'O(n)', 'O(n²)', 'O(log n)', 'O(1)', NULL, NULL, 'C'),
	(32, 4, '¿Qué estructura de datos usa LIFO?', 'Queue (cola)', 'Stack (pila)', 'Linked List', 'Binary Tree', NULL, NULL, 'B'),
	(33, 4, '¿Cuál es la diferencia entre BFS y DFS?', 'Son el mismo algoritmo con distinto nombre', 'BFS explora por niveles usando una cola; DFS profundiza usando una pila o recursión', 'DFS siempre encuentra el camino más corto', 'BFS solo funciona en grafos sin ciclos', NULL, NULL, 'B'),
	(34, 4, '¿Qué complejidad tiene insertar al final de un array dinámico?', 'O(n) siempre', 'O(log n)', 'O(1) amortizado', 'O(n²)', NULL, NULL, 'C'),
	(35, 4, '¿Qué es una tabla hash (HashMap)?', 'Un árbol binario de búsqueda', 'Estructura que mapea claves a valores usando una función hash para acceso O(1) promedio', 'Una lista doblemente enlazada', 'Un tipo de grafo dirigido', NULL, NULL, 'B'),
	(36, 4, '¿Qué algoritmo de ordenamiento tiene complejidad O(n log n) en el caso promedio?', 'Bubble Sort', 'Insertion Sort', 'Selection Sort', 'Quick Sort', NULL, NULL, 'D'),
	(37, 4, '¿Qué es la recursión en programación?', 'Un bucle que itera sobre arrays', 'Cuando una función se llama a sí misma con un caso base para detenerse', 'Un tipo de puntero a funciones', 'Una forma de herencia en OOP', NULL, NULL, 'B'),
	(38, 4, '¿Qué es un árbol binario de búsqueda (BST)?', 'Un árbol donde cada nodo tiene exactamente dos hijos', 'Un árbol donde el hijo izquierdo es menor y el derecho es mayor que el padre', 'Una lista enlazada con dos punteros', 'Un grafo sin ciclos y con pesos', NULL, NULL, 'B'),
	(39, 4, '¿Cuál es la complejidad de buscar en una lista enlazada?', 'O(1)', 'O(log n)', 'O(n)', 'O(n log n)', NULL, NULL, 'C'),
	(40, 4, '¿Qué es la notación Big O?', 'El tiempo exacto en milisegundos que tarda un algoritmo', 'Una notación que describe el comportamiento del tiempo/espacio de un algoritmo en el peor caso', 'La cantidad de memoria RAM usada', 'El número de líneas de código de un algoritmo', NULL, NULL, 'B'),
	(41, 5, '¿Qué es el Box Model en CSS?', 'Un framework de diseño', 'Modelo que describe el espacio de un elemento: content, padding, border y margin', 'La especificidad de los selectores CSS', 'Un tipo de layout de flexbox', NULL, NULL, 'B'),
	(42, 5, '¿Cuál es la diferencia entre display:block e display:inline?', 'No hay diferencia visual', 'block ocupa todo el ancho disponible; inline solo ocupa el espacio de su contenido', 'inline permite establecer width y height', 'block no puede tener padding', NULL, NULL, 'B'),
	(43, 5, '¿Qué propiedad CSS activa el modelo Flexbox?', 'flex: 1', 'position: flex', 'display: flex', 'layout: flexbox', NULL, NULL, 'C'),
	(44, 5, '¿Qué es position:sticky en CSS?', 'Es equivalente a position:fixed', 'El elemento se posiciona relativo a su contenedor siempre', 'El elemento fluye normalmente hasta cruzar un umbral, luego se fija como fixed', 'Solo funciona en navegadores modernos con JavaScript activo', NULL, NULL, 'C'),
	(45, 5, '¿Qué hace la propiedad z-index?', 'Define el tamaño del elemento en píxeles', 'Controla el orden de apilamiento (eje Z) de elementos posicionados', 'Establece la transparencia del elemento', 'Solo funciona con position:absolute', NULL, NULL, 'B'),
	(46, 5, '¿Qué es CSS Grid?', 'Un sistema de diseño unidimensional para filas o columnas', 'Un sistema bidimensional de layout para filas y columnas simultáneamente', 'Un reemplazo de Flexbox para todos los casos', 'Una librería externa de CSS', NULL, NULL, 'B'),
	(47, 5, '¿Qué atributo HTML mejora la accesibilidad para lectores de pantalla?', 'data-*', 'aria-label', 'tabindex', 'role="none"', NULL, NULL, 'B'),
	(48, 5, '¿Qué es el Critical Rendering Path?', 'Una propiedad CSS de rendimiento', 'El camino crítico de peticiones de red', 'La secuencia HTML→DOM→CSSOM→Render Tree→Layout→Paint→Composite del navegador', 'Una etiqueta HTML5 de optimización', NULL, NULL, 'C'),
	(49, 5, '¿Cuál es la diferencia entre em y rem en CSS?', 'Son idénticos', 'em es relativo al elemento padre; rem es relativo al elemento raíz (html)', 'rem es relativo al viewport', 'em solo funciona para font-size', NULL, NULL, 'B'),
	(50, 5, '¿Qué hace meta name="viewport"?', 'Define el título de la página', 'Configura cómo el navegador escala y dimensiona la página en dispositivos móviles', 'Establece el idioma de la página', 'Define el charset del documento', NULL, NULL, 'B'),
	(51, 6, '¿Qué diferencia hay entre git pull y git fetch?', 'Son idénticos', 'fetch descarga cambios sin aplicarlos; pull = fetch + merge automático', 'pull es más seguro que fetch', 'fetch solo descarga la rama principal', NULL, NULL, 'B'),
	(52, 6, '¿Qué es un merge conflict?', 'Un error de sintaxis en el código', 'Ocurre cuando dos ramas modificaron las mismas líneas y Git no puede fusionarlas automáticamente', 'Cuando se intenta hacer commit sin cambios', 'Un fallo de la red al hacer push', NULL, NULL, 'B'),
	(53, 6, '¿Qué hace git rebase?', 'Elimina commits del historial', 'Es igual a git merge', 'Reaplica commits sobre una nueva base creando un historial más limpio y lineal', 'Revierte el último commit', NULL, NULL, 'C'),
	(54, 6, '¿Cuándo usarías git cherry-pick?', 'Para crear una nueva rama', 'Para aplicar un commit específico de otra rama sin fusionar toda la rama', 'Para borrar commits remotos', 'Para ver el historial de cambios', NULL, NULL, 'B'),
	(55, 6, '¿Qué es un Pull Request (PR)?', 'Una solicitud para descargar un repositorio', 'Una solicitud para que los cambios de una rama sean revisados y fusionados', 'Un comando de Git para actualizar ramas', 'Una notificación de conflictos', NULL, NULL, 'B'),
	(56, 6, '¿Qué hace git stash?', 'Elimina todos los cambios no confirmados', 'Guarda temporalmente los cambios no confirmados para limpiar el working directory', 'Crea un backup del repositorio remoto', 'Fusiona ramas automáticamente', NULL, NULL, 'B'),
	(57, 6, '¿Qué es CI/CD?', 'Un sistema de control de versiones', 'Integración Continua / Entrega Continua: automatizar builds, tests y despliegues', 'Una metodología de gestión de proyectos', 'Un tipo de contenedor Docker', NULL, NULL, 'B'),
	(58, 6, '¿Qué es Docker?', 'Una máquina virtual completa', 'Un sistema de control de versiones para contenedores', 'Plataforma para empaquetar aplicaciones en contenedores ligeros y portables', 'Un servidor web de alto rendimiento', NULL, NULL, 'C'),
	(59, 6, '¿Cuál es la diferencia entre git reset y git revert?', 'Son idénticos en resultado', 'reset mueve el HEAD (puede ser destructivo); revert crea un nuevo commit que deshace cambios', 'revert borra el historial; reset lo conserva', 'reset solo funciona en ramas locales', NULL, NULL, 'B'),
	(60, 6, '¿Qué es gitflow?', 'El comando para ver el flujo de commits', 'Una extensión de Git para gestionar releases', 'Un modelo de ramificación con ramas: main, develop, feature, release, hotfix', 'Una herramienta visual de Git', NULL, NULL, 'C'),
	(62, 7, 'GAA', 'GAA', 'GA', NULL, NULL, NULL, NULL, 'A'),
	(63, 8, '1', '1', '2', NULL, NULL, NULL, NULL, 'A');

-- Volcando estructura para tabla simulador_db_highwaydid.retos
CREATE TABLE IF NOT EXISTS `retos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) NOT NULL,
  `enunciado` text NOT NULL,
  `codigo_inicial` text DEFAULT NULL,
  `test_input` varchar(255) DEFAULT NULL,
  `test_output` varchar(255) DEFAULT NULL,
  `dificultad` enum('Fácil','Medio','Difícil') DEFAULT 'Fácil',
  `puntos` int(11) DEFAULT 10,
  `lenguaje` varchar(50) DEFAULT 'JavaScript',
  `pista` text DEFAULT NULL,
  `autor_id` int(11) DEFAULT NULL,
  `solucion` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.retos: ~17 rows (aproximadamente)
INSERT INTO `retos` (`id`, `titulo`, `enunciado`, `codigo_inicial`, `test_input`, `test_output`, `dificultad`, `puntos`, `lenguaje`, `pista`, `autor_id`, `solucion`) VALUES
	(1, 'Calculadora de IMC', 'Crea una función "solucion" que reciba el peso (kg) y la altura (m) y devuelva el Índice de Masa Corporal redondeado a 1 decimal.', 'function solucion(peso, altura) {\n  // IMC = peso / (altura * altura)\n}', '70, 1.75', '22.9', 'Fácil', 10, 'JavaScript', 'Usa la fórmula: peso / (altura * altura) y redondea con toFixed(1).', NULL, NULL),
	(2, 'Verificador de Primos', 'Escribe una función que devuelva true si un número es primo y false si no lo es.', 'function solucion(n) {\n  // Tu lógica aquí\n}', '7', 'true', 'Medio', 10, 'JavaScript', 'Itera desde 2 hasta Math.sqrt(n). Si n es divisible por alguno, no es primo.', NULL, NULL),
	(3, 'Conversor de Minutos', 'Crea una función que convierta minutos en un string de formato "Xh Ym".', 'function solucion(min) {\n  // Ejemplo: 130 -> "2h 10m"\n}', '130', '"2h 10m"', 'Medio', 10, 'JavaScript', 'Horas = Math.floor(min / 60), minutos restantes = min % 60.', NULL, NULL),
	(4, 'Encontrar el menor', 'Dada una lista de números, devuelve el menor de todos.', 'function solucion(arr) {\n  return Math.min(...arr);\n}', '[10, 5, 20, 1]', '1', 'Fácil', 10, 'JavaScript', 'Puedes usar Math.min(...arr) o iterar el array comparando valores.', NULL, NULL),
	(5, 'Generador de Iniciales', 'Recibe un nombre completo (ej: "Diego Castillo") y devuelve las iniciales en mayúsculas ("DC").', 'function solucion(nombre) {\n  // Tu código aquí\n}', '"Diego Castillo"', '"DC"', 'Fácil', 10, 'JavaScript', 'Usa split(" ") para separar palabras y toma la primera letra de cada una con [0].', NULL, NULL),
	(6, 'Suma de Múltiplos de 3 y 5', 'Suma todos los números menores a N que sean múltiplos de 3 o 5.', 'function solucion(n) {\n  // Lógica de ciclo y módulo\n}', '10', '23', 'Medio', 10, 'JavaScript', 'Usa un for de 1 a N-1 y comprueba con % 3 === 0 || % 5 === 0.', NULL, NULL),
	(7, 'Detección de Anagramas', 'Determina si dos palabras son anagramas (tienen las mismas letras).', 'function solucion(palabra1, palabra2) {\n  // Ejemplo: "roma", "amor" -> true\n}', '"roma", "amor"', 'true', 'Difícil', 10, 'JavaScript', 'Ordena las letras de ambas palabras con split("").sort().join("") y compáralas.', NULL, NULL),
	(8, 'Limpieza de Espacios', 'Elimina todos los espacios en blanco de un string.', 'function solucion(texto) {\n  // Usa replace o split/join\n}', '" U P T "', '"UPT"', 'Fácil', 10, 'JavaScript', 'Usa replace(/ /g, "") o split(" ").join("") para eliminar todos los espacios.', NULL, NULL),
	(9, 'Validar Año Bisiesto', 'Devuelve true si el año es bisiesto.', 'function solucion(anio) {\n  // Tu lógica\n}', '2024', 'true', 'Medio', 10, 'JavaScript', 'Bisiesto: divisible entre 4, excepto siglos (100) a menos que sean divisibles entre 400.', NULL, NULL),
	(10, 'Potencia de un Número', 'Calcula a elevado a la potencia b sin usar Math.pow().', 'function solucion(a, b) {\n  // Usa un ciclo\n}', '2, 3', '8', 'Medio', 10, 'JavaScript', 'Usa un for que multiplique resultado por "a" exactamente "b" veces.', NULL, NULL),
	(11, 'Contar Palabras', 'Cuenta cuántas palabras hay en una oración.', 'function solucion(oracion) {\n  // Usa split(" ")\n}', '"Bienvenidos a la UPT"', '4', 'Fácil', 10, 'JavaScript', 'Usa split(" ").length, pero cuidado con espacios extra al inicio o al final (usa trim()).', NULL, NULL),
	(12, 'Invertir Array', 'Recibe un array y devuélvelo en orden inverso.', 'function solucion(arr) {\n  // Lógica de reversa\n}', '[1, 2, 3]', '[3, 2, 1]', 'Medio', 10, 'JavaScript', 'Puedes usar arr.reverse() o un loop que recorra el array desde el final.', NULL, NULL),
	(13, 'Palíndromos en Java', 'Crea una función que reciba una cadena de texto y determine si es un palíndromo (se lee igual de izquierda a derecha que de derecha a izquierda).\r\nLa función debe devolver "true" si es palíndromo y "false" si no lo es.', 'function solucion(texto) {\n  // Tu lógica aquí\n}', '"ana"', 'true', 'Difícil', 10, 'Java', 'Convierte el texto a minúsculas y compáralo con su versión invertida usando StringBuilder.', 1, NULL),
	(14, 'Suma de Dos Números', 'Crea una función que reciba dos números enteros y devuelva su suma.', 'int solucion(int a, int b) {\r\n  // Tu lógica aquí\r\n}', '2, 3', '5', 'Fácil', 10, 'C++', 'Solo necesitas usar el operador +.', 1, NULL),
	(15, 'Suma de dos números en Python', 'Crea una función que reciba dos números y devuelva su suma.', 'def solucion(a, b):\r\n    # Tu lógica aquí', '2, 3', '5', 'Fácil', 10, 'Python', 'Usa el operador + para sumar a y b.', 1, NULL),
	(16, 'Números Perfectos', 'Un número perfecto es aquel que es igual a la suma de sus divisores propios (excluyendo el mismo número). Crea una función que reciba un número entero positivo y devuelva "true" si es perfecto y "false" si no lo es. Ejemplo: 6 es perfecto porque 1+2+3=6.', 'int solucion(int n) {\r\n  // Tu lógica aquí\r\n}', '6', 'true', 'Difícil', 10, 'C++', 'Itera desde 1 hasta n/2 y suma los divisores. Compara la suma con n.', 1, NULL),
	(17, 'GA', 'GA', 'GA', 'GA', 'GA', 'Fácil', 10, 'JavaScript', 'GA', 5, NULL);

-- Volcando estructura para tabla simulador_db_highwaydid.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `foto_perfil` varchar(255) DEFAULT 'default-user.png',
  `rol` varchar(20) DEFAULT 'user',
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla simulador_db_highwaydid.usuarios: ~11 rows (aproximadamente)
INSERT INTO `usuarios` (`id`, `nombre`, `email`, `password`, `foto_perfil`, `fecha_registro`) VALUES
	(1, 'Diego Castillo', 'diego@upt.pe', '123', 'default-user.png', '2026-04-12 03:21:52'),
	(2, 'Ana Torres', 'ana@gmail.com', '123', 'default-user.png', '2026-04-12 03:21:52'),
	(3, 'Carlos Ayala', 'carlos@upt.pe', '123', 'default-user.png', '2026-04-12 03:21:52'),
	(4, 'Joan Medina', 'joan@upt.pe', '$2b$10$szInG/BKJgqAxLZdHE/cQuYh28nY2ZtOPX2..RHmOMDo6gLHzT0fy', 'default-user.png', '2026-04-12 03:26:58'),
	(5, 'Estrella Castillo', 'estrellacastillo227@gmail.com', '$2b$10$BXloNqMCWzCpxiUQSLvLgOBAr0ifhyiOQgK5RMPY0DMr9I6CdMK7q', 'default-user.png', '2026-04-29 05:35:48'),
	(6, 'DIEGO FERNANDO CASTILLO MAMANI', 'dc2022073895@virtual.upt.pe', '$2b$10$atGuFdS0a5fWmASPEZqIQe0YT40q3K6aU86jU52ZVYTXluxx/OuXu', 'default-user.png', '2026-04-29 05:37:49'),
	(7, 'DIEGO CASTILLO', 'diegofernandocastillo848@gmail.com', '$2b$10$4JrrYstpyjhy1HL4d4KH2eLilLyCf2m/tEgvunmvSn7S5GHGavicK', 'default-user.png', '2026-04-29 06:07:54'),
	(8, 'Sergio Pro123', 'sergiotlv51@gmail.com', '$2b$10$poJN1S9dH.ArgD24DYWeauvscp.YSmdUyQGaGKTiIXiifU2cypCTq', 'default-user.png', '2026-04-30 02:29:21'),
	(9, 'PATRICK JOSE CUADROS QUIROGA', 'patcuadrosq@virtual.upt.pe', '$2b$10$yWKshlJmjuKFiaZfBdcgIOYsnbZu/tECvKZMiS6EvdwN8Vb59Qx1u', 'default-user.png', '2026-04-30 02:41:55'),
	(10, 'HASHIRA BELÉN VARGAS CANDIA', 'hv2022075480@virtual.upt.pe', '$2b$10$Aod1RZHiWD2M/pgb6YHdM.6CB70D9ujqykLZq8jHOicLjqMSZVCJ.', 'default-user.png', '2026-04-30 02:42:41'),
	(11, 'A', 'a@a.com', '$2b$10$.LF5cC8loRkuRFGLIImRVOwBVHzgvF7sGZ7nmg65cI/25nr5XiPQC', 'default-user.png', '2026-05-03 00:03:16');


CREATE TABLE amigos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  amigo_id INT,
  estado ENUM('pendiente','aceptado') DEFAULT 'pendiente',
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE salas_reto (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(8) UNIQUE,
  reto_id INT,
  creador_id INT,
  estado ENUM('esperando','en_curso','finalizado') DEFAULT 'esperando',
  ganador_id INT DEFAULT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE certificados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  sala_codigo VARCHAR(8) NOT NULL,
  reto_titulo VARCHAR(150) NOT NULL,
  oponente_nombre VARCHAR(100) NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);



/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
