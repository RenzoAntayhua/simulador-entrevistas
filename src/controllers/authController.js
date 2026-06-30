const User = require('../models/userModel');
const bcrypt = require('bcryptjs');
const { OAuth2Client } = require('google-auth-library');
const CLIENT_ID = process.env.GOOGLE_CLIENT_ID || '492667044647-ip91s35salhgo6jb96h2s9ovj1gfgb4s.apps.googleusercontent.com';
const client = new OAuth2Client(CLIENT_ID);

exports.getLogin = (req, res) => {
    res.render('auth/login', { googleClientId: CLIENT_ID });
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
        console.log('Google Auth: Verificando token con CLIENT_ID:', CLIENT_ID);
        const ticket = await client.verifyIdToken({
            idToken: credential,
            audience: CLIENT_ID,
        });
        const payload = ticket.getPayload();
        const { email, name } = payload;
        
        let user = await User.findByEmail(email);
        if (!user) {
            const randomPassword = bcrypt.hashSync(Math.random().toString(36), 10);
            const result = await User.create(name, email, randomPassword);
            user = { id: result.insertId, nombre: name, email, rol: 'user' };
        } else if (user.rol === 'admin') {
            return res.status(403).send('Los administradores no pueden iniciar sesion con Google.');
        }
        
        req.session.userId = user.id;
        req.session.userName = user.nombre;
        req.session.usuario = user;
        return res.redirect('/dashboard');
    } catch (error) {
        console.error('Google Auth Error DETALLADO:', error.message);
        console.error('CLIENT_ID usado:', CLIENT_ID);
        console.error('Error completo:', error);
        return res.status(500).send('Error verificando la cuenta de Google: ' + error.message);
    }
};

