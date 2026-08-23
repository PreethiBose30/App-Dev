const mongoose = require('mongoose');
const Asset = require('../models/Asset');
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');

// @route   GET /api/v1/dashboard/stats
// @desc    Current user's vault statistics. There is no shared stock/quantity
//          concept in this app (each item is a personally-owned document/
//          asset, not shelf inventory), so "low stock" / "out of stock" from
//          a generic inventory spec don't apply here -- warranty status is
//          the equivalent signal, so stats are built around that instead.
const getMyStats = asyncHandler(async (req, res) => {
  const userId = new mongoose.Types.ObjectId(req.user.id);
  const now = new Date();
  const in30Days = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);
  const hasWarrantyExpiry = { $ne: [{ $ifNull: ['$warrantyExpiry', null] }, null] };

  const [totals, byCategory] = await Promise.all([
    Asset.aggregate([
      { $match: { user: userId } },
      {
        $group: {
          _id: null,
          totalProducts: { $sum: 1 },
          totalValue: { $sum: { $ifNull: ['$price', 0] } },
          expiringSoon: {
            $sum: {
              $cond: [
                {
                  $and: [
                    hasWarrantyExpiry,
                    { $gte: ['$warrantyExpiry', now] },
                    { $lte: ['$warrantyExpiry', in30Days] },
                  ],
                },
                1,
                0,
              ],
            },
          },
          expired: {
            // hasWarrantyExpiry guard is required: a *missing* warrantyExpiry
            // field is NOT treated as equal to `null` by aggregation $ne/$eq
            // (confirmed empirically -- $type reports "missing", a distinct
            // BSON type), so a bare $lt would wrongly count every
            // "no warranty tracked" item as expired. $ifNull normalizes
            // missing to null first so the null-check actually catches it.
            $sum: {
              $cond: [{ $and: [hasWarrantyExpiry, { $lt: ['$warrantyExpiry', now] }] }, 1, 0],
            },
          },
        },
      },
    ]),
    Asset.aggregate([
      { $match: { user: userId } },
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]),
  ]);

  const summary = totals[0] || { totalProducts: 0, totalValue: 0, expiringSoon: 0, expired: 0 };

  res.status(200).json({
    totalProducts: summary.totalProducts,
    totalValue: summary.totalValue,
    expiringSoon: summary.expiringSoon,
    expired: summary.expired,
    byCategory: byCategory.map((c) => ({ category: c._id, count: c.count })),
  });
});

// @route   GET /api/v1/admin/stats
// @desc    ADMIN ONLY: system-wide metrics. Deliberately aggregate-only --
//          admin does not get read access to any individual user's vault
//          contents (see assetController's ownership check).
const getAdminStats = asyncHandler(async (req, res) => {
  const [totalUsers, totalVaultedDocuments] = await Promise.all([
    User.countDocuments(),
    Asset.countDocuments(),
  ]);

  res.status(200).json({
    systemStatus: 'Optimal',
    totalUsers,
    totalVaultedDocuments,
    accessRole: req.user.role,
  });
});

module.exports = { getMyStats, getAdminStats };
