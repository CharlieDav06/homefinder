// Import required modules
const express = require("express");
const cors = require("cors");

// Create Express application (Application Layer entry point)
const app = express();

// Middleware setup
app.use(cors());              // Enables cross-origin requests (frontend ↔ backend)
app.use(express.json());      // Parses incoming JSON data


// MOCK DATA (represents Database Layer)

let properties = [
    { id: 1, title: "2 Bed Apartment", location: "London", price: 1200 },
    { id: 2, title: "Office Space", location: "Manchester", price: 3000 }
];


// AUTH CONTROLLER (from UML: AuthService / User)

app.post("/login", (req, res) => {
    const { email, password } = req.body;

    // Basic authentication logic (to be replaced with DB + hashing)
    if (email === "test@test.com" && password === "1234") {
        res.json({ success: true });   // Successful login response
    } else {
        res.json({ success: false });  // Failed login response
    }
});


// PROPERTY CONTROLLER (from UML: PropertyController)

app.get("/properties", (req, res) => {
    res.json(properties); // Returns all properties
});


// SEARCH FUNCTION (UML: FilterCriteria)

app.get("/search", (req, res) => {
    const { location } = req.query;

    // Filters properties based on location input
    const result = properties.filter(p =>
        p.location.toLowerCase().includes(location.toLowerCase())
    );

    res.json(result);
});


// BOOKING CONTROLLER (UML: ViewingReservation)

app.post("/book", (req, res) => {
    // In a full system, booking would be stored in database
    res.json({ message: "Booking confirmed!" });
});

// Start server
app.listen(3000, () => console.log("Server running on port 3000"));
