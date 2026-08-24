const fs = require('fs/promises');
const path = require('path');
const Asset = require('../models/Asset');
const asyncHandler = require('../utils/asyncHandler');
const { ApiError } = require('../middleware/errorHandler');
const { UPLOAD_ROOT } = require('../middleware/upload');

const ASSET_FIELDS = [
  'name', 'category', 'brand', 'modelNumber', 'price',
  'purchaseDate', 'warrantyDurationMonths', 'serviceDate',
  'notes', 'reminderEnabled',
];

const pickFields = (body) => {
  const data = {};
  for (const field of ASSET_FIELDS) {
    if (body[field] !== undefined) data[field] = body[field];
  }
  return data;
};

// Each user's vault is private -- ownership is checked on every read/write
// of a single asset, admin included. Admin's elevated role only grants
// access to aggregate stats (see dashboardController), never to another
// user's items.
const loadOwnedAsset = async (req) => {
  const asset = await Asset.findById(req.params.id);
  if (!asset) throw new ApiError(404, 'Asset not found');
  if (asset.user.toString() !== req.user.id) {
    throw new ApiError(403, 'Access denied: you do not own this item');
  }
  return asset;
};

const documentPathOnDisk = (asset) => path.join(UPLOAD_ROOT, asset.user.toString(), asset.imagePath);

const deleteDocumentFile = async (asset) => {
  if (!asset.imagePath) return;
  try {
    await fs.unlink(documentPathOnDisk(asset));
  } catch (err) {
    if (err.code !== 'ENOENT') throw err;
  }
};

// @route   GET /api/v1/assets?search=&category=
const listAssets = asyncHandler(async (req, res) => {
  const { search, category } = req.query;
  const filter = { user: req.user.id };

  if (category) filter.category = new RegExp(`^${category}$`, 'i');
  if (search) {
    const term = new RegExp(search, 'i');
    filter.$or = [{ name: term }, { brand: term }, { modelNumber: term }];
  }

  const assets = await Asset.find(filter).sort({ createdAt: -1 });
  res.status(200).json(assets);
});

// @route   GET /api/v1/assets/:id
const getAsset = asyncHandler(async (req, res) => {
  const asset = await loadOwnedAsset(req);
  res.status(200).json(asset);
});

// @route   POST /api/v1/assets
const createAsset = asyncHandler(async (req, res) => {
  const asset = await Asset.create({ ...pickFields(req.body), user: req.user.id });
  res.status(201).json({ message: 'Asset created', asset });
});

// @route   PUT /api/v1/assets/:id
const updateAsset = asyncHandler(async (req, res) => {
  const asset = await loadOwnedAsset(req);
  Object.assign(asset, pickFields(req.body));
  await asset.save();
  res.status(200).json({ message: 'Asset updated', asset });
});

// @route   DELETE /api/v1/assets/:id
const deleteAsset = asyncHandler(async (req, res) => {
  const asset = await loadOwnedAsset(req);
  await deleteDocumentFile(asset);
  await asset.deleteOne();
  res.status(200).json({ message: 'Asset deleted', id: req.params.id });
});

// @route   POST /api/v1/assets/:id/document
// @desc    Upload (or replace) the scanned bill/warranty document for an
//          asset. multer has already validated type/size and written the
//          file to disk by the time this runs; this just records it and
//          cleans up whatever was there before.
const uploadDocument = asyncHandler(async (req, res) => {
  const asset = await loadOwnedAsset(req);
  if (!req.file) throw new ApiError(400, 'No file uploaded');

  const previousPath = asset.imagePath && asset.imagePath !== req.file.filename ? documentPathOnDisk(asset) : null;

  asset.imagePath = req.file.filename;
  asset.documentOriginalName = req.file.originalname;
  asset.documentMimeType = req.file.mimetype;
  await asset.save();

  if (previousPath) {
    try {
      await fs.unlink(previousPath);
    } catch (err) {
      if (err.code !== 'ENOENT') throw err;
    }
  }

  res.status(200).json({ message: 'Document uploaded', asset });
});

// @route   GET /api/v1/assets/:id/document
const getDocument = asyncHandler(async (req, res) => {
  const asset = await loadOwnedAsset(req);
  if (!asset.imagePath) throw new ApiError(404, 'No document on file for this asset');

  res.setHeader('Content-Type', asset.documentMimeType || 'application/octet-stream');
  res.setHeader('Content-Disposition', `inline; filename="${asset.documentOriginalName || asset.imagePath}"`);
  res.sendFile(documentPathOnDisk(asset), (err) => {
    if (err && !res.headersSent) {
      res.status(404).json({ message: 'Document file is missing on the server' });
    }
  });
});

// @route   DELETE /api/v1/assets/:id/document
const deleteDocument = asyncHandler(async (req, res) => {
  const asset = await loadOwnedAsset(req);
  await deleteDocumentFile(asset);
  asset.imagePath = undefined;
  asset.documentOriginalName = undefined;
  asset.documentMimeType = undefined;
  await asset.save();
  res.status(200).json({ message: 'Document removed', asset });
});

module.exports = {
  listAssets,
  getAsset,
  createAsset,
  updateAsset,
  deleteAsset,
  uploadDocument,
  getDocument,
  deleteDocument,
};
