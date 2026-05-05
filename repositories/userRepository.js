const db = require("../db");

/**
 * Find user by email
 */
exports.findByEmail = (email, callback) => {
    db.query(
        "SELECT * FROM users WHERE email = ?",
        [email],
        callback
    );
};

/**
 * Create new user (registration)
 */
exports.createUser = (email, password, callback) => {
    db.query(
        "INSERT INTO users (email, password) VALUES (?, ?)",
        [email, password],
        callback
    );
};