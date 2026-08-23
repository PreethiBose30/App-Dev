const express = require('express');
const router = express.Router();
const { body, param, query } = require('express-validator');
const validate = require('../middleware/validate');
const { authenticateToken } = require('../middleware/auth');
const { upload } = require('../middleware/upload');
const {
  listAssets,
  getAsset,
  createAsset,
  updateAsset,
  deleteAsset,
  uploadDocument,
  getDocument,
  deleteDocument,
} = require('../controllers/assetController');

router.use(authenticateToken);

const assetBodyRules = [
  body('name').optional().isString().trim().notEmpty().withMessage('Name cannot be empty'),
  body('category').optional().isString().trim(),
  body('brand').optional().isString().trim(),
  body('modelNumber').optional().isString().trim(),
  body('price').optional().isFloat({ min: 0 }).withMessage('Price must be a positive number'),
  body('purchaseDate').optional().isISO8601().toDate(),
  body('warrantyDurationMonths').optional().isInt({ min: 0 }).withMessage('Warranty duration must be a positive integer'),
  body('serviceDate').optional().isISO8601().toDate(),
  body('notes').optional().isString().trim(),
  body('reminderEnabled').optional().isBoolean().toBoolean(),
];

router.get(
  '/assets',
  [query('search').optional().isString().trim(), query('category').optional().isString().trim()],
  validate,
  listAssets
);

router.get('/assets/:id', [param('id').isMongoId()], validate, getAsset);

router.post(
  '/assets',
  [body('name').isString().trim().notEmpty().withMessage('Name is required'), ...assetBodyRules],
  validate,
  createAsset
);

router.put('/assets/:id', [param('id').isMongoId(), ...assetBodyRules], validate, updateAsset);

router.delete('/assets/:id', [param('id').isMongoId()], validate, deleteAsset);

// Document upload: multer parses the multipart body and validates
// type/size before the controller ever runs; ownership is still checked
// inside the controller itself (multer doesn't know about that).
router.post('/assets/:id/document', [param('id').isMongoId()], validate, upload.single('document'), uploadDocument);
router.get('/assets/:id/document', [param('id').isMongoId()], validate, getDocument);
router.delete('/assets/:id/document', [param('id').isMongoId()], validate, deleteDocument);

module.exports = router;
