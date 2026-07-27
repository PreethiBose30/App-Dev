const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const bcrypt = require('bcryptjs');

// In-memory fallback stores (used when no MongoDB available)
const devUsers = global.__DEV_USERS || [];
global.__DEV_USERS = devUsers;

// Helper to sign JWT
const generateToken = (id, role) => {
  return jwt.sign({ id, role }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

// @route   POST /api/v1/auth/register
// @desc    Register a new user (default role: user)
router.post(
  '/register',
  [
    body('name').isString().trim().notEmpty().withMessage('Name is required'),
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { name, email, password, role } = req.body;

      // If using in-memory fallback
      if (global.__USE_IN_MEMORY_DB) {
        if (devUsers.find(u => u.email === email)) return res.status(400).json({ message: 'User already exists' });
        const hashed = await bcrypt.hash(password, 10);
        const user = { _id: `${Date.now()}`, name, email, password: hashed, role: role || 'user' };
        devUsers.push(user);
        return res.status(201).json({
          message: 'Account created successfully (in-memory)',
          token: generateToken(user._id, user.role),
          user: { id: user._id, name: user.name, email: user.email, role: user.role }
        });
      }

      const userExists = await User.findOne({ email });
      if (userExists) return res.status(400).json({ message: 'User already exists' });

      const user = await User.create({
        name,
        email,
        password,
        role: role || 'user'
      });

      res.status(201).json({
        message: 'Account created successfully',
        token: generateToken(user._id, user.role),
        user: { id: user._id, name: user.name, email: user.email, role: user.role }
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// @route   POST /api/v1/auth/login
// @desc    Authenticate user & get token
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').exists().withMessage('Password is required')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { email, password } = req.body;

      if (global.__USE_IN_MEMORY_DB) {
        const user = devUsers.find(u => u.email === email);
        if (!user) return res.status(401).json({ message: 'Invalid email or password' });
        const ok = await bcrypt.compare(password, user.password);
        if (!ok) return res.status(401).json({ message: 'Invalid email or password' });
        return res.status(200).json({
          message: 'Authorization successful (in-memory)',
          token: generateToken(user._id, user.role),
          user: { id: user._id, name: user.name, email: user.email, role: user.role }
        });
      }

      const user = await User.findOne({ email });
      if (!user || !(await user.matchPassword(password))) {
        return res.status(401).json({ message: 'Invalid email or password' });
      }

      res.status(200).json({
        message: 'Authorization successful',
        token: generateToken(user._id, user.role),
        user: { id: user._id, name: user.name, email: user.email, role: user.role }
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

module.exports = router;
