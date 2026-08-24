const { validationResult } = require('express-validator');

// Run after express-validator's body()/query() chains. Returns 422 Validation
// Error (not 200/500) so the frontend can distinguish bad input from a
// server failure.
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ message: 'Validation failed', errors: errors.array() });
  }
  next();
};

module.exports = validate;
