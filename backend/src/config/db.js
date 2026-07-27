const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
    return;
  } catch (error) {
    console.error(`Database Connection Error: ${error.message}`);
    console.warn('No MongoDB available — falling back to in-memory JS stores for development/testing');
    // Signal other modules to use in-memory fallback
    global.__USE_IN_MEMORY_DB = true;
  }

  // Fallback: start an in-memory MongoDB (for local dev when no Mongo running)
  try {
    const { MongoMemoryServer } = require('mongodb-memory-server');
    const mongod = await MongoMemoryServer.create();
    const uri = mongod.getUri();
    const conn = await mongoose.connect(uri);
    console.log(`Connected to in-memory MongoDB: ${conn.connection.host}`);
  } catch (err) {
    console.error('In-memory MongoDB failed to start:', err.message);
  }
};

module.exports = connectDB;
