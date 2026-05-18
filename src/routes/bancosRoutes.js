const express = require('express');
const router = express.Router();
const bancosController = require('../controllers/bancosController');
const { isAuthenticated } = require('../middlewares/authMiddleware');

router.get('/', isAuthenticated, bancosController.listarBancos);
router.get('/crear', isAuthenticated, bancosController.getCrearBanco);
router.post('/crear', isAuthenticated, bancosController.postCrearBanco);
router.get('/editar/:id', isAuthenticated, bancosController.getEditarBanco);
router.post('/editar/:id', isAuthenticated, bancosController.postEditarBanco);
router.post('/eliminar/:id', isAuthenticated, bancosController.postEliminarBanco);
router.get('/ver/:id', isAuthenticated, bancosController.verBanco);
router.post('/calificar', isAuthenticated, bancosController.calificarBanco);

module.exports = router;
