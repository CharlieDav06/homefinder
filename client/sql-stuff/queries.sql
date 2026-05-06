ALTER TABLE user MODIFY COLUMN phone_number VARCHAR(20) NULL DEFAULT NULL;
ALTER TABLE user MODIFY COLUMN gdpr_consent_given BOOLEAN NULL DEFAULT NULL;


-- @block
SELECT * FROM residential;

-- @block
ALTER TABLE Session DROP FOREIGN KEY session_ibfk_2;
ALTER TABLE Session DROP COLUMN auth_id;

-- @block
SELECT * FROM Session;



-- @block
INSERT INTO Admin (user_id, admin_level, permissions) 
VALUES (18, 1, 'all');


