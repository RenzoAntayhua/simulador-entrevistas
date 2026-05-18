const express = require('express');
const router = express.Router();
const bancosController = require('../controllers/bancosController');
const { isAuthenticated } = require('../middlewares/authMiddleware');

router.post('/crear', isAuthenticated, bancosController.postCrearPregunta);
router.post('/eliminar/:id', isAuthenticated, bancosController.postEliminarPregunta);

module.exports = router;
