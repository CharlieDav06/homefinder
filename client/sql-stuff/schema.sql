CREATE TABLE User (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone_number VARCHAR(20),
  gdpr_consent_given BOOLEAN NOT NULL
);

CREATE TABLE AuthService (
  auth_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  max_login_attempts INT NOT NULL,
  token_expiry_time INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES 'User'(user_id)
);

CREATE TABLE '2FA' (
  auth_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token_value VARCHAR(10) NOT NULL,
  time_created DATETIME NOT NULL,
  is_used BOOLEAN NOT NULL,
  retry_count INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES User(user_id),
  FOREIGN KEY (auth_id) REFERENCES AuthService(auth_id)
);

CREATE TABLE Session (
  session_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  auth_id INT NOT NULL,
  session_start_time DATETIME NOT NULL,
  last_input_time DATETIME,
  ip_address VARCHAR(45),
  is_active BOOLEAN NOT NULL,
  FOREIGN KEY (user_id) REFERENCES User(user_id),
  FOREIGN KEY (auth_id) REFERENCES AuthService(auth_id)
);

CREATE TABLE Admin (
  user_id INT PRIMARY KEY,
  admin_level INT NOT NULL,
  permissions VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES User(user_id)
);

CREATE TABLE Supervisor (
  user_id INT PRIMARY KEY,
  supervisor_role VARCHAR(100) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- @block
CREATE TABLE Report (
  report_id INT AUTO_INCREMENT PRIMARY KEY,
  property_id INT NOT NULL,
  user_id INT NOT NULL,
  month DATETIME NOT NULL,
  total_inquiries INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Supervisor(user_id),
  FOREIGN KEY (property_id) REFERENCES Property(property_id)
);

-- @block
CREATE TABLE Property (
  property_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  location VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  image_url VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES Admin(user_id)
);

-- @block
CREATE TABLE Residential (
  property_id INT PRIMARY KEY,
  num_bedrooms INT NOT NULL,
  is_furnished BOOLEAN NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (property_id) REFERENCES Property(property_id)
);

-- @block
CREATE TABLE Commercial (
  property_id INT PRIMARY KEY,
  square_ft INT NOT NULL,
  floors INT NOT NULL,
  property_usage VARCHAR(100) NOT NULL,
  has_parking BOOLEAN NOT NULL,
  zoning_type VARCHAR(100) NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (property_id) REFERENCES Property(property_id)
);

-- @block
CREATE TABLE Rental (
  property_id INT PRIMARY KEY,
  monthly_rent DECIMAL(10,2) NOT NULL,
  security_deposit DECIMAL(10,2) NOT NULL,
  lease_duration INT NOT NULL,
  is_pet_friendly BOOLEAN NOT NULL,
  lease_terms VARCHAR(255),
  is_furnished BOOLEAN NOT NULL,

  FOREIGN KEY (property_id) REFERENCES Property(property_id)
);