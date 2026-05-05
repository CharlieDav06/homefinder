const bcrypt = require("bcrypt");
const userRepo = require("../repositories/userRepository");

/**
 * Register new user
 */
exports.register = async (req, res) => {
    const { email, password } = req.body;

    // Basic validation
    if (!email || !password) {
        return res.status(400).json({ error: "Missing fields" });
    }

    // Check if user already exists
    userRepo.findByEmail(email, async (err, results) => {
        if (err) return res.status(500).json(err);

        if (results.length > 0) {
            return res.json({ success: false, message: "User already exists" });
        }

        try {
            // Hash password
            const hashedPassword = await bcrypt.hash(password, 10);

            // Save user
            userRepo.createUser(email, hashedPassword, (err) => {
                if (err) return res.status(500).json(err);

                res.json({ success: true, message: "User registered successfully" });
            });

        } catch (error) {
            res.status(500).json(error);
        }
    });
};