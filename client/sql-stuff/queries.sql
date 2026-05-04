
-- @block

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS property;

SET FOREIGN_KEY_CHECKS = 1;


-- @block
SELECT * FROM property;

-- @block
DELETE FROM Residential WHERE property_id = 4;

-- @block
SELECT * FROM commercial;

-- @block
SELECT * FROM commercial;

-- @block
SELECT * FROM rental;


-- @block
ALTER TABLE Property ADD COLUMN owner_email VARCHAR(100)



-- @block
DELETE FROM Residential;
DELETE FROM Rental;
DELETE FROM Commercial;
DELETE FROM Property;
ALTER TABLE property AUTO_INCREMENT = 1;


-- @block
DROP TABLE Residential;
DROP TABLE Rental;
DROP TABLE Commercial;
DROP TABLE Property;

-- @block
ALTER TABLE Residential MODIFY COLUMN price INT NOT NULL;
ALTER TABLE Commercial MODIFY COLUMN price INT NOT NULL;