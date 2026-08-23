const mongoose = require('mongoose');

// Connects to the MongoDB URI from the environment. If none is configured
// (or the connection fails) during local development, falls back to an
// in-memory MongoDB instance so the API is still fully functional --
// every route still goes through real Mongoose models and real queries,
// the only difference is where the data physically lives.
const connectDB = async () => {
  const uri = process.env.MONGO_URI;

  if (uri) {
    try {
      const conn = await mongoose.connect(uri);
      console.log(`MongoDB connected: ${conn.connection.host}`);
      return;
    } catch (error) {
      console.error(`Could not connect to MONGO_URI: ${error.message}`);
    }
  } else {
    console.warn('MONGO_URI not set.');
  }

  console.warn('Falling back to an in-memory MongoDB instance for local development. Data will NOT persist between restarts -- set MONGO_URI in backend/.env to use a real database.');

  const { MongoMemoryServer } = require('mongodb-memory-server');
  const mongod = await MongoMemoryServer.create();
  const memoryUri = mongod.getUri();
  const conn = await mongoose.connect(memoryUri);
  console.log(`Connected to in-memory MongoDB: ${conn.connection.host}`);
};

module.exports = connectDB;
