const mongoose = require('mongoose');

/**
 * Strips accidental wrapping quotes and leading/trailing whitespace.
 */
function cleanMongoUri(rawUri) {
  if (!rawUri || typeof rawUri !== 'string') return '';
  let uri = rawUri.trim();
  if (
    (uri.startsWith('"') && uri.endsWith('"')) ||
    (uri.startsWith("'") && uri.endsWith("'"))
  ) {
    uri = uri.slice(1, -1).trim();
  }
  return uri;
}

/**
 * Masks credentials for secure logging without exposing passwords.
 */
function maskMongoUri(uri) {
  if (!uri) return '<EMPTY>';
  return uri.replace(
    /^(mongodb(?:\+srv)?:\/\/)([^:]+):([^@]+)@/i,
    (match, protocol, user) => `${protocol}${user}:*****@`
  );
}

/**
 * Validates connection string structure and catches common configuration mistakes.
 * Returns false if the URI is invalid, preventing connection attempts.
 */
function validateMongoUri(uri) {
  if (!uri) {
    console.error('❌ [MongoDB Error] MONGO_URI environment variable is not defined.');
    console.error('👉 Fix: Go to Render Dashboard -> Environment -> Add MONGO_URI.');
    return false;
  }

  // Detect unreplaced template placeholders
  if (/<password>|<db_password>|<username>|<dbname>/i.test(uri)) {
    console.error('❌ [MongoDB Error] MONGO_URI contains an unreplaced placeholder (e.g. "<password>").');
    console.error('👉 Fix: Replace <password> with your actual MongoDB user password in Render Environment.');
    console.error('👉 Note: Be sure to remove the angle brackets "<" and ">" as well.');
    return false;
  }

  // Detect unencoded '@' in password (causes 'bad auth' or invalid host)
  const atMatches = uri.match(/@/g);
  if (atMatches && atMatches.length > 1) {
    console.warn('⚠️ [MongoDB Warning] Multiple "@" symbols detected in MONGO_URI.');
    console.warn('👉 If your password contains an "@", it must be URL-encoded as "%40".');
  }

  return true;
}

/**
 * Connects to MongoDB with retry logic and clear diagnostics.
 * Uses the database name specified in MONGO_URI without arbitrary overrides.
 */
const connectDB = async (retries = 3, delayMs = 4000) => {
  const rawUri = process.env.MONGO_URI;
  const uri = cleanMongoUri(rawUri);

  console.log(`🔌 Attempting MongoDB connection to: ${maskMongoUri(uri)}`);

  // Stop immediately if the URI is invalid; do not attempt connection
  if (!validateMongoUri(uri)) {
    console.error('💥 Aborting database connection attempt due to invalid MONGO_URI configuration.');
    process.exit(1);
  }

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      // Ensure any previous failed connection attempt is cleanly closed
      if (mongoose.connection.readyState !== 0) {
        await mongoose.disconnect();
      }

      // Connect strictly using the URI and its embedded database name
      const conn = await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 10000,
      });

      console.log(`✅ MongoDB Connected Successfully: ${conn.connection.host}`);
      if (conn.connection.name) {
        console.log(`📦 Database: ${conn.connection.name}`);
      }
      return conn;
    } catch (error) {
      console.error(`❌ Database Connection Error (Attempt ${attempt}/${retries}): ${error.message}`);

      // Provide targeted troubleshooting for authentication failures
      if (/auth|authentication/i.test(error.message)) {
        console.error('─────────────────────────────────────────────────────────────────');
        console.error('🔍 MongoDB Authentication Failure Diagnostics:');
        console.error(' 1. Check your MongoDB Atlas Database User:');
        console.error('    - Go to MongoDB Atlas -> Security -> Database Access.');
        console.error('    - Ensure the username matches exactly (case-sensitive).');
        console.error('    - Ensure the user has "Read and write to any database" privileges.');
        console.error(' 2. Check your Password:');
        console.error('    - Make sure you used the Database User password, NOT your Atlas cloud login password.');
        console.error('    - If password has special characters (@, #, $, %, etc.), URL-encode them:');
        console.error('      @ -> %40, # -> %23, $ -> %24, % -> %25, + -> %2B, / -> %2F');
        console.error(' 3. Check Network Access:');
        console.error('    - Go to MongoDB Atlas -> Security -> Network Access.');
        console.error('    - Ensure Network Access allows traffic from your Render backend service (e.g. Render\'s outbound IP addresses or your designated hosting IP range).');
        console.error('─────────────────────────────────────────────────────────────────');
      }

      if (attempt < retries) {
        console.log(`⏳ Retrying in ${delayMs / 1000} seconds...`);
        await new Promise((resolve) => setTimeout(resolve, delayMs));
      } else {
        console.error('💥 All MongoDB connection attempts failed.');
        throw error;
      }
    }
  }
};

module.exports = connectDB;
