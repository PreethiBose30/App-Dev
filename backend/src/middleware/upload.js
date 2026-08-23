const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { ApiError } = require('./errorHandler');

// Files live outside the request context so restarts/redeploys don't lose
// them, one folder per user for trivial isolation on disk (ownership is
// still enforced at the route/controller level regardless).
const UPLOAD_ROOT = path.resolve(__dirname, '../../uploads');

const ALLOWED_TYPES = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'application/pdf': '.pdf',
};

const storage = multer.diskStorage({
  destination: (req, _file, cb) => {
    const dir = path.join(UPLOAD_ROOT, req.user.id);
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  // One document per asset: naming the file after the asset id means a
  // re-upload simply overwrites the previous one (extension-agnostic
  // cleanup is handled in the controller since the old and new file types
  // may differ).
  filename: (req, file, cb) => {
    cb(null, `${req.params.id}${ALLOWED_TYPES[file.mimetype]}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (_req, file, cb) => {
    // A plain ApiError here (not multer.MulterError -- its message is
    // looked up from a fixed table by code, ignoring whatever string is
    // passed) so the client gets an accurate reason, not "Unexpected field".
    if (!ALLOWED_TYPES[file.mimetype]) {
      return cb(new ApiError(400, 'Only JPEG, PNG, or PDF files are allowed'));
    }
    cb(null, true);
  },
});

module.exports = { upload, UPLOAD_ROOT, ALLOWED_TYPES };
