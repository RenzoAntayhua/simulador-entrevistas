-- --------------------------------------------------------
-- Host:                         0c5ena.h.filess.io
-- Server version:               11.6.2-MariaDB-ubu2404 - mariadb.org binary distribution
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             12.17.0.7270
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for simulador_db_highwaydid
CREATE DATABASE IF NOT EXISTS `simulador_db_highwaydid` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `simulador_db_highwaydid`;

-- Dumping structure for table simulador_db_highwaydid.amigos
CREATE TABLE IF NOT EXISTS `amigos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `amigo_id` int(11) DEFAULT NULL,
  `estado` enum('pendiente','aceptado') DEFAULT 'pendiente',
  `fecha` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table simulador_db_highwaydid.amigos: ~17 rows (approximately)
INSERT INTO `amigos` (`id`, `usuario_id`, `amigo_id`, `estado`, `fecha`) VALUES
	(1, 6, 4, 'aceptado', '2026-05-03 04:57:54'),
	(2, 7, 6, 'aceptado', '2026-05-03 05:29:18'),
	(3, 13, 5, 'pendiente', '2026-05-05 01:12:59'),
	(4, 13, 7, 'pendiente', '2026-05-05 01:13:02'),
	(5, 13, 6, 'aceptado', '2026-05-05 01:13:04'),
	(6, 13, 9, 'pendiente', '2026-05-05 01:13:08'),
	(7, 6, 14, 'pendiente', '2026-05-05 01:20:00'),
	(8, 6, 8, 'pendiente', '2026-05-05 01:20:12'),
	(9, 10, 6, 'aceptado', '2026-05-05 01:24:06'),
	(10, 15, 6, 'aceptado', '2026-05-05 01:26:21'),
	(11, 15, 10, 'aceptado', '2026-05-05 01:26:22'),
	(12, 17, 15, 'aceptado', '2026-05-05 01:32:48'),
	(13, 18, 6, 'aceptado', '2026-05-18 05:14:40'),
	(14, 6, 19, 'aceptado', '2026-05-19 01:23:13'),
	(15, 41, 25, 'pendiente', '2026-06-10 01:48:40'),
	(16, 41, 14, 'pendiente', '2026-06-10 01:48:59'),
	(17, 41, 1, 'pendiente', '2026-06-10 01:49:02');

-- Dumping structure for table simulador_db_highwaydid.bancos
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table simulador_db_highwaydid.bancos: ~10 rows (approximately)
INSERT INTO `bancos` (`id`, `titulo`, `descripcion`, `categoria`, `autor_id`, `fecha_creacion`) VALUES
	(1, 'JavaScript Avanzado', 'Preguntas sobre closures, promesas, event loop y patrones modernos de JS.', 'Programación', 1, '2026-04-12 03:21:52'),
	(2, 'SQL y Bases de Datos', 'Consultas SQL, optimización, índices, transacciones y modelado relacional.', 'Bases de Datos', 1, '2026-04-12 03:21:52'),
	(3, 'Python para Backend', 'Decoradores, OOP, manejo de errores, librerías y buenas prácticas en Python.', 'Programación', 2, '2026-04-12 03:21:52'),
	(4, 'Algoritmos y Estructuras', 'Complejidad algorítmica, ordenamiento, búsqueda, grafos y estructuras de datos.', 'Algoritmos', 2, '2026-04-12 03:21:52'),
	(5, 'HTML, CSS y Frontend', 'Responsive design, flexbox, grid, accesibilidad y rendimiento web.', 'Frontend', 3, '2026-04-12 03:21:52'),
	(6, 'Git y DevOps', 'Control de versiones, ramas, CI/CD, Docker y flujos de trabajo profesionales.', 'DevOps', 3, '2026-04-12 03:21:52'),
	(7, 'GAA', 'GAA', 'GAA', 6, '2026-04-29 05:37:59'),
	(8, 'A', 'A', 'A', 11, '2026-05-03 00:03:37'),
	(9, 'Entrevista Tecnica de Node', 'Conocimientos de Node como BackEnd', 'Desarrollo Web', 62, '2026-06-27 22:09:22'),
	(10, 'Entrevista Tecnica Python', 'Conocimiento Basico de Python en Backend', 'Backend', 14, '2026-06-27 22:14:46');

-- Dumping structure for table simulador_db_highwaydid.calificaciones
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

-- Dumping data for table simulador_db_highwaydid.calificaciones: ~13 rows (approximately)
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

-- Dumping structure for table simulador_db_highwaydid.calificaciones_retos
CREATE TABLE IF NOT EXISTS `calificaciones_retos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `reto_id` int(11) DEFAULT NULL,
  `estrellas` tinyint(4) DEFAULT NULL CHECK (`estrellas` between 1 and 5),
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario_id` (`usuario_id`,`reto_id`),
  KEY `reto_id` (`reto_id`),
  CONSTRAINT `calificaciones_retos_ibfk_1` FOREIGN KEY (`reto_id`) REFERENCES `retos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table simulador_db_highwaydid.calificaciones_retos: ~2 rows (approximately)
INSERT INTO `calificaciones_retos` (`id`, `usuario_id`, `reto_id`, `estrellas`) VALUES
	(1, 1, 1, 5),
	(2, 17, 15, 5);

-- Dumping structure for table simulador_db_highwaydid.casos_prueba
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

-- Dumping data for table simulador_db_highwaydid.casos_prueba: ~56 rows (approximately)
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
	(56, 16, '12', 'false', 0);

-- Dumping structure for table simulador_db_highwaydid.certificados
CREATE TABLE IF NOT EXISTS `certificados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `sala_codigo` varchar(8) NOT NULL,
  `reto_titulo` varchar(150) NOT NULL,
  `oponente_nombre` varchar(100) NOT NULL,
  `fecha` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `certificados_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table simulador_db_highwaydid.certificados: ~13 rows (approximately)
