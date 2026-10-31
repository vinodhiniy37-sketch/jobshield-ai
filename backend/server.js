const app = require('./app');
const connectDB = require('./config/db');

const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0';

/**
 * Initializes database connection before starting the HTTP server.
 * Guarantees the API does not report healthy before MongoDB is connected.
 */
async function startServer() {
  try {
    // 1. Establish database connection first
    await connectDB();

    // 2. Start HTTP server only after database connection succeeds
    const server = app.listen(PORT, HOST, () => {
      console.log(`🚀 Server listening on ${HOST}:${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (err) => {
      console.error(`Unhandled Rejection: ${err.message}`);
      server.close(() => process.exit(1));
    });
  } catch (error) {
    console.error(`💥 Server failed to start: ${error.message}`);
    process.exit(1);
  }
}

startServer();
