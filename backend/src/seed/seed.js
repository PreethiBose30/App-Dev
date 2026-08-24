// Development seed data. Run with: npm run seed
// Wipes and repopulates Users + Assets with demo accounts and sample items
// so the app has something to show without manual data entry.
const path = require('path');
const dotenv = require('dotenv');
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const connectDB = require('../config/db');
const User = require('../models/User');
const Asset = require('../models/Asset');

const monthsAgo = (n) => {
  const d = new Date();
  d.setMonth(d.getMonth() - n);
  return d;
};

const run = async () => {
  await connectDB();

  await User.deleteMany({});
  await Asset.deleteMany({});

  const admin = await User.create({
    name: 'Admin Demo',
    email: 'admin@digitalvault.dev',
    password: 'Admin@123',
    role: 'admin',
  });

  const user = await User.create({
    name: 'Preethi Demo',
    email: 'user@digitalvault.dev',
    password: 'User@123',
    role: 'user',
  });

  await Asset.create([
    {
      user: user._id,
      name: 'iPhone 15',
      category: 'Phone',
      brand: 'Apple',
      modelNumber: 'A3092',
      price: 79900,
      purchaseDate: monthsAgo(2),
      warrantyDurationMonths: 12,
      reminderEnabled: true,
    },
    {
      user: user._id,
      name: 'MacBook Air M2',
      category: 'Laptop',
      brand: 'Apple',
      modelNumber: 'A2681',
      price: 114900,
      purchaseDate: monthsAgo(11),
      warrantyDurationMonths: 12, // expires soon
      reminderEnabled: true,
    },
    {
      user: user._id,
      name: 'Samsung Refrigerator',
      category: 'Appliance',
      brand: 'Samsung',
      price: 45000,
      purchaseDate: monthsAgo(30),
      warrantyDurationMonths: 24, // already expired
    },
    {
      user: user._id,
      name: 'Office Chair',
      category: 'Furniture',
      brand: 'IKEA',
      price: 8500,
      purchaseDate: monthsAgo(1),
      warrantyDurationMonths: 0, // no warranty tracked
      notes: 'Assembled by service technician',
    },
  ]);

  console.log('Seed complete.');
  console.log('Demo credentials:');
  console.log(`  admin: ${admin.email} / Admin@123`);
  console.log(`  user:  ${user.email} / User@123`);
  process.exit(0);
};

run().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