INSERT INTO `certificados` (`id`, `usuario_id`, `sala_codigo`, `reto_titulo`, `oponente_nombre`, `fecha`) VALUES
	(1, 4, 'XELWOC', 'Suma de dos números en Python', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-03 04:51:59'),
	(2, 4, '7PBW3B', 'Calculadora de IMC', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-03 04:52:58'),
	(3, 6, 'AC87ID', 'Palíndromos en Java', 'Joan Medina', '2026-05-03 05:00:15'),
	(4, 4, 'OEYKAT', 'Calculadora de IMC', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-03 05:14:26'),
	(5, 7, '33OWMG', 'Calculadora de IMC', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-03 05:30:44'),
	(6, 13, 'NS2MJ3', 'Calculadora de IMC', 'RENZO ANTONIO ANTAYHUA MAMANI', '2026-05-05 01:14:25'),
	(7, 13, '1YPJHL', 'Calculadora de IMC', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-05 01:21:10'),
	(8, 10, '117WYC', 'Suma de dos números en Python', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-05 01:25:26'),
	(9, 15, '5S8BP4', 'Suma de dos números en Python', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-05 01:27:24'),
	(10, 18, 'C87JXP', 'Números Perfectos', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-18 05:15:28'),
	(11, 18, '0TUU7M', 'Números Perfectos', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-18 05:33:43'),
	(12, 18, '9U76RF', 'Números Perfectos', 'DIEGO FERNANDO CASTILLO MAMANI', '2026-05-18 05:35:41'),
	(13, 14, 'RQI2OQ', 'Calculadora de IMC', 'Carlos Ayala Ramos', '2026-06-27 22:04:18'),
	(14, 14, 'A3JU7J', 'Calculadora de IMC', 'Carlos Ayala Ramos', '2026-06-27 22:17:28');

-- Dumping structure for table simulador_db_highwaydid.intentos
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table simulador_db_highwaydid.intentos: ~4 rows (approximately)
INSERT INTO `intentos` (`id`, `usuario_id`, `banco_id`, `puntaje`, `total`, `tiempo_segundos`, `fecha`) VALUES
	(1, 1, 1, 1, 10, 11, '2026-04-12 04:21:48'),
	(2, 1, 2, 2, 10, 28, '2026-04-13 21:14:14'),
	(3, 5, 1, 6, 10, 13, '2026-04-29 05:36:31'),
	(4, 5, 7, 1, 1, 2, '2026-04-29 05:38:31'),
	(5, 41, 2, 7, 10, 132, '2026-06-10 01:48:15');

-- Dumping structure for table simulador_db_highwaydid.intentos_retos
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
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table simulador_db_highwaydid.intentos_retos: ~117 rows (approximately)
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
	(117, 6, 15, 'def solucion(a, b):\n    # Tu lógica aquí\n return a + b', 'Exitoso', '2026-04-30 02:39:12'),
	(118, 17, 15, 'def solucion(a, b):\n    # a + b', 'Fallido', '2026-05-05 01:35:46'),
	(119, 17, 15, 'def solucion(a, b):\n    a + b', 'Fallido', '2026-05-05 01:35:56'),
	(120, 17, 15, 'def solucion(a, b):\n    return a + b', 'Exitoso', '2026-05-05 01:37:42'),
	(121, 6, 16, 'int solucion(int n) {\n  int suma = 0;\n  for (int i = 1; i <= n/2; i++) {\n    if (n % i == 0) suma += i;\n  }\n  return suma == n;\n}', 'Exitoso', '2026-05-18 05:03:09'),
	(122, 18, 16, 'int solucion(int n) {\r\n  int suma = 0;\r\n  for (int i = 1; i <= n/2; i++) {\r\n    if (n % i == 0) suma += i;\r\n  }\r\n  return suma == n;\r\n}', 'Exitoso', '2026-05-18 05:13:36'),
	(123, 14, 1, 'function solucion(peso, altura) {\n  let imc = peso / (altura * altura);\n  return Number(imc.toFixed(1));\n}', 'Exitoso', '2026-06-27 22:16:17');

-- Dumping structure for table simulador_db_highwaydid.preguntas
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

-- Dumping data for table simulador_db_highwaydid.preguntas: ~60 rows (approximately)
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

-- Dumping structure for table simulador_db_highwaydid.retos
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

-- Dumping data for table simulador_db_highwaydid.retos: ~16 rows (approximately)
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
	(16, 'Números Perfectos', 'Un número perfecto es aquel que es igual a la suma de sus divisores propios (excluyendo el mismo número). Crea una función que reciba un número entero positivo y devuelva "true" si es perfecto y "false" si no lo es. Ejemplo: 6 es perfecto porque 1+2+3=6.', 'int solucion(int n) {\r\n  // Tu lógica aquí\r\n}', '6', 'true', 'Difícil', 10, 'C++', 'Itera desde 1 hasta n/2 y suma los divisores. Compara la suma con n.', 1, NULL);

-- Dumping structure for table simulador_db_highwaydid.salas_reto
CREATE TABLE IF NOT EXISTS `salas_reto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(8) DEFAULT NULL,
  `reto_id` int(11) DEFAULT NULL,
  `creador_id` int(11) DEFAULT NULL,
  `estado` enum('esperando','en_curso','finalizado') DEFAULT 'esperando',
  `ganador_id` int(11) DEFAULT NULL,
  `fecha` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table simulador_db_highwaydid.salas_reto: ~14 rows (approximately)
INSERT INTO `salas_reto` (`id`, `codigo`, `reto_id`, `creador_id`, `estado`, `ganador_id`, `fecha`) VALUES
	(1, '7PBW3B', 1, 4, 'finalizado', 4, '2026-05-03 04:46:33'),
	(2, 'XELWOC', 15, 4, 'finalizado', 4, '2026-05-03 04:51:19'),
	(3, 'AC87ID', 13, 4, 'finalizado', 6, '2026-05-03 04:59:04'),
	(5, 'OEYKAT', 1, 4, 'finalizado', 4, '2026-05-03 05:12:53'),
	(6, '33OWMG', 1, 6, 'finalizado', 7, '2026-05-03 05:29:45'),
	(8, 'NS2MJ3', 1, 6, 'finalizado', 13, '2026-05-04 05:41:31'),
	(9, '1YPJHL', 1, 13, 'finalizado', 13, '2026-05-05 01:20:39'),
	(11, '117WYC', 15, 10, 'finalizado', 10, '2026-05-05 01:24:26'),
	(12, '5S8BP4', 15, 15, 'finalizado', 15, '2026-05-05 01:26:51'),
	(13, 'C87JXP', 16, 6, 'finalizado', 18, '2026-05-18 05:14:52'),
	(14, '0TUU7M', 16, 18, 'finalizado', 18, '2026-05-18 05:32:47'),
	(15, '9U76RF', 16, 6, 'finalizado', 18, '2026-05-18 05:35:13'),
	(22, 'RQI2OQ', 1, 62, 'finalizado', 14, '2026-06-27 22:02:27'),
	(23, 'A3JU7J', 1, 62, 'finalizado', 14, '2026-06-27 22:05:29');

-- Dumping structure for table simulador_db_highwaydid.sesiones_entrevista
CREATE TABLE IF NOT EXISTS `sesiones_entrevista` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `puesto` varchar(255) NOT NULL,
  `historial` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`historial`)),
  `nota_final` decimal(4,1) DEFAULT NULL,
  `reporte` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`reporte`)),
  `estado` enum('en_curso','completada') DEFAULT 'en_curso',
  `fecha` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `sesiones_entrevista_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table simulador_db_highwaydid.sesiones_entrevista: ~10 rows (approximately)
INSERT INTO `sesiones_entrevista` (`id`, `usuario_id`, `puesto`, `historial`, `nota_final`, `reporte`, `estado`, `fecha`) VALUES
	(1, 6, 'Backend Developer Node.js', '[{"pregunta":"¿En el desarrollo backend con Node.js, es fundamental manejar operaciones asíncronas. ¿Podrías explicar qué son las `Promises` en JavaScript y cómo nos ayudan a manejar estas operaciones de una manera más limpia y eficiente que los callbacks tradicionales?","respuesta":"Las Promises son objetos que representan el resultado eventual de una operación asíncrona. Tienen 3 estados: pending, fulfilled y rejected. Nos ayudan a evitar el \\"callback hell\\" porque podemos encadenar .then() y manejar errores con .catch(), en vez de anidar callbacks uno dentro de otro. También permiten usar async/await que hace el código asíncrono más legible, como si fuera síncrono.","_nivel":"Junior","_puesto":"Backend Developer Node.js"},{"pregunta":"Mencionaste que `async/await` hace el código asíncrono más legible. ¿Podrías explicarnos cómo funciona `async/await` internamente con las `Promises`? Y lo que es más importante, ¿cómo manejarías los errores en una función que utiliza `async/await`?","respuesta":"async/await es azúcar sintáctico sobre las Promises. Cuando una función es async, automáticamente retorna una Promise. El await pausa la ejecución de la función hasta que la Promise se resuelva, sin bloquear el hilo principal — internamente sigue usando el microtask queue de JavaScript. Para manejar errores uso try/catch envolviendo el await, en vez de .catch(), porque se ve más limpio y se comporta como manejo de errores síncrono tradicional. También puedo combinar varios await con Promise.a"},{"pregunta":"Hemos hablado de cómo Node.js maneja las operaciones asíncronas con Promises y async/await sin bloquear el hilo principal. ¿Podrías explicarnos cómo es posible esto, dado que Node.js es de hilo único? Es decir, ¿cómo funciona el Event Loop de Node.js y cuál es su papel fundamental en la ejecución de código asíncrono?","respuesta":"El Event Loop es el mecanismo que permite a Node.js ser asíncrono aunque tenga un solo hilo principal. Cuando hay una operación I/O (leer un archivo, consultar una DB, hacer un fetch), Node la delega a libuv, que usa un thread pool por debajo. Mientras esa operación se resuelve en segundo plano, el hilo principal sigue ejecutando otro código. El Event Loop tiene varias fases: timers (setTimeout), pending callbacks, poll (donde se procesan los I/O), check (setImmediate), y close callbacks. Cuando la operación asíncrona termina, su callback se encola y el Event Loop la ejecuta cuando le toca su turno, sin bloquear nada mientras tanto. Las microtasks como Promises tienen prioridad sobre las macrotasks y se ejecutan entre cada fase."},{"pregunta":"¿Hemos hablado de los fundamentos de Node.js y su modelo asíncrono. En el desarrollo backend, es común utilizar frameworks para construir APIs de manera más estructurada. Uno de los más populares es Express.js. ¿Podrías explicarnos qué es Express.js, cuál es su propósito principal y cómo configurarías una ruta básica para manejar una solicitud GET (por ejemplo, a `/productos`) en una aplicación Express?","respuesta":"esa si no se"},{"pregunta":"En la pregunta anterior, identificaste que Express.js es un framework importante. Para continuar explorando tus conocimientos en este área, imaginemos que estamos construyendo una API REST. ¿Cómo harías para procesar los datos enviados en el cuerpo (body) de una solicitud HTTP POST, por ejemplo, cuando un cliente envía un nuevo objeto en formato JSON a tu servidor Express.js?","respuesta":"noi se que haria"}]', 14.5, '{"nota":14.5,"nivel_alcanzado":"Junior con potencial","resumen":"El candidato demuestra un conocimiento excepcional de los fundamentos de Node.js, incluyendo el modelo asíncrono, Promises, async/await y el Event Loop. Sin embargo, presenta una carencia crítica en la experiencia práctica con frameworks web comunes como Express.js, lo cual es fundamental para un rol de backend.","fortalezas":["Profundo entendimiento de los conceptos asíncronos en JavaScript y Node.js (Promises, async/await).","Capacidad para explicar el funcionamiento interno del Event Loop, libuv y la gestión de microtasks/macrotasks.","Excelente comunicación de conceptos técnicos complejos de manera clara y concisa.","Honestidad al reconocer las áreas de desconocimiento, lo cual es una buena señal de actitud."],"debilidades":["Ausencia total de conocimientos o experiencia práctica con Express.js, incluyendo configuración básica de rutas y manejo de cuerpos de solicitud.","Limitada experiencia práctica en la construcción de APIs REST utilizando frameworks, lo cual es una habilidad central para un desarrollador backend Node.js, incluso a nivel junior."],"recomendacion":"El candidato debería enfocar su aprendizaje en adquirir experiencia práctica intensiva con Express.js (o un framework similar como NestJS o Fastify). Es crucial construir varias APIs REST completas, practicando la definición de rutas, el uso de middleware, el procesamiento de datos del cuerpo (JSON, formularios) y la integración con bases de datos. Esto convertirá su sólido conocimiento teórico en habilidades aplicables.","evaluacion_por_area":[{"area":"Conocimiento Técnico","puntaje":15,"maximo":20,"comentario":"Excelente conocimiento de los fundamentos de Node.js y el modelo asíncrono. Sin embargo, la falta de conocimiento de Express.js es una brecha significativa para un rol de backend."},{"area":"Resolución de Problemas","puntaje":13,"maximo":20,"comentario":"Demostró capacidad analítica al explicar mecanismos complejos. No obstante, no pudo aplicar esta habilidad a problemas prácticos comunes de construcción de APIs debido a la falta de conocimiento del framework."},{"area":"Comunicación","puntaje":16,"maximo":20,"comentario":"Muy buena capacidad para articular y explicar conceptos técnicos de forma clara y precisa en las preguntas que pudo responder."},{"area":"Experiencia Práctica","puntaje":12,"maximo":20,"comentario":"Fuerte base teórica, pero la ausencia de experiencia con un framework web estándar como Express.js es una deficiencia crítica para un puesto de desarrollador backend, incluso a nivel junior."},{"area":"Cultura y Actitud","puntaje":17,"maximo":20,"comentario":"Actitud honesta y transparente al admitir desconocimiento, lo cual es muy valorado. Demuestra potencial para aprender y crecer."}],"contrataria":true}', 'completada', '2026-06-17 04:23:15'),
	(2, 6, 'Data Scientist Python', '[{"pregunta":"No hay problema, a veces es útil empezar con lo más fundamental. En Python, si necesitaras almacenar una secuencia ordenada de elementos, como por ejemplo, una lista de los últimos 5 precios de una acción o las calificaciones de varios estudiantes, ¿qué tipo de estructura de datos básica usarías para esto y por qué la elegirías?","respuesta":"Usaría una lista, porque es lo que hemos usado en clase para guardar varios valores juntos. Con una lista puedo hacer precios = [] y después agregar con precios.append(150) cada vez que tengo un nuevo precio. Y si quiero ver el último precio sería precios[-1]. Creo que también podría usar una tupla pero esa no se puede modificar después, entonces para algo que va cambiando como precios o calificaciones, mejor lista.","_nivel":"Junior","_puesto":"Data Scientist Python"},{"pregunta":"En la pregunta anterior hablamos de listas para secuencias ordenadas. Ahora, imagina que necesitas almacenar información más compleja, como los detalles de un producto (su nombre, precio, stock disponible). Cada detalle tiene una etiqueta clara (como \'nombre\', \'precio\'). ¿Qué tipo de estructura de datos de Python usarías para guardar esta información de manera que puedas acceder a cada detalle usando su etiqueta, y por qué?","respuesta":"Usaría un diccionario (dict), porque me permite guardar cada dato con su etiqueta, como producto = {\'nombre\': \'Laptop\', \'precio\': 2500, \'stock\': 10}. Así puedo acceder directo con producto[\'precio\'] en vez de tener que recordar en qué posición está cada cosa como en una lista. Es más claro porque la etiqueta me dice qué es cada valor."},{"pregunta":"Hemos hablado de listas para almacenar secuencias. Ahora, pensemos en cómo procesarlas. Si tuvieras una lista de números, por ejemplo, `temperaturas = [20, 22, 18, 25, 21]`, y quisieras crear una *nueva* lista que solo incluyera las temperaturas mayores a 20 grados, ¿qué técnica \'Pythonic\' y concisa usarías para construir esta nueva lista a partir de la original? Dame un ejemplo de cómo filtrarías las temperaturas mayores a 20.","respuesta":"Usaría una list comprehension, que es una forma corta de crear una lista a partir de otra. Sería así:\\npythontemperaturas = [20, 22, 18, 25, 21]\\nmayores_20 = [t for t in temperaturas if t > 20]"},{"pregunta":"Hasta ahora, hemos hablado de cómo guardar y manipular datos. Un concepto fundamental para cualquier programador, especialmente en Data Science, es la capacidad de organizar el código en bloques reutilizables. Esto se logra con las funciones. Imagina que tienes una lista de números y necesitas calcular su promedio. ¿Cómo definirías una función en Python que reciba una lista de números como entrada y devuelva su promedio? Dame un ejemplo de cómo se vería la definición de esa función.","respuesta":"No sé"},{"pregunta":"Entiendo, no hay problema. A veces, la sintaxis de las funciones puede ser un poco intimidante al principio, pero son una herramienta muy poderosa. Para simplificar, piensa en una función como una receta: tiene un nombre, unos ingredientes que necesita (sus entradas) y luego hace algo para darte un resultado. En Python, ¿qué palabra clave usarías para indicar que estás empezando a definir una nueva función y cómo indicarías los \'ingredientes\' o valores que esa función necesita para trabajar?","respuesta":"Usaría def para definir la función, así: def calcular_promedio(numeros):. Los \\"ingredientes\\" serían los parámetros, en este caso numeros, que es la lista que la función va a recibir para trabajar con ella."}]', 15.4, '{"nota":15.4,"nivel_alcanzado":"Junior apto","resumen":"Reporte de contingencia generado automáticamente debido a una interrupción en el análisis. El candidato completó la entrevista para Data Scientist Python (Junior) respondiendo a 5 preguntas.","fortalezas":["Completó la entrevista de 5 preguntas de manera estructurada.","Mostró interés y perseverancia durante la evaluación."],"debilidades":["\\"Hasta ahora, hemos hablado de cómo guardar y manipular datos. Un concepto fundamental para cualquier programador, especialmente en Data Science, es la capacidad de organizar el código en bloques reutilizables. Esto se logra con las funciones. Imagina que tienes una lista de números y necesitas calcular su promedio. ¿Cómo definirías una función en Python que reciba una lista de números como entrada y devuelva su promedio? Dame un ejemplo de cómo se vería la definición de esa función.\\" → El candidato respondió que no sabía."],"recomendacion":"Revisar y reforzar los conceptos evaluados durante la sesión, especialmente en las áreas con respuestas dudosas o incompletas.","evaluacion_por_area":[{"area":"Conocimiento Técnico","puntaje":12,"maximo":20,"comentario":"Evaluado preliminarmente."},{"area":"Resolución de Problemas","puntaje":11,"maximo":20,"comentario":"Resuelve la mayoría de retos planteados."},{"area":"Comunicación","puntaje":15,"maximo":20,"comentario":"Fluidez comunicativa adecuada."},{"area":"Experiencia Práctica","puntaje":12,"maximo":20,"comentario":"Suficiente para el nivel."},{"area":"Cultura y Actitud","puntaje":16,"maximo":20,"comentario":"Buena disposición a la evaluación."}],"contrataria":true}', 'completada', '2026-06-17 04:38:07'),
	(3, 6, 'soporte tecnico', '[{"pregunta":"¿Cuáles consideras que son las mejores prácticas al desarrollar con soporte tecnico?","respuesta":"waaa","_nivel":"Junior","_puesto":"soporte tecnico"},{"pregunta":"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de soporte tecnico?","respuesta":"muy bien"},{"pregunta":"Describe un problema técnico difícil que hayas resuelto recientemente en soporte tecnico.","respuesta":"instalcion de word"},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con soporte tecnico y por qué?","respuesta":"java"},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con soporte tecnico y por qué?","respuesta":"c++"}]', 6.4, '{"nota":6.4,"nivel_alcanzado":"Junior con debilidades","resumen":"Reporte de contingencia generado automáticamente debido a una interrupción en el análisis. El candidato completó la entrevista para soporte tecnico (Junior) respondiendo a 5 preguntas.","fortalezas":["Completó la entrevista de 5 preguntas de manera estructurada.","Mostró interés y perseverancia durante la evaluación."],"debilidades":["\\"¿Cuáles consideras que son las mejores prácticas al desarrollar con soporte tecnico?\\" → El candidato respondió que no sabía.","\\"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de soporte tecnico?\\" → El candidato respondió que no sabía.","\\"¿Qué herramientas o librerías consideras esenciales para trabajar con soporte tecnico y por qué?\\" → El candidato respondió que no sabía.","\\"¿Qué herramientas o librerías consideras esenciales para trabajar con soporte tecnico y por qué?\\" → El candidato respondió que no sabía."],"recomendacion":"Revisar y reforzar los conceptos evaluados durante la sesión, especialmente en las áreas con respuestas dudosas o incompletas.","evaluacion_por_area":[{"area":"Conocimiento Técnico","puntaje":5,"maximo":20,"comentario":"Evaluado preliminarmente."},{"area":"Resolución de Problemas","puntaje":4,"maximo":20,"comentario":"Resuelve la mayoría de retos planteados."},{"area":"Comunicación","puntaje":15,"maximo":20,"comentario":"Fluidez comunicativa adecuada."},{"area":"Experiencia Práctica","puntaje":5,"maximo":20,"comentario":"Suficiente para el nivel."},{"area":"Cultura y Actitud","puntaje":16,"maximo":20,"comentario":"Buena disposición a la evaluación."}],"contrataria":false}', 'completada', '2026-06-17 05:34:04'),
	(4, 18, 'Backend Developer Node.js Junior', '[{"pregunta":"¿Cuáles consideras que son las mejores prácticas al desarrollar con Backend Developer Node.js Junior?","respuesta":"waa","_nivel":"Junior","_puesto":"Backend Developer Node.js Junior"},{"pregunta":"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de Backend Developer Node.js Junior?","respuesta":"no che"},{"pregunta":"Describe un problema técnico difícil que hayas resuelto recientemente en Backend Developer Node.js Junior.","respuesta":"Hace poco tuve un problema en mi proyecto del simulador de entrevistas, donde uso un pool de conexiones a MySQL con un límite de solo 4 conexiones simultáneas porque mi hosting gratuito lo restringe. Cuando varios usuarios evaluaban código al mismo tiempo, a veces se quedaban esperando o fallaban porque se agotaban las conexiones disponibles. Lo resolví asegurándome de que cada conexión se liberara correctamente después de cada consulta, usando bien el pool con mysql2/promise en vez de crear conexiones nuevas cada vez. También agregué manejo de errores con try/catch en cada función que usa la base de datos, para que si algo fallaba no se quedara una conexión \\"colgada\\" sin liberarse."},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Backend Developer Node.js Junior y por qué?","respuesta":"Para backend con Node.js considero esenciales Express para crear las rutas y APIs de forma rápida, dotenv para manejar variables de entorno sin exponer credenciales, y mysql2 (o el ORM que corresponda) para conectarse a la base de datos de forma segura con consultas parametrizadas. También uso nodemon en desarrollo para que el servidor se reinicie solo al guardar cambios, y algo como express-session cuando necesito manejar autenticación de usuarios."},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Backend Developer Node.js Junior y por qué?","respuesta":"Para backend con Node.js considero esenciales Express, porque simplifica crear rutas y manejar peticiones HTTP sin escribir todo desde cero. También dotenv, para mantener las credenciales y configuraciones fuera del código fuente. Uso mysql2 para conectarme a la base de datos con consultas parametrizadas y evitar inyección SQL. En desarrollo uso nodemon para que el servidor se reinicie automáticamente al guardar cambios, y express-session cuando el proyecto necesita manejar sesiones de usuario y autenticación."}]', 14.0, '{"nota":14,"nivel_alcanzado":"Junior apto","resumen":"Reporte de contingencia generado automáticamente debido a una interrupción en el análisis. El candidato completó la entrevista para Backend Developer Node.js Junior (Junior) respondiendo a 5 preguntas.","fortalezas":["Completó la entrevista de 5 preguntas de manera estructurada.","Mostró interés y perseverancia durante la evaluación."],"debilidades":["\\"¿Cuáles consideras que son las mejores prácticas al desarrollar con Backend Developer Node.js Junior?\\" → El candidato respondió que no sabía.","\\"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de Backend Developer Node.js Junior?\\" → El candidato respondió que no sabía."],"recomendacion":"Revisar y reforzar los conceptos evaluados durante la sesión, especialmente en las áreas con respuestas dudosas o incompletas.","evaluacion_por_area":[{"area":"Conocimiento Técnico","puntaje":11,"maximo":20,"comentario":"Evaluado preliminarmente."},{"area":"Resolución de Problemas","puntaje":10,"maximo":20,"comentario":"Resuelve la mayoría de retos planteados."},{"area":"Comunicación","puntaje":15,"maximo":20,"comentario":"Fluidez comunicativa adecuada."},{"area":"Experiencia Práctica","puntaje":11,"maximo":20,"comentario":"Suficiente para el nivel."},{"area":"Cultura y Actitud","puntaje":16,"maximo":20,"comentario":"Buena disposición a la evaluación."}],"contrataria":true}', 'completada', '2026-06-17 05:55:06'),
	(5, 6, 'data science', '[{"pregunta":"¿Cuáles consideras que son las mejores prácticas al desarrollar con data science?","respuesta":"usar bd","_nivel":"Mid","_puesto":"data science"},{"pregunta":"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de data science?","respuesta":"muy bien"},{"pregunta":"Describe un problema técnico difícil que hayas resuelto recientemente en data science.","respuesta":null}]', NULL, NULL, 'en_curso', '2026-06-17 06:08:38'),
	(6, 6, 'data science', '[{"pregunta":"¿Cuáles consideras que son las mejores prácticas al desarrollar con data science?","respuesta":null,"_nivel":"Junior","_puesto":"data science"}]', NULL, NULL, 'en_curso', '2026-06-17 06:28:17'),
	(7, 6, 'Frontend React', '[{"pregunta":"¿Cuáles consideras que son las mejores prácticas al desarrollar con Frontend React?","respuesta":"Nose","_nivel":"Mid","_puesto":"Frontend React"},{"pregunta":"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de Frontend React?","respuesta":"Github"},{"pregunta":"Describe un problema técnico difícil que hayas resuelto recientemente en Frontend React.","respuesta":"manejo de DOM"},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?","respuesta":"a"},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?","respuesta":"a"}]', 7.4, '{"nota":7.4,"nivel_alcanzado":"Mid con debilidades","resumen":"Reporte de contingencia generado automáticamente debido a una interrupción en el análisis. El candidato completó la entrevista para Frontend React (Mid) respondiendo a 5 preguntas.","fortalezas":["Completó la entrevista de 5 preguntas de manera estructurada.","Mostró interés y perseverancia durante la evaluación."],"debilidades":["\\"¿Cuáles consideras que son las mejores prácticas al desarrollar con Frontend React?\\" → El candidato respondió que no sabía.","\\"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de Frontend React?\\" → El candidato respondió que no sabía.","\\"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?\\" → El candidato respondió que no sabía.","\\"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?\\" → El candidato respondió que no sabía."],"recomendacion":"Revisar y reforzar los conceptos evaluados durante la sesión, especialmente en las áreas con respuestas dudosas o incompletas.","evaluacion_por_area":[{"area":"Conocimiento Técnico","puntaje":6,"maximo":20,"comentario":"Evaluado preliminarmente."},{"area":"Resolución de Problemas","puntaje":5,"maximo":20,"comentario":"Resuelve la mayoría de retos planteados."},{"area":"Comunicación","puntaje":15,"maximo":20,"comentario":"Fluidez comunicativa adecuada."},{"area":"Experiencia Práctica","puntaje":6,"maximo":20,"comentario":"Suficiente para el nivel."},{"area":"Cultura y Actitud","puntaje":16,"maximo":20,"comentario":"Buena disposición a la evaluación."}],"contrataria":false}', 'completada', '2026-06-18 02:25:31'),
	(8, 14, 'Frontend Developer React', '[{"pregunta":"¿Cuáles consideras que son las mejores prácticas al desarrollar con Frontend Developer React?","respuesta":"asdasdasdasd","_nivel":"Mid","_puesto":"Frontend Developer React"},{"pregunta":"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de Frontend Developer React?","respuesta":"asdasdasdasasdasd"},{"pregunta":"Describe un problema técnico difícil que hayas resuelto recientemente en Frontend Developer React.","respuesta":"asdadsadasd"},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend Developer React y por qué?","respuesta":"asdadsad"},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend Developer React y por qué?","respuesta":"asdasdasdas"}]', 17.0, '{"nota":17,"nivel_alcanzado":"Mid apto","resumen":"Reporte de contingencia generado automáticamente debido a una interrupción en el análisis. El candidato completó la entrevista para Frontend Developer React (Mid) respondiendo a 5 preguntas.","fortalezas":["Completó la entrevista de 5 preguntas de manera estructurada.","Mostró interés y perseverancia durante la evaluación."],"debilidades":["\\"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend Developer React y por qué?\\" → El candidato respondió que no sabía."],"recomendacion":"Revisar y reforzar los conceptos evaluados durante la sesión, especialmente en las áreas con respuestas dudosas o incompletas.","evaluacion_por_area":[{"area":"Conocimiento Técnico","puntaje":14,"maximo":20,"comentario":"Evaluado preliminarmente."},{"area":"Resolución de Problemas","puntaje":12,"maximo":20,"comentario":"Resuelve la mayoría de retos planteados."},{"area":"Comunicación","puntaje":15,"maximo":20,"comentario":"Fluidez comunicativa adecuada."},{"area":"Experiencia Práctica","puntaje":13,"maximo":20,"comentario":"Suficiente para el nivel."},{"area":"Cultura y Actitud","puntaje":16,"maximo":20,"comentario":"Buena disposición a la evaluación."}],"contrataria":true}', 'completada', '2026-06-27 22:18:52'),
	(9, 14, 'Frontend React', '[{"pregunta":"¿Cuáles consideras que son las mejores prácticas al desarrollar con Frontend React?","respuesta":"asdasd","_nivel":"Mid","_puesto":"Frontend React"},{"pregunta":"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de Frontend React?","respuesta":"asdasd"},{"pregunta":"Describe un problema técnico difícil que hayas resuelto recientemente en Frontend React.","respuesta":"asdasdas"},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?","respuesta":"asdasd"},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?","respuesta":"asdas"}]', 5.0, '{"nota":5,"nivel_alcanzado":"Mid con debilidades","resumen":"Reporte de contingencia generado automáticamente debido a una interrupción en el análisis. El candidato completó la entrevista para Frontend React (Mid) respondiendo a 5 preguntas.","fortalezas":["Completó la entrevista de 5 preguntas de manera estructurada.","Mostró interés y perseverancia durante la evaluación."],"debilidades":["\\"¿Cuáles consideras que son las mejores prácticas al desarrollar con Frontend React?\\" → El candidato respondió que no sabía.","\\"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de Frontend React?\\" → El candidato respondió que no sabía.","\\"Describe un problema técnico difícil que hayas resuelto recientemente en Frontend React.\\" → El candidato respondió que no sabía.","\\"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?\\" → El candidato respondió que no sabía.","\\"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?\\" → El candidato respondió que no sabía."],"recomendacion":"Revisar y reforzar los conceptos evaluados durante la sesión, especialmente en las áreas con respuestas dudosas o incompletas.","evaluacion_por_area":[{"area":"Conocimiento Técnico","puntaje":4,"maximo":20,"comentario":"Evaluado preliminarmente."},{"area":"Resolución de Problemas","puntaje":4,"maximo":20,"comentario":"Resuelve la mayoría de retos planteados."},{"area":"Comunicación","puntaje":15,"maximo":20,"comentario":"Fluidez comunicativa adecuada."},{"area":"Experiencia Práctica","puntaje":4,"maximo":20,"comentario":"Suficiente para el nivel."},{"area":"Cultura y Actitud","puntaje":16,"maximo":20,"comentario":"Buena disposición a la evaluación."}],"contrataria":false}', 'completada', '2026-06-27 22:20:57'),
	(10, 14, 'Frontend React', '[{"pregunta":"¿Cuáles consideras que son las mejores prácticas al desarrollar con Frontend React?","respuesta":"Componentes pequeños y reutilizables: Seguir el principio de responsabilidad única.\\nEstructura de archivos clara: Organizar por características (features) o por tipo (componentes, hooks, servicios).\\nUso correcto de Hooks: Evitar re-renders innecesarios memorizando con useMemo y useCallback solo cuando sea crucial.","_nivel":"Mid","_puesto":"Frontend React"},{"pregunta":"¿Cómo manejas el control de versiones y el trabajo en equipo en un proyecto de Frontend React?","respuesta":"GitFlow / Feature Branches: Crear ramas independientes por cada tarea (feature/bton-login) y nunca pushear directo a main.\\nPull Requests (PRs) estrictas: Revisión de código por pares, ejecución de pruebas automáticas (CI/CD) y linters antes de fusionar."},{"pregunta":"Describe un problema técnico difícil que hayas resuelto recientemente en Frontend React.","respuesta":"Problema: Caída drástica de rendimiento en un dashboard que renderizaba miles de filas de datos en tiempo real debido a múltiples re-renders por WebSockets.\\nSolución: Implementé virtualización de listas (con react-window) para renderizar solo lo visible en pantalla. Además, optimicé el contexto global dividiendo el estado y aplicando React.memo a los componentes de las filas, reduciendo el uso de CPU en un 70%."},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?","respuesta":"Vite: Como empaquetador, porque es infinitamente más rápido que el viejo Create React App.\\nTailwind CSS: Para un estilizado rápido, responsivo y basado en clases utilitarias sin salir del componente."},{"pregunta":"¿Qué herramientas o librerías consideras esenciales para trabajar con Frontend React y por qué?","respuesta":"Vite: Como empaquetador, porque es infinitamente más rápido que el viejo Create React App.\\nTailwind CSS: Para un estilizado rápido, responsivo y basado en clases utilitarias sin salir del componente."}]', 18.9, '{"nota":18.9,"nivel_alcanzado":"Mid apto","resumen":"Reporte de contingencia generado automáticamente debido a una interrupción en el análisis. El candidato completó la entrevista para Frontend React (Mid) respondiendo a 5 preguntas.","fortalezas":["Completó la entrevista de 5 preguntas de manera estructurada.","Mostró interés y perseverancia durante la evaluación."],"debilidades":["Se requiere profundizar en aspectos avanzados de Frontend React."],"recomendacion":"Revisar y reforzar los conceptos evaluados durante la sesión, especialmente en las áreas con respuestas dudosas o incompletas.","evaluacion_por_area":[{"area":"Conocimiento Técnico","puntaje":15,"maximo":20,"comentario":"Evaluado preliminarmente."},{"area":"Resolución de Problemas","puntaje":13,"maximo":20,"comentario":"Resuelve la mayoría de retos planteados."},{"area":"Comunicación","puntaje":15,"maximo":20,"comentario":"Fluidez comunicativa adecuada."},{"area":"Experiencia Práctica","puntaje":14,"maximo":20,"comentario":"Suficiente para el nivel."},{"area":"Cultura y Actitud","puntaje":16,"maximo":20,"comentario":"Buena disposición a la evaluación."}],"contrataria":true}', 'completada', '2026-06-27 22:23:50');

-- Dumping structure for table simulador_db_highwaydid.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `foto_perfil` varchar(255) DEFAULT 'default-user.png',
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `rol` enum('admin','user') DEFAULT 'user',
  `proveedor` enum('local','google') DEFAULT 'local',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table simulador_db_highwaydid.usuarios: ~59 rows (approximately)
INSERT INTO `usuarios` (`id`, `nombre`, `email`, `password`, `foto_perfil`, `fecha_registro`, `rol`, `proveedor`) VALUES
	(1, 'Diego Castillo', 'diego@upt.pe', '123', 'default-user.png', '2026-04-12 03:21:52', 'user', 'local'),
	(2, 'Ana Torres', 'ana@gmail.com', '123', 'default-user.png', '2026-04-12 03:21:52', 'user', 'local'),
	(3, 'Carlos Ayala', 'carlos@upt.pe', '123', 'default-user.png', '2026-04-12 03:21:52', 'user', 'local'),
	(4, 'Joan Medina', 'joan@upt.pe', '$2b$10$szInG/BKJgqAxLZdHE/cQuYh28nY2ZtOPX2..RHmOMDo6gLHzT0fy', 'default-user.png', '2026-04-12 03:26:58', 'user', 'local'),
	(5, 'Estrella Castillo', 'estrellacastillo227@gmail.com', '$2b$10$BXloNqMCWzCpxiUQSLvLgOBAr0ifhyiOQgK5RMPY0DMr9I6CdMK7q', 'default-user.png', '2026-04-29 05:35:48', 'user', 'local'),
	(6, 'DIEGO FERNANDO CASTILLO MAMANI', 'dc2022073895@virtual.upt.pe', '$2b$10$atGuFdS0a5fWmASPEZqIQe0YT40q3K6aU86jU52ZVYTXluxx/OuXu', 'default-user.png', '2026-04-29 05:37:49', 'user', 'local'),
	(7, 'DIEGO CASTILLO', 'diegofernandocastillo848@gmail.com', '$2b$10$4JrrYstpyjhy1HL4d4KH2eLilLyCf2m/tEgvunmvSn7S5GHGavicK', 'default-user.png', '2026-04-29 06:07:54', 'user', 'local'),
	(8, 'Sergio Pro123', 'sergiotlv51@gmail.com', '$2b$10$poJN1S9dH.ArgD24DYWeauvscp.YSmdUyQGaGKTiIXiifU2cypCTq', 'default-user.png', '2026-04-30 02:29:21', 'user', 'local'),
	(9, 'PATRICK JOSE CUADROS QUIROGA', 'patcuadrosq@virtual.upt.pe', '$2b$10$yWKshlJmjuKFiaZfBdcgIOYsnbZu/tECvKZMiS6EvdwN8Vb59Qx1u', 'default-user.png', '2026-04-30 02:41:55', 'user', 'local'),
	(10, 'HASHIRA BELÉN VARGAS CANDIA', 'hv2022075480@virtual.upt.pe', '$2b$10$Aod1RZHiWD2M/pgb6YHdM.6CB70D9ujqykLZq8jHOicLjqMSZVCJ.', 'default-user.png', '2026-04-30 02:42:41', 'user', 'local'),
	(11, 'A', 'a@a.com', '$2b$10$.LF5cC8loRkuRFGLIImRVOwBVHzgvF7sGZ7nmg65cI/25nr5XiPQC', 'default-user.png', '2026-05-03 00:03:16', 'user', 'local'),
	(12, 'OSITO AYALA', 'admin@upt.pe', '123', 'default-user.png', '2026-05-03 03:20:01', 'admin', 'local'),
	(13, 'Andy Michael Calizaya Ladera', 'michaelladera2004@gmail.com', '$2b$10$SCdDEiIa9mUhnxUU5sckuO.UXfaF3Cxltu7JRXfYbQqAHD5K3KW7G', 'default-user.png', '2026-05-05 01:12:21', 'user', 'local'),
	(14, 'RENZO ANTONIO ANTAYHUA MAMANI', 'ra2022073504@virtual.upt.pe', '$2b$10$xzkxxliORguAvfRW0RLKTenKlSUMjuRC2.MGiyytEfTw3R/DlCbxy', 'default-user.png', '2026-05-05 01:12:27', 'user', 'local'),
	(15, 'Gerardo Concha', 'conchagerardoa@gmail.com', '$2b$10$vqds9cukObyY9WERtFAWH.iBVEyiBbMMKD6Ex0pXwbN2pp4rCQJsq', 'default-user.png', '2026-05-05 01:25:31', 'user', 'local'),
	(16, 'JEFFERSON RONALDIHÑO ROSAS CHAMBILLA', 'jr2021072618@virtual.upt.pe', '$2b$10$L1i6WqOy5PS0MaGlZe5zh.zigvJpVdCDCOEioVKcoukniXjFf/lOq', 'default-user.png', '2026-05-05 01:30:44', 'user', 'local'),
	(17, 'Junior Mamani', 'junior@gmail.com', '$2b$10$8YA3oImxyhTsi8iUp28cjeU4qyfrFRMG1PxSVXPHam.mtzRu1bg6u', 'default-user.png', '2026-05-05 01:31:09', 'user', 'local'),
	(18, 'Diego Castillo', 'diegofer12320@gmail.com', '$2b$10$K0mq7/PStl6N1STALh35he1bRZpVkZXbtl1tXrX4J77oo.ElgcReq', 'default-user.png', '2026-05-18 05:11:46', 'user', 'local'),
	(19, 'Angel Jose VARGAS GUTIERREZ', 'av2020066922@virtual.upt.pe', '$2b$10$yeufgluADTIbtXhmWY5.3.7cb.K1y13gssGEM4ymyLj7sv2MqyOgy', 'default-user.png', '2026-05-19 01:22:55', 'user', 'local'),
	(20, 'LUDVIN RENSO GUTIERREZ LAURA', 'lg2022073506@virtual.upt.pe', '$2b$10$Q53xEy..1LSXsz6Gi4loJ.mMqkDebQZN0bEaazio46/HnlQRVvkBy', 'default-user.png', '2026-06-01 23:16:16', 'user', 'local'),
	(21, 'Angel Vargad', 'vargastechnologiesteam@gmail.com', '$2b$10$uhVaXf./Oa8TGsWSTbufsudwSFnz0mpKXVrq4MnDLq.0r1XT8E8b2', 'default-user.png', '2026-06-01 23:18:40', 'user', 'local'),
	(22, 'Bruno Enrique ANCCO SUAÑA', 'ba2023077472@virtual.upt.pe', '$2b$10$zE23l/7yiK42qwfd1nX.MuFqxyTZtzYwXv.tDll2N/6YDGraRjBW.', 'default-user.png', '2026-06-01 23:46:28', 'user', 'local'),
	(23, 'MARYMAR DANYTZA CALLOTICONA CHAMBILLA', 'mc2023076791@virtual.upt.pe', '$2b$10$GZPlm5uYOeFU0jvc5kcrVeTPcYNDd6zNdqDOy8i/JUZZYHfthhjSG', 'default-user.png', '2026-06-01 23:51:57', 'user', 'local'),
	(24, 'ANDY MICHAEL CALIZAYA LADERA', 'ac2022074258@virtual.upt.pe', '$2b$10$yvcgCtpzj.IX8btgoE.lfuCXb5oVMIUcgGEc8rfy135YlRn/p.NKm', 'default-user.png', '2026-06-01 23:53:09', 'user', 'local'),
	(25, 'JOAN CRISTIAN MEDINA QUISPE', 'jm2022074255@virtual.upt.pe', '$2b$10$7r4gBebUaka5ZnXcWOb3XeZuJS.rpAB9sX7LPwlk4bEjmip8mZzsu', 'default-user.png', '2026-06-02 00:05:10', 'user', 'local'),
	(26, 'Renzo Fernando LOYOLA VILCA CHOQUE', 'rl2021072615@virtual.upt.pe', '$2b$10$zIdQj162WWPZ.pWRLloLLOGS.K2GCiBOs6UbfVUcyqHIuz.iXZ8l2', 'default-user.png', '2026-06-02 00:07:16', 'user', 'local'),
	(27, 'FRANCO TEDDY MANGO PUMA', 'fm2021072628@virtual.upt.pe', '$2b$10$FViaXVKOHt.LNqMaiOODz.gy63BDh441qSKd1uRosWoEN9Vsw4KO6', 'default-user.png', '2026-06-02 00:34:00', 'user', 'local'),
	(28, 'VICTOR WILLIAMS CRUZ MAMANI', 'vc2022073903@virtual.upt.pe', '$2b$10$f8WcFTXlS2V4mFK1GpApzOvyQxphuEDDLGVEu3T141iKtYFidHPh2', 'default-user.png', '2026-06-02 00:56:11', 'user', 'local'),
	(29, 'ENZO LEONEL LAQUI LUYO', 'el2022073907@virtual.upt.pe', '$2b$10$8ia/15YZiJm5PY4tsLKZ0e3HrBBXDxanKcbt662vimP4.zR6.1TFS', 'default-user.png', '2026-06-02 00:58:35', 'user', 'local'),
	(30, 'cristian quispe levano', 'cristianql1999@gmail.com', '$2b$10$PPg1y7Dvo99iJbcHGN.mGeS7FT1oDRG4LVE5gnffWR4xayaiuNIO2', 'default-user.png', '2026-06-06 00:16:16', 'user', 'local'),
	(31, 'Nikolás C. Meléndez', 'nkmelndz@gmail.com', '$2b$10$CkLvok51m/ky6AHudacn1.nru5.vv8YZucr0nhbuBr4AQtvl4iKaW', 'default-user.png', '2026-06-06 00:20:44', 'user', 'local'),
	(32, 'Yo Yo tmbn', 'yotmbnyo@gmail.com', '$2b$10$GG/MXdLTzzGNVkn0VudEGOfYgdD84jqsXR.8dDGA/iUg8YU3fmyz6', 'default-user.png', '2026-06-06 00:23:40', 'user', 'local'),
	(33, 'Gerardo Alejandro CONCHA LLACA', 'gc2017057849@virtual.upt.pe', '$2b$10$rxMGqKuYp22kGsx/Xrp0buAMT1LTD/TaZ.iBMoFUF9gLDaeB0BZxe', 'default-user.png', '2026-06-06 00:34:32', 'user', 'local'),
	(34, 'Luzkalid Gutierrez', 'luzkalidgm@gmail.com', '$2b$10$vRi76/3/J8/6gUxnvjJYoerDgNcXk9vxA7cSLl5rd8L5rae9bd2Za', 'default-user.png', '2026-06-09 23:15:37', 'user', 'local'),
	(35, 'Sebastian Fuentes', 'fuentessebastiansa4s@gmail.com', '$2b$10$zu4aT8ZllCf20oMa/fJ5Nu6orsyfcEaPZb3OB.dxYIpyxabIoM3CS', 'default-user.png', '2026-06-09 23:15:49', 'user', 'local'),
	(36, 'MAYRA FERNANDA CHIRE RAMOS', 'mc2021072620@virtual.upt.pe', '$2b$10$ctrcD7YXOzoVlXRt1vj19ualS4ql52SJg0UQH9gzOjbphfXZB4EBC', 'default-user.png', '2026-06-09 23:20:26', 'user', 'local'),
	(37, 'Maria Jose Coaguila Caceres', 'majos2209@gmail.com', '$2b$10$EUdkmWXiawbV8M.LuUG/kerEbU05LLQSzo4enWSdOqv1L86hWYaZC', 'default-user.png', '2026-06-09 23:26:18', 'user', 'local'),
	(38, 'ADRIANA RAFAELA LAOS GONZALEZ', 'al2023077474@virtual.upt.pe', '$2b$10$kYC4FP46/aop78sLfJmdKewdugk.7bwqU8dGFkohFmM2rYldaF1hG', 'default-user.png', '2026-06-10 01:28:32', 'user', 'local'),
	(39, 'Mariela Ramos', 'maranyramos7@gmail.com', '$2b$10$iexkEPDSaJn8epG2sJye6uZjtD32ro6Q5OjhOMRReTewLw2GpGwg2', 'default-user.png', '2026-06-10 01:30:10', 'user', 'local'),
	(40, 'Mary Luz CHURA TICONA', 'mc2019065163@virtual.upt.pe', '$2b$10$AzRmCcpeRCpPH7cs4QHGFOHQSH9Iq0a9t.t0FGd7780FEXGgsdAoa', 'default-user.png', '2026-06-10 01:42:33', 'user', 'local'),
	(41, 'Royser Villanueva', 'royservillanueva2004@gmail.com', '$2b$10$lObJD6J8n17qGCagR7SSuOEATVBAjT1kdsm3yK1ZNJfk8PlSUMP0e', 'default-user.png', '2026-06-10 01:44:10', 'user', 'local'),
	(42, 'Enzo Alejandro VASQUEZ VELASCO', 'ev2020066899@virtual.upt.pe', '$2b$10$5bqLLGAHFrQ68nJshicRRe7fjkxyEIErkzeXx0HecokWTAUD8Qw.G', 'default-user.png', '2026-06-10 01:49:29', 'user', 'local'),
	(43, 'Nicole Medina', 'nicolemedinalopez496@gmail.com', '$2b$10$n2JF5dIiTXc99GCtQ84ideEL4.A5ls6HRFzzQhjMtf/E1J9WIHCQi', 'default-user.png', '2026-06-10 01:52:12', 'user', 'local'),
	(44, 'DIEGO ERICK CAHUANA CCASO', 'dc2023076684@virtual.upt.pe', '$2b$10$OUhrlWilC.6Ifr/EKtvZXu8c.P4BeCEPb47rh39Rm0ueJDLsaDQmy', 'default-user.png', '2026-06-10 01:55:53', 'user', 'local'),
	(45, 'VICTOR ADRIAN MAMANI CAMPOS', 'vm2022075464@virtual.upt.pe', '$2b$10$Rjb/ZV.d/ykVOMIv62lna.l85mdoewFIw7N7aafEYkgFQ.ofU2K7q', 'default-user.png', '2026-06-10 01:57:13', 'user', 'local'),
	(46, 'LUCERO MAMANI PACOTICONA', 'lucerobtsarmy7@gmail.com', '$2b$10$PXh4y5TtdXRPo02bSHEzqeSEndp.UuhGsioC1zb9nLHTBETduteEG', 'default-user.png', '2026-06-10 02:05:06', 'user', 'local'),
	(47, 'GIAN MARCO CHIPANA VILLON', 'gc2022075687@virtual.upt.pe', '$2b$10$bBWNSP.XGTZSM5Tk1CCdeOKxeeHjKkBXe997eScGS.9bUn/neL44u', 'default-user.png', '2026-06-10 02:10:17', 'user', 'local'),
	(48, 'Brenda Arocutipa', 'brendaarocutipaticona@gmail.com', '$2b$10$a24rALlqkbuV7cKER10PweJqFn43Pt5WkCMDMBA4MS2oaYTU35mTu', 'default-user.png', '2026-06-10 02:20:20', 'user', 'local'),
	(49, 'Mónica Daval_os', 'monicaada2005@gmail.com', '$2b$10$4BGz1XZoXsNHfCdoGvQIPu9z2HYYkaTGnrSQ1GqaFmfBT4uYSkRmC', 'default-user.png', '2026-06-10 02:22:50', 'user', 'local'),
	(50, 'Gino Navarro', 'floresneduardo7@gmail.com', '$2b$10$SUZQH7B0arv.dUCET9s.Iewe3mldLNHv9cgS0zYyPrEiKou6p91uS', 'default-user.png', '2026-06-10 02:25:38', 'user', 'local'),
	(51, 'LUIS DAVID MOSQUITO FLORES', 'lm2023077088@virtual.upt.pe', '$2b$10$hrr/3hhm7MkWLSZJUrwIaegVO7c76yEzjbXpKhLEDBKSd1GpZHoxK', 'default-user.png', '2026-06-10 02:30:40', 'user', 'local'),
	(52, 'Ana Cecilia Esteban', 'anaesteban4b@gmail.com', '$2b$10$gzBgUupmEfmcHTlMIxOR2eqifnvOtb53h09PRxCrO3s/VaDtQJQnW', 'default-user.png', '2026-06-10 02:34:55', 'user', 'local'),
	(53, 'SOANNY GERALDINE RIVAS GUTIERREZ', 'sr2023078694@virtual.upt.pe', '$2b$10$RNXOb5bRkHML/2gAz9s0R.zAKwVeAu294VFLUiRxMv38Ffux3DFMG', 'default-user.png', '2026-06-10 02:36:42', 'user', 'local'),
	(54, 'Sebastian Arce', 'sebastianarce2010@gmail.com', '$2b$10$vG/bixLE6x0Kk7venSZ6oeCFDqsnsrkamcxGG6ZgPHLqF4.uTOMBa', 'default-user.png', '2026-06-11 00:06:33', 'user', 'local'),
	(55, 'Moisés !!!', 'alessandrocorrales5@gmail.com', '$2b$10$OCqHDcrBdh3iMH3EHZs4AueF9fPEUFYT./xKV.Mi7QgT6iP0ysGl6', 'default-user.png', '2026-06-11 00:12:10', 'user', 'local'),
	(56, 'JHOSELYN ELEANITA SANTILLAN RIVERA', 'js2021072579@virtual.upt.pe', '$2b$10$TIg6NKEE2s5aM3EluW20h.du5Lk7saMFGYR.F1oemC2omOTCkyRTK', 'default-user.png', '2026-06-11 00:26:21', 'user', 'local'),
	(57, 'NAYELI YAKELIN RAMOS CUEVA', 'nr2021069976@virtual.upt.pe', '$2b$10$TwxNv8A.6sck4ro5ZCi0luEhZLNBW2P4J9KpfrvzSZQGaw5ytKEoy', 'default-user.png', '2026-06-11 00:29:02', 'user', 'local'),
	(58, 'JOSE DANIEL TICONA LUPACA', 'jt2024079716@virtual.upt.pe', '$2b$10$olNjCCzRbcNlA8nkxvnzK.y0JMqN8ufTGlOyLTC2YQaqX0uucoW.W', 'default-user.png', '2026-06-11 00:31:27', 'user', 'local'),
	(59, 'MICHELL ENRIQUE ACOSTA VILCA', 'ma2022075457@virtual.upt.pe', '$2b$10$GFsJhbp7XtsazDN2pvpEROWx4.ErLHNQK/Kq19lZcTMJfHMDrNACG', 'default-user.png', '2026-06-11 00:42:01', 'user', 'local'),
	(60, 'Elvis MAMANI VALDIVIA', 'em2020068763@virtual.upt.pe', '$2b$10$KFfaUKj1CugBvETf7r7JcOFVtOcmlAC1N8v1xVDJHIgwHvZ7vTfLa', 'default-user.png', '2026-06-11 00:58:39', 'user', 'local'),
	(61, 'Javier Arteaga Ramos', 'javieroarteaga@gmail.com', '$2b$10$dN9xQ1wKr6qMHcR361ntauIukkHZ0yqS.UfrHV469NwGmh5dop7QG', 'default-user.png', '2026-06-11 01:00:48', 'user', 'local'),
	(62, 'Carlos Ayala Ramos', 'carlos@gmail.com', '$2b$10$/6yKKAzym6C9awINcoRX8./aVbyk8IGP0YO4jrJUoYXAr5.1Sa5vm', 'default-user.png', '2026-06-27 22:00:20', 'user', 'local');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
