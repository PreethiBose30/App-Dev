const express = require('express');
const router = express.Router();
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const { getMyStats, getAdminStats } = require('../controllers/dashboardController');

router.get('/dashboard/stats', authenticateToken, getMyStats);
router.get('/admin/stats', authenticateToken, authorizeRoles('admin'), getAdminStats);

module.exports = router;
