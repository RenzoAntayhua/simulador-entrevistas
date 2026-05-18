const express = require('express');
const router = express.Router();
const retosController = require('../controllers/retosController');
const { isAuthenticated } = require('../middlewares/authMiddleware');

router.get('/', isAuthenticated, retosController.listarRetos);
router.get('/crear', isAuthenticated, retosController.getCrearReto);
router.post('/crear', isAuthenticated, retosController.postCrearReto);
router.post('/calificar', isAuthenticated, retosController.calificarReto);
router.get('/resolver/:id', isAuthenticated, retosController.getResolverReto);
router.post('/evaluar', isAuthenticated, retosController.evaluarRetoEnBackend);

module.exports = router;
