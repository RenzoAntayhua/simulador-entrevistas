const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { isAdmin } = require('../middlewares/authMiddleware');

router.get('/', isAdmin, adminController.getDashboard);
router.get('/usuarios', isAdmin, adminController.getUsuarios);
router.post('/usuarios/:id/toggle', isAdmin, adminController.toggleUsuario);
router.post('/usuarios/:id/rol', isAdmin, adminController.cambiarRol);
router.get('/retos', isAdmin, adminController.getRetos);
router.post('/retos/:id/delete', isAdmin, adminController.deleteReto);
router.get('/bancos', isAdmin, adminController.getBancos);
router.post('/bancos/:id/delete', isAdmin, adminController.deleteBanco);
router.get('/reporte/pdf', isAdmin, adminController.generarReportePDF);

module.exports = router;
