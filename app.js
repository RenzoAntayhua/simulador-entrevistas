require('dotenv').config();
const express = require('express');
const session = require('express-session');
const path = require('path');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// Guardamos usuarios conectados (socket.id -> data { nombre, id })
const usuariosConectados = new Map();
const salasActivas = new Map();
const db = require('./src/config/db');

function emitirConectadosUnicos() {
    const unicos = [];
    const nombresVistos = new Set();
    for (let data of usuariosConectados.values()) {
        if (!nombresVistos.has(data.nombre)) {
            nombresVistos.add(data.nombre);
            unicos.push(data);
        }
    }
    io.emit('actualizar-conectados', unicos);
}

io.on('connection', (socket) => {
    socket.on('usuario-conectado', (data) => {
        usuariosConectados.set(socket.id, data);
        emitirConectadosUnicos();
    });

    // Permitir solicitar explícitamente la lista (ej. Admin al recargar panel)
    socket.on('solicitar-conectados', () => {
        emitirConectadosUnicos();
    });

    socket.on('disconnect', () => {
        usuariosConectados.delete(socket.id);
        emitirConectadosUnicos();

        // Desconexión de batallas 1v1
        salasActivas.forEach((sala, codigo) => {
            const idx = sala.jugadores.findIndex(j => j.socketId === socket.id);
            if (idx !== -1) {
                const perdedor = sala.jugadores[idx];
                const ganador = sala.jugadores.find(j => j.socketId !== socket.id);
                if (ganador) {
                    io.to(codigo).emit('reto-ganado', { ganador, perdedor, porDesconexion: true });
                }
                salasActivas.delete(codigo);
            }
        });
    });

    // --- BATALLAS 1V1 ---
    socket.on('unirse-sala', ({ codigo, usuario }) => {
        socket.join(codigo);
        if (!salasActivas.has(codigo)) salasActivas.set(codigo, { jugadores: [] });
        const sala = salasActivas.get(codigo);
        if (!sala.jugadores.find(j => j.id === usuario.id)) {
            sala.jugadores.push({ id: usuario.id, nombre: usuario.nombre, socketId: socket.id });
        }
        io.to(codigo).emit('actualizar-sala', sala.jugadores);
        if (sala.jugadores.length === 2) io.to(codigo).emit('sala-lista', sala.jugadores);
    });

    socket.on('evaluando-codigo', ({ codigo }) => {
        socket.to(codigo).emit('oponente-evaluando');
    });

    socket.on('reto-completado', async ({ codigo, ganador, perdedor, retoTitulo }) => {
        io.to(codigo).emit('reto-ganado', { ganador, perdedor });
        try {
            await db.execute('UPDATE salas_reto SET estado="finalizado", ganador_id=? WHERE codigo=?', [ganador.id, codigo]);
            const oponenteNombre = perdedor ? perdedor.nombre : 'Desconectado';
            await db.execute('INSERT INTO certificados (usuario_id, sala_codigo, reto_titulo, oponente_nombre) VALUES (?,?,?,?)', [ganador.id, codigo, retoTitulo, oponenteNombre]);
        } catch (e) {
            console.error('Error actualizando DB en reto-completado:', e);
        }
        salasActivas.delete(codigo);
    });

    socket.on('invitar-amigo', ({ amigo_id, codigo, reto }) => {
        let retadorData = usuariosConectados.get(socket.id);
        let retador = retadorData ? retadorData.nombre : 'Un amigo';
        
        for (let [sockId, data] of usuariosConectados.entries()) {
            if (data.id == amigo_id) {
                io.to(sockId).emit('invitacion-recibida', { retador, codigo, reto });
            }
        }
    });

    socket.on('invitacion-rechazada', ({ codigo }) => {
        io.to(codigo).emit('oponente-rechazo');
    });
});

// 1. Middlewares de lectura (DEBEN IR PRIMERO)
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// 2. Sesiones en MySQL (Para Producción)
const MySQLStore = require('express-mysql-session')(session);
const pool = require('./src/config/db').pool; // Asegúrate de que tu db.js exporta 'pool' directamente o modificar esto.
// Nota: Si src/config/db.js exporta directamente el pool de promesas, el store de MySQL puede tomarlo o necesita sus propias credenciales.
// La forma más segura de instanciar es pasarle las credenciales:
const options = {
    host: process.env.DB_HOST || 'localhost',
    port: 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_NAME || 'simulador_db'
};
const sessionStore = new MySQLStore(options);

app.use(session({
    key: 'simulador_session',
    secret: process.env.SESSION_SECRET || 'clave_secreta_upt',
    store: sessionStore,
    resave: false,
    saveUninitialized: false,
    cookie: {
        maxAge: 1000 * 60 * 60 * 24 // 1 día
    }
}));

// 3. Variables locales globales (para usarse en vistas)
app.use((req, res, next) => {
    res.locals.userName    = req.session ? req.session.userName : null;
    res.locals.userId      = req.session ? req.session.userId   : null;
    res.locals.currentPath = req.path; // Para marcar el link activo en el sidebar
    next();
});

// 4. Archivos estáticos y Vistas
app.use(express.static(path.join(__dirname, 'public')));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'src/views'));

// 4. Importación de rutas con validación
const indexRoutes = require('./src/routes/index');

if (indexRoutes) {
    app.use('/', indexRoutes);
} else {
    console.error("Error: No se pudieron cargar las rutas correctamente.");
}

// 5. Puerto
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`🚀 Servidor en: http://localhost:${PORT}/login`);
});