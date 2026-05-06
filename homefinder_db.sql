-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: home_finder_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `2fa`
--

DROP TABLE IF EXISTS `2fa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `2fa` (
  `auth_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token_value` varchar(10) NOT NULL,
  `time_created` datetime NOT NULL,
  `is_used` tinyint(1) NOT NULL,
  `retry_count` int NOT NULL,
  PRIMARY KEY (`auth_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `2fa_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `2fa_ibfk_2` FOREIGN KEY (`auth_id`) REFERENCES `authservice` (`auth_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `2fa`
--

LOCK TABLES `2fa` WRITE;
/*!40000 ALTER TABLE `2fa` DISABLE KEYS */;
INSERT INTO `2fa` VALUES (1,1,'482915','2026-04-29 09:00:00',1,1),(2,2,'193847','2026-04-29 09:10:00',0,0),(3,3,'564738','2026-04-29 09:20:00',1,2),(4,4,'918273','2026-04-29 09:30:00',0,1),(5,5,'102938','2026-04-29 09:40:00',1,3);
/*!40000 ALTER TABLE `2fa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `user_id` int NOT NULL,
  `admin_level` int NOT NULL,
  `permissions` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,3,'ALL_ACCESS'),(3,2,'MANAGE_USERS,VIEW_REPORTS');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `authservice`
--

DROP TABLE IF EXISTS `authservice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `authservice` (
  `auth_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `max_login_attempts` int NOT NULL,
  `token_expiry_time` int NOT NULL,
  PRIMARY KEY (`auth_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `authservice_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authservice`
--

LOCK TABLES `authservice` WRITE;
/*!40000 ALTER TABLE `authservice` DISABLE KEYS */;
INSERT INTO `authservice` VALUES (1,1,5,3600),(2,2,3,7200),(3,3,10,1800),(4,4,5,3600),(5,5,7,5400);
/*!40000 ALTER TABLE `authservice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `commercial`
--

DROP TABLE IF EXISTS `commercial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `commercial` (
  `property_id` int NOT NULL,
  `square_ft` int NOT NULL,
  `floors` int NOT NULL,
  `property_usage` varchar(100) NOT NULL,
  `has_parking` tinyint(1) NOT NULL,
  `zoning_type` varchar(100) NOT NULL,
  `price` int NOT NULL,
  PRIMARY KEY (`property_id`),
  CONSTRAINT `commercial_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `commercial`
--

LOCK TABLES `commercial` WRITE;
/*!40000 ALTER TABLE `commercial` DISABLE KEYS */;
INSERT INTO `commercial` VALUES (4,10000,5,'Office',1,'B1',1400000);
/*!40000 ALTER TABLE `commercial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `property`
--

DROP TABLE IF EXISTS `property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `property` (
  `property_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `location` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `owner_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`property_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `property_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `admin` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `property`
--

LOCK TABLES `property` WRITE;
/*!40000 ALTER TABLE `property` DISABLE KEYS */;
INSERT INTO `property` VALUES (1,1,'York House','High Street, Tutbury, DE13','Spacious period home with large rooms, traditional features, garden, and village location close to amenities.','/images/York House.jpg','james.hartley@gmail.com'),(2,3,'Oatlands','Alderley Edge, Cheshire, SK9','Exceptional luxury residence in a prime Alderley Edge location featuring extensive living space, high-end finishes, landscaped grounds, and secure gated access.','/images/Oatlands House.jpg','victoria.pemberton@outlook.com'),(3,1,'Ironmonger Row Apartment','Coventry, West Midlands, CV1','Modern rental apartment in central Coventry with convenient access to shops, transport links, and local amenities.','/images/Ironmonger Flat.jpg','daniel.shaw@hotmail.com'),(4,3,'Apex Centre Office','55 Calthorpe Road, Edgbaston, Birmingham B15','Modern office space in a prime Edgbaston location offering high-quality commercial accommodation with strong transport links and professional surroundings.','/images/Apex Centre Building.webp','sophie.chambers@businessmail.com');
/*!40000 ALTER TABLE `property` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental`
--

DROP TABLE IF EXISTS `rental`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental` (
  `property_id` int NOT NULL,
  `num_bedrooms` int NOT NULL,
  `num_bathrooms` int NOT NULL,
  `monthly_rent` decimal(10,2) NOT NULL,
  `security_deposit` decimal(10,2) NOT NULL,
  `lease_duration` int NOT NULL,
  `is_pet_friendly` tinyint(1) NOT NULL,
  `lease_terms` varchar(255) DEFAULT NULL,
  `is_furnished` tinyint(1) NOT NULL,
  PRIMARY KEY (`property_id`),
  CONSTRAINT `rental_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental`
--

LOCK TABLES `rental` WRITE;
/*!40000 ALTER TABLE `rental` DISABLE KEYS */;
INSERT INTO `rental` VALUES (3,2,1,690.00,800.00,12,1,'12 month minimum tenancy, no smoking',1);
/*!40000 ALTER TABLE `rental` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report`
--

DROP TABLE IF EXISTS `report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `property_id` int NOT NULL,
  `user_id` int NOT NULL,
  `month` datetime NOT NULL,
  `total_inquiries` int NOT NULL,
  PRIMARY KEY (`report_id`),
  KEY `user_id` (`user_id`),
  KEY `property_id` (`property_id`),
  CONSTRAINT `report_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `supervisor` (`user_id`),
  CONSTRAINT `report_ibfk_2` FOREIGN KEY (`property_id`) REFERENCES `property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report`
--

LOCK TABLES `report` WRITE;
/*!40000 ALTER TABLE `report` DISABLE KEYS */;
/*!40000 ALTER TABLE `report` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `residential`
--

DROP TABLE IF EXISTS `residential`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `residential` (
  `property_id` int NOT NULL,
  `num_bedrooms` int NOT NULL,
  `num_bathrooms` int NOT NULL,
  `is_furnished` tinyint(1) NOT NULL,
  `price` int NOT NULL,
  PRIMARY KEY (`property_id`),
  CONSTRAINT `residential_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `residential`
--

LOCK TABLES `residential` WRITE;
/*!40000 ALTER TABLE `residential` DISABLE KEYS */;
INSERT INTO `residential` VALUES (1,4,2,0,720000),(2,6,4,1,6650000);
/*!40000 ALTER TABLE `residential` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `session` (
  `session_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `auth_id` int NOT NULL,
  `session_start_time` datetime NOT NULL,
  `last_input_time` datetime DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`session_id`),
  KEY `user_id` (`user_id`),
  KEY `auth_id` (`auth_id`),
  CONSTRAINT `session_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `session_ibfk_2` FOREIGN KEY (`auth_id`) REFERENCES `authservice` (`auth_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
INSERT INTO `session` VALUES (1,1,1,'2026-04-29 09:00:00','2026-04-29 09:10:00','192.168.0.10',1),(2,2,2,'2026-04-29 09:15:00','2026-04-29 09:45:00','192.168.0.11',1),(3,3,3,'2026-04-29 10:00:00','2026-04-29 10:05:00','192.168.0.12',0),(4,4,4,'2026-04-29 10:20:00','2026-04-29 10:50:00','192.168.0.13',1),(5,5,5,'2026-04-29 11:00:00','2026-04-29 11:30:00','192.168.0.14',0);
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supervisor`
--

DROP TABLE IF EXISTS `supervisor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supervisor` (
  `user_id` int NOT NULL,
  `supervisor_role` varchar(100) NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `supervisor_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supervisor`
--

LOCK TABLES `supervisor` WRITE;
/*!40000 ALTER TABLE `supervisor` DISABLE KEYS */;
INSERT INTO `supervisor` VALUES (2,'TEAM_LEAD'),(4,'SENIOR_SUPERVISOR');
/*!40000 ALTER TABLE `supervisor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `twofa_tokens`
--

DROP TABLE IF EXISTS `twofa_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `twofa_tokens` (
  `token_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token` varchar(6) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`token_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `twofa_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `twofa_tokens`
--

LOCK TABLES `twofa_tokens` WRITE;
/*!40000 ALTER TABLE `twofa_tokens` DISABLE KEYS */;
INSERT INTO `twofa_tokens` VALUES (1,12,'972523','2026-05-06 11:30:33',0),(2,13,'584794','2026-05-06 11:31:13',0);
/*!40000 ALTER TABLE `twofa_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `gdpr_consent_given` tinyint(1) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'Alex','Taylor','alex.taylor88@gmail.com','07111222333',1,NULL),(2,'Jessica','Anderson','jessica.a99@gmail.com','07123456780',1,NULL),(3,'Daniel','Thomas','daniel.thomas2024@gmail.com','07222333444',0,NULL),(4,'Laura','White','laura.white7@gmail.com','07333444555',1,NULL),(5,'James','Martin','jamesm_23@gmail.com','07444555666',1,NULL),(6,'Olivia','Clark','olivia.clark11@gmail.com','07555666777',0,NULL),(7,'Ethan','Lewis','ethan.lewis55@gmail.com','07199887766',1,NULL),(8,'Ava','Walker','ava.walker09@gmail.com','07211002233',1,NULL),(9,'Noah','Hall','noah.hall3@gmail.com','07322113344',0,NULL),(10,'Mia','Allen','mia.allen77@gmail.com','07433221100',1,NULL),(11,NULL,NULL,'fgfogfiggo_djgfjhg@icloud.com',NULL,NULL,'$2b$12$qV4CLYwzbKsMpRoCFrhHUOgeJGvQtDAL1gK87h29sJwEe8A4Mrc1i'),(12,NULL,NULL,'bobriley@bob.com',NULL,NULL,'$2b$12$ppg3qoeugi5B0Es9L6DRteE1PLbLLByJQCDrdDOI6lECW.aRUrbW2'),(13,NULL,NULL,'100742585@unimail.derby.ac.uk',NULL,NULL,'$2b$12$0AAQ0NEn3fE7gkqPUxYNKe8yqNIz/ZdUI4psA6iGORlSoq9LxUFV2');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `viewing_reservation`
--

DROP TABLE IF EXISTS `viewing_reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `viewing_reservation` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `property_id` int NOT NULL,
  `user_id` int NOT NULL,
  `reservation_name` varchar(32) NOT NULL,
  `schedule_date` datetime NOT NULL,
  `reservation_duration` int NOT NULL,
  `reservation_type` varchar(32) NOT NULL,
  `status` varchar(32) NOT NULL,
  PRIMARY KEY (`reservation_id`),
  KEY `property_id` (`property_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `viewing_reservation_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `property` (`property_id`),
  CONSTRAINT `viewing_reservation_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `viewing_reservation`
--

LOCK TABLES `viewing_reservation` WRITE;
/*!40000 ALTER TABLE `viewing_reservation` DISABLE KEYS */;
INSERT INTO `viewing_reservation` VALUES (1,2,1,'bob','2026-05-14 19:32:00',30,'in-person','pending'),(2,2,1,'John Mclaine','2026-05-14 21:03:00',90,'virtual','pending'),(3,3,1,'Bart Simpson','2026-05-07 22:04:00',90,'in-person','pending');
/*!40000 ALTER TABLE `viewing_reservation` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-06 11:55:45
