const mongoose = require('mongoose');

const assetSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  category: { type: String, default: 'General' },
  purchaseDate: { type: Date, default: Date.now },
  warrantyDurationMonths: { type: Number, default: 12 },
  imagePath: { type: String }, // Local or Cloud URL to document image
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Asset', assetSchema);
