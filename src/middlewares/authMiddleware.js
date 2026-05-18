const isAuthenticated = (req, res, next) => {
    if (req.session && req.session.userId) {
        return next();
    }
    res.redirect('/login');
};

const isAdmin = (req, res, next) => {
    if (req.session && req.session.usuario && req.session.usuario.rol === 'admin') {
        return next();
    }
    res.redirect('/dashboard');
};

module.exports = {
    isAuthenticated,
    isAdmin
};
