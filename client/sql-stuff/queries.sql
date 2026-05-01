
-- @block

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS commercial;

SET FOREIGN_KEY_CHECKS = 1;


-- @block
SELECT * FROM property;

-- @block
DELETE FROM Residential WHERE property_id = 4;

-- @block
SELECT * FROM commercial;

-- @block
SELECT * FROM Residential WHERE property_id = 4;