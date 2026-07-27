const express = require('express');
const router = express.Router();
const Asset = require('../models/Asset');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
// In-memory fallback store for assets
const devAssets = global.__DEV_ASSETS || [];
global.__DEV_ASSETS = devAssets;

const { body, validationResult } = require('express-validator');

// @route   POST /api/v1/assets
// @desc    Upload / Sync asset record from Flutter (Offline Hive -> Online MongoDB)
router.post(
  '/assets',
  authenticateToken,
  [
    body('title').isString().trim().notEmpty().withMessage('Title is required'),
    body('category').optional().isString(),
    body('purchaseDate').optional().isISO8601().toDate(),
    body('warrantyDurationMonths').optional().isInt({ min: 0 })
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { title, category, purchaseDate, warrantyDurationMonths, imagePath } = req.body;

      if (global.__USE_IN_MEMORY_DB) {
        const asset = {
          _id: `${Date.now()}`,
          user: req.user.id,
          title,
          category,
          purchaseDate,
          warrantyDurationMonths,
          imagePath,
          createdAt: new Date()
        };
        devAssets.push(asset);
        return res.status(201).json({ message: 'Asset synced to in-memory store', asset });
      }

      const asset = await Asset.create({
        user: req.user.id,
        title,
        category,
        purchaseDate,
        warrantyDurationMonths,
        imagePath
      });

      res.status(201).json({ message: 'Asset synced to MongoDB', asset });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// @route   GET /api/v1/assets
// @desc    Get user's vaulted items
router.get('/assets', authenticateToken, async (req, res) => {
  try {
    if (global.__USE_IN_MEMORY_DB) {
      const assets = devAssets.filter(a => a.user === req.user.id).sort((a,b)=> new Date(b.createdAt) - new Date(a.createdAt));
      return res.status(200).json(assets);
    }
    const assets = await Asset.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.status(200).json(assets);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// @route   GET /api/v1/admin/stats
// @desc    ADMIN ONLY: System metrics dashboard
router.get('/admin/stats', authenticateToken, authorizeRoles('admin'), async (req, res) => {
  try {
    if (global.__USE_IN_MEMORY_DB) {
      return res.status(200).json({ systemStatus: 'Optimal', totalVaultedDocuments: devAssets.length, accessRole: req.user.role });
    }
    const totalAssets = await Asset.countDocuments();
    res.status(200).json({
      systemStatus: 'Optimal',
      totalVaultedDocuments: totalAssets,
      accessRole: req.user.role
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
