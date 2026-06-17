const express = require('express');
const router = express.Router();
const { isAuthenticated } = require('../middlewares/authMiddleware');
const entrevistaController = require('../controllers/entrevistaController');

router.get('/', isAuthenticated, entrevistaController.getMisSesiones);
router.get('/iniciar', isAuthenticated, entrevistaController.getIniciar);
router.post('/iniciar', isAuthenticated, entrevistaController.postIniciar);
router.get('/analizar-cv', isAuthenticated, entrevistaController.getAnalizarCV);
router.post('/analizar-cv', isAuthenticated, entrevistaController.postAnalizarCV);
router.get('/:id', isAuthenticated, entrevistaController.getSala);
router.post('/:id/responder', isAuthenticated, entrevistaController.postResponder);
router.get('/:id/reporte', isAuthenticated, entrevistaController.getReporte);
router.get('/:id/pdf', isAuthenticated, entrevistaController.getPDF);

module.exports = router;
