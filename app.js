const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

let properties = [
    { id: 1, title: "2 Bed Apartment", location: "London", price: 1200 },
    { id: 2, title: "Office Space", location: "Manchester", price: 3000 }
];

// LOGIN
app.post("/login", (req, res) => {
    const { email, password } = req.body;

    if (email === "test@test.com" && password === "1234") {
        res.json({ success: true });
    } else {
        res.json({ success: false });
    }
});

// GET PROPERTIES
app.get("/properties", (req, res) => {
    res.json(properties);
});

// SEARCH
app.get("/search", (req, res) => {
    const { location } = req.query;
    const result = properties.filter(p =>
        p.location.toLowerCase().includes(location.toLowerCase())
    );
    res.json(result);
});

// BOOKING
app.post("/book", (req, res) => {
    res.json({ message: "Booking confirmed!" });
});

app.listen(3000, () => console.log("Server running"));