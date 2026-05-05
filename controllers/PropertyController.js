/**
 * Property Controller (Application Layer)
 * Handles incoming requests related to properties
 */

// Temporary in-memory storage (simulates database)
const properties = [];

/**
 * Retrieves all properties
 * Maps to: Property.getAll() in UML logic
 */
exports.getAll = (req, res) => {
    res.json(properties);
};

/**
 * Searches properties using filter criteria
 * Maps to UML: FilterCriteria class
 */
exports.search = (req, res) => {
    const { location } = req.query;

    const result = properties.filter(p =>
        p.location.toLowerCase().includes(location.toLowerCase())
    );

    res.json(result);
};