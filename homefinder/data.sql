-- ============================================================
-- HomeFinder Portal - Seed Data
-- Run after schema.sql: mysql -u root -p homefinder < data.sql
-- ============================================================

USE homefinder;

-- ── Agents ────────────────────────────────────────────────────
INSERT INTO agents (name, email, phone, photo_url, bio) VALUES
('Sarah Mitchell',   'sarah.mitchell@homefinder.co.uk',  '01234 567890', 'https://randomuser.me/api/portraits/women/44.jpg', 'Senior property consultant with 12 years experience across Hampshire and Surrey.'),
('James Hartley',    'james.hartley@homefinder.co.uk',   '01234 567891', 'https://randomuser.me/api/portraits/men/32.jpg',   'Specialist in coastal and countryside properties throughout the South of England.'),
('Priya Sharma',     'priya.sharma@homefinder.co.uk',    '01234 567892', 'https://randomuser.me/api/portraits/women/68.jpg', 'Helping first-time buyers and investors find their perfect property since 2015.'),
('Tom Blackwood',    'tom.blackwood@homefinder.co.uk',   '01234 567893', 'https://randomuser.me/api/portraits/men/55.jpg',   'Expert in new-build developments and off-plan purchases across the South Coast.'),
('Emma Clarke',      'emma.clarke@homefinder.co.uk',     '01234 567894', 'https://randomuser.me/api/portraits/women/12.jpg', 'Dedicated to matching buyers with character properties and period homes.');

-- ── Users ─────────────────────────────────────────────────────
-- passwords are all "password123" hashed with werkzeug
INSERT INTO users (first_name, last_name, email, phone, password_hash) VALUES
('Alice',   'Thompson', 'alice@example.com',  '07700 900001', 'pbkdf2:sha256:260000$abc$demo_hash_alice'),
('Bob',     'Patel',    'bob@example.com',    '07700 900002', 'pbkdf2:sha256:260000$def$demo_hash_bob'),
('Charlie', 'Wilson',   'charlie@example.com','07700 900003', 'pbkdf2:sha256:260000$ghi$demo_hash_charlie');

-- ── Properties ────────────────────────────────────────────────
INSERT INTO properties
  (title, description, property_type, listing_type, price, bedrooms, bathrooms, reception_rooms, square_footage,
   address_line1, city, county, postcode, latitude, longitude,
   agent_id, status, has_garden, has_parking, has_garage, is_new_build, energy_rating, main_image_url)
VALUES
-- 1
('Stunning Detached Family Home',
 'A beautifully presented four-bedroom detached house set in a quiet cul-de-sac. The property boasts a large south-facing garden, double garage, and has been fully refurbished throughout. The open-plan kitchen-diner flows onto the garden, perfect for entertaining. Close to excellent schools and transport links.',
 'detached','sale',485000, 4,2,2, 1850,
 '14 Birchwood Close','Winchester','Hampshire','SO22 4RT', 51.0632,-1.3080,
 1,'available', TRUE,TRUE,TRUE,FALSE,'C',
 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&q=80'),
-- 2
('Modern City Centre Flat',
 'A sleek two-bedroom apartment on the fourth floor of a contemporary development in the heart of Southampton. Floor-to-ceiling windows flood the space with natural light. Features an open-plan living area, high-spec kitchen, two bathrooms, and a private balcony with city views. Allocated underground parking included.',
 'flat','sale',295000, 2,2,1, 820,
 'Apt 4F, 12 Harbour Exchange','Southampton','Hampshire','SO14 2LX', 50.9097,-1.4044,
 3,'available', FALSE,TRUE,FALSE,TRUE,'B',
 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80'),
-- 3
('Charming Victorian Terraced House',
 'A gorgeous period home retaining many original features including sash windows, high ceilings, and ornate coving. Three bedrooms, a contemporary family bathroom, and a lovely landscaped rear garden. Walking distance to Gunwharf Quays, the Historic Dockyard, and Harbour ferry.',
 'terraced','sale',340000, 3,1,2, 1200,
 '7 Nelson Street','Portsmouth','Hampshire','PO1 2HG', 50.7986,-1.0942,
 5,'available', TRUE,FALSE,FALSE,FALSE,'E',
 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=80'),
-- 4
('Luxury Penthouse Apartment',
 'An exceptional penthouse occupying the entire top floor of a prestigious riverside development. Featuring three bedrooms, three bathrooms, a wraparound terrace with panoramic water views, cinema room, and concierge service. The master suite includes a dressing room and ensuite spa bathroom. Truly outstanding.',
 'flat','sale',875000, 3,3,1, 2100,
 'Penthouse, 1 Ocean Way','Southampton','Hampshire','SO15 1DP', 50.8981,-1.3963,
 2,'available', FALSE,TRUE,TRUE,TRUE,'A',
 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80'),
-- 5
('Cosy 2-Bed Cottage',
 'A delightful country cottage brimming with character. Beamed ceilings, inglenook fireplace, and exposed brick walls create a warm and welcoming atmosphere. The cottage garden is a real delight, and the village has an excellent pub and primary school. A perfect rural retreat just 20 minutes from Winchester.',
 'cottage','sale',365000, 2,1,2, 980,
 'Rose Cottage, Ducks Lane','Owslebury','Hampshire','SO21 1LT', 51.0009,-1.2703,
 5,'available', TRUE,TRUE,FALSE,FALSE,'F',
 'https://images.unsplash.com/photo-1449844908441-8829872d2607?w=800&q=80'),
-- 6
('Executive Semi-Detached',
 'A large and well-appointed semi-detached home ideal for growing families. Four bedrooms including a master with ensuite. The kitchen has been extended to create a stunning open-plan kitchen-family room with bi-fold doors to the garden. Utility room, separate study, and driveway parking for three cars.',
 'semi-detached','sale',420000, 4,2,2, 1650,
 '23 Maple Avenue','Eastleigh','Hampshire','SO50 6LB', 50.9681,-1.3601,
 1,'available', TRUE,TRUE,FALSE,FALSE,'C',
 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&q=80'),
-- 7
('Stylish 1-Bed Flat to Rent',
 'A contemporary and well-presented one-bedroom apartment in a popular purpose-built block. Features an open-plan lounge-kitchen with integrated appliances, modern bathroom, and a private juliet balcony. Available furnished or unfurnished. Pets considered. EPC B. Council Tax Band B.',
 'flat','rent',1100, 1,1,1, 510,
 'Flat 2A, 45 Station Road','Fareham','Hampshire','PO16 0HB', 50.8527,-1.1843,
 3,'available', FALSE,TRUE,FALSE,FALSE,'B',
 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80'),
-- 8
('Spacious 3-Bed House to Rent',
 'A well-maintained three-bedroom semi-detached house available to rent in a popular residential area. Gas central heating, double glazing throughout, private rear garden, and off-road parking. Walking distance to local amenities, schools, and bus routes. Available from 1st of next month.',
 'semi-detached','rent',1450, 3,1,1, 1100,
 '11 Hawthorn Road','Gosport','Hampshire','PO12 3NQ', 50.7940,-1.1258,
 4,'available', TRUE,TRUE,FALSE,FALSE,'D',
 'https://images.unsplash.com/photo-1565182999561-18d7dc61c393?w=800&q=80'),
-- 9
('New Build 3-Bed Townhouse',
 'A brand new three-storey townhouse forming part of an exciting new development. The ground floor features an integral garage and utility area. The first floor offers an open-plan kitchen-diner and lounge. Two bedrooms and a family bathroom on the second floor, with the master suite and ensuite on the top floor. 10-year NHBC warranty.',
 'terraced','sale',379000, 3,2,1, 1400,
 '5 Kestrel Place, Whiteley Village','Whiteley','Hampshire','PO15 7FH', 50.8714,-1.2346,
 4,'available', FALSE,TRUE,TRUE,TRUE,'A',
 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=800&q=80'),
-- 10
('Period Bungalow with Large Plot',
 'A rare opportunity to acquire a well-proportioned detached bungalow set on a generous 0.35 acre plot. The property offers three bedrooms, a bright conservatory, generous lounge, and a kitchen with room to extend (STPP). The plot provides significant development potential or scope to create outstanding gardens.',
 'bungalow','sale',445000, 3,1,2, 1350,
 '2 The Grange','Chandlers Ford','Hampshire','SO53 2GH', 50.9821,-1.3785,
 2,'under_offer', TRUE,TRUE,TRUE,FALSE,'E',
 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80'),
-- 11
('Waterfront Apartment',
 'A stunning waterfront apartment with breathtaking harbour views from every principal room. This exceptional two-bedroom property features a wraparound balcony, luxury fitted kitchen, and two stylish bathrooms. The development offers secure underground parking, a residents gym, and a concierge.',
 'flat','sale',525000, 2,2,1, 950,
 'Apt 12, Marine Quarter','Portsmouth','Hampshire','PO1 3LY', 50.8010,-1.0895,
 2,'available', FALSE,TRUE,FALSE,FALSE,'B',
 'https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=800&q=80'),
-- 12
('Substantial Country House',
 'An impressive country house offering five bedrooms, three bathrooms, and extensive reception space across three floors. Set in approximately 1.2 acres of beautifully landscaped grounds including a walled kitchen garden, heated swimming pool, and triple garage. A truly exceptional family home in a tranquil rural setting.',
 'detached','sale',1250000, 5,3,4, 3800,
 'Greenfield House, Church Lane','Bishops Waltham','Hampshire','SO32 1DL', 50.9508,-1.2143,
 1,'available', TRUE,TRUE,TRUE,FALSE,'D',
 'https://images.unsplash.com/photo-1464146072230-91cabc968266?w=800&q=80');

-- ── Property Features ─────────────────────────────────────────
INSERT INTO property_features (property_id, feature) VALUES
(1,'Open-plan kitchen-diner'),(1,'South-facing garden'),(1,'Double garage'),(1,'Underfloor heating'),(1,'Quiet cul-de-sac location'),
(2,'Private balcony'),(2,'City views'),(2,'Underground parking'),(2,'Concierge service'),(2,'Floor-to-ceiling windows'),
(3,'Original Victorian features'),(3,'Sash windows'),(3,'High ceilings'),(3,'Landscaped garden'),(3,'Walking distance to Gunwharf Quays'),
(4,'Wraparound terrace'),(4,'Panoramic river views'),(4,'Cinema room'),(4,'Concierge service'),(4,'Spa bathroom'),
(5,'Inglenook fireplace'),(5,'Beamed ceilings'),(5,'Cottage garden'),(5,'Village location'),(5,'Original character features'),
(6,'Open-plan kitchen-family room'),(6,'Bi-fold garden doors'),(6,'Master ensuite'),(6,'Study/home office'),(6,'Driveway parking x3'),
(7,'Juliet balcony'),(7,'Integrated appliances'),(7,'Pets considered'),(7,'Furnished or unfurnished'),(7,'Modern bathrooms'),
(8,'Off-road parking'),(8,'Private garden'),(8,'Gas central heating'),(8,'Double glazing'),(8,'Near good schools'),
(9,'NHBC 10-year warranty'),(9,'Integral garage'),(9,'Open-plan living'),(9,'Master ensuite'),(9,'New development'),
(10,'Large 0.35 acre plot'),(10,'Development potential (STPP)'),(10,'Conservatory'),(10,'Detached garage'),(10,'Quiet location'),
(11,'Harbour views'),(11,'Wraparound balcony'),(11,'Residents gym'),(11,'Secure parking'),(11,'Concierge service'),
(12,'Heated swimming pool'),(12,'Walled kitchen garden'),(12,'Triple garage'),(12,'1.2 acres of grounds'),(12,'Rural tranquil setting');

-- ── Property Images ───────────────────────────────────────────
INSERT INTO property_images (property_id, image_url, caption, display_order) VALUES
(1,'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80','Living Room',1),
(1,'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80','Kitchen',2),
(2,'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&q=80','Bedroom',1),
(3,'https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=800&q=80','Reception',1),
(4,'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80','Terrace View',1),
(5,'https://images.unsplash.com/photo-1598928636135-d146006ff4be?w=800&q=80','Garden',1),
(12,'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?w=800&q=80','Swimming Pool',1);

-- ── Sample Enquiry ────────────────────────────────────────────
INSERT INTO enquiries (property_id, name, email, phone, message, enquiry_type) VALUES
(1, 'Alice Thompson', 'alice@example.com', '07700 900001', 'I would love to arrange a viewing at the weekend if possible. Are Saturday mornings available?', 'viewing'),
(3, 'Bob Patel', 'bob@example.com', '07700 900002', 'Could you tell me more about the parking situation and whether the loft has been converted?', 'general');

-- ── Sample Favourites ─────────────────────────────────────────
INSERT INTO favourites (user_id, property_id, notes) VALUES
(1, 1, 'Great garden, need to check school catchment'),
(1, 3, 'Love the period features'),
(2, 4, 'Dream property - check mortgage options'),
(2, 11, 'Harbour views - perfect location');
