const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const asyncHandler = require('../utils/asyncHandler');
const { ApiError } = require('../middleware/errorHandler');

// @route   POST /api/v1/auth/register
// @desc    Register a new user (role defaults to 'user'; 'admin' cannot be
//          self-assigned through this endpoint)
const register = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;

  const userExists = await User.findOne({ email });
  if (userExists) throw new ApiError(409, 'A user with that email already exists');

  const user = await User.create({ name, email, password, role: 'user' });

  res.status(201).json({
    message: 'Account created successfully',
    token: generateToken(user._id, user.role),
    user: { id: user._id, name: user.name, email: user.email, role: user.role },
  });
});

// @route   POST /api/v1/auth/login
const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select('+password');
  if (!user || !(await user.matchPassword(password))) {
    throw new ApiError(401, 'Invalid email or password');
  }

  res.status(200).json({
    message: 'Authorization successful',
    token: generateToken(user._id, user.role),
    user: { id: user._id, name: user.name, email: user.email, role: user.role },
  });
});

// @route   GET /api/v1/auth/me
const getMe = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user) throw new ApiError(404, 'User not found');

  res.status(200).json({ id: user._id, name: user.name, email: user.email, role: user.role });
});

module.exports = { register, login, getMe };
