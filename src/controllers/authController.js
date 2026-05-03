const User = require('../models/userModel');
const bcrypt = require('bcryptjs');
const { OAuth2Client } = require('google-auth-library');
const CLIENT_ID = '279698872477-rulqnl9i28p3jcgvfpfqfeucl56nglb1.apps.googleusercontent.com';
const client = new OAuth2Client(CLIENT_ID);

exports.getLogin = (req, res) => {
    res.render('auth/login');
};

exports.postLogin = async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await User.findByEmail(email);

        if (user) {
            // Compatible de forma retroactiva (encriptadas o texto plano)
            const isMatch = bcrypt.compareSync(password, user.password) || user.password === password;
            if (isMatch) {
                // Guardamos datos en la sesi%%n
                req.session.userId = user.id;
                req.session.userName = user.nombre;
                req.session.usuario = user; // Guardamos el objeto completo para el mddleware admin
                
                if (user.rol === 'admin') {
                    return res.redirect('/admin');
                }
                return res.redirect('/dashboard');
            }
        }
        return res.send('Correo o contrase%�%a incorrectos');
    } catch (error) {
        console.error(error);
        res.send('Error al intentar iniciar sesi%%n');
    }
};

exports.getRegister = (req, res) => {
    res.render('auth/register');
};

exports.postRegister = async (req, res) => {
    const { nombre, email, password } = req.body;
    try {
        const existingUser = await User.findByEmail(email);
        if (existingUser) {
            return res.send('El correo ya est%� registrado en el sistema.');
        }

        // Hasheamos la contrase%�%a para mantener la seguridad
        const hashedPassword = bcrypt.hashSync(password, 10);
        
        // Creamos el nuevo usuario
        const result = await User.create(nombre, email, hashedPassword);
        
        // Auto-login al terminar el registro
        req.session.userId = result.insertId;
        req.session.userName = nombre;
        
        return res.redirect('/dashboard');
    } catch (error) {
        console.error(error);
        res.send('Error al intentar registrarse');
    }
};

exports.postGoogleLogin = async (req, res) => {
    const { credential } = req.body;
    if (!credential) {
        return res.status(400).send('No credential received from Google.');
    }
    try {
        const ticket = await client.verifyIdToken({
            idToken: credential,
            audience: CLIENT_ID,
        });
        const payload = ticket.getPayload();
        const { email, name } = payload;
        
        let user = await User.findByEmail(email);
        if (!user) {
            const randomPassword = bcrypt.hashSync(Math.random().toString(36), 10);
            // Si el user no existe, asumo que al crearse será un 'user' por defecto, 
            // aunque el método User.create podría no gestionar 'proveedor' si no lo hemos adaptado, pero asumiremos que sí funciona.
            const result = await User.create(name, email, randomPassword);
            user = { id: result.insertId, nombre: name, email, rol: 'user' };
        } else if (user.rol === 'admin') {
            return res.status(403).send('Los administradores no pueden iniciar sesión con Google.');
        }
        
        req.session.userId = user.id;
        req.session.userName = user.nombre;
        req.session.usuario = user; // Guardamos el objeto completo
        return res.redirect('/dashboard');
    } catch (error) {
        console.error('Google Auth Error:', error);
        return res.status(500).send('Error verificando la cuenta de Google. Revisa la consola para m%�s detalles.');
    }
};

