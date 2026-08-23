const mongoose = require('mongoose');

const assetSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },

    name: { type: String, required: true, trim: true },
    category: { type: String, required: true, trim: true, default: 'Other' },
    brand: { type: String, trim: true },
    modelNumber: { type: String, trim: true },
    price: { type: Number, min: 0 },

    purchaseDate: { type: Date },
    warrantyDurationMonths: { type: Number, min: 0, default: 0 },
    // Derived from purchaseDate + warrantyDurationMonths, recomputed on save.
    warrantyExpiry: { type: Date },
    serviceDate: { type: Date },

    notes: { type: String, trim: true },
    // Set only by the upload controller (POST /assets/:id/document), never
    // directly from client-supplied create/update bodies -- imagePath is
    // the server-generated on-disk filename (<assetId>.<ext>), not a raw
    // path the client can point anywhere.
    imagePath: { type: String },
    documentOriginalName: { type: String },
    documentMimeType: { type: String },
    reminderEnabled: { type: Boolean, default: false },
  },
  { timestamps: true }
);

assetSchema.pre('save', function () {
  if (this.purchaseDate && this.warrantyDurationMonths > 0) {
    const expiry = new Date(this.purchaseDate);
    expiry.setMonth(expiry.getMonth() + this.warrantyDurationMonths);
    this.warrantyExpiry = expiry;
  } else {
    this.warrantyExpiry = undefined;
  }
});

module.exports = mongoose.model('Asset', assetSchema);
