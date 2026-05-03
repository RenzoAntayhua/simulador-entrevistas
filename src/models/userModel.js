const db = require('../config/db');

const User = {
    // Busca un usuario por su correo
    findByEmail: async (email) => {
        // Obtenemos todos los campos necesarios incluyendo la contraseÃ±a para la validaciÃ³n y el rol para el administrador
        const [rows] = await db.execute('SELECT id, nombre, email, password, rol FROM usuarios WHERE email = ?', [email]);
        return rows[0]; // Retorna el primer usuario que encuentre
    },
    // Crea un nuevo usuario
    create: async (nombre, email, password) => {
        const sql = 'INSERT INTO usuarios (nombre, email, password) VALUES (?, ?, ?)';
        const [result] = await db.execute(sql, [nombre, email, password]);
        return result;
    }
};

module.exports = User;