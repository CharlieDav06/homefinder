INSERT INTO `2FA` (
  user_id,
  auth_id,
  token_value,
  time_created,
  is_used,
  retry_count
)
VALUES
(1, 1, '482915', '2026-04-29 09:00:00', TRUE, 1),
(2, 2, '193847', '2026-04-29 09:10:00', FALSE, 0),
(3, 3, '564738', '2026-04-29 09:20:00', TRUE, 2),
(4, 4, '918273', '2026-04-29 09:30:00', FALSE, 1),
(5, 5, '102938', '2026-04-29 09:40:00', TRUE, 3);





INSERT INTO supervisor (user_id, supervisor_role)
VALUES
(2, 'TEAM_LEAD'),
(4, 'SENIOR_SUPERVISOR');




INSERT INTO User (first_name, last_name, email, phone_number, gdpr_consent_given)
VALUES
('Alex', 'Taylor', 'alex.taylor88@gmail.com', '07111222333', TRUE),
('Jessica', 'Anderson', 'jessica.a99@gmail.com', '07123456780', TRUE),
('Daniel', 'Thomas', 'daniel.thomas2024@gmail.com', '07222333444', FALSE),
('Laura', 'White', 'laura.white7@gmail.com', '07333444555', TRUE),
('James', 'Martin', 'jamesm_23@gmail.com', '07444555666', TRUE),
('Olivia', 'Clark', 'olivia.clark11@gmail.com', '07555666777', FALSE),
('Ethan', 'Lewis', 'ethan.lewis55@gmail.com', '07199887766', TRUE),
('Ava', 'Walker', 'ava.walker09@gmail.com', '07211002233', TRUE),
('Noah', 'Hall', 'noah.hall3@gmail.com', '07322113344', FALSE),
('Mia', 'Allen', 'mia.allen77@gmail.com', '07433221100', TRUE);




INSERT INTO Session (
  user_id,
  auth_id,
  session_start_time,
  last_input_time,
  ip_address,
  is_active
)
VALUES
(1, 1, '2026-04-29 09:00:00', '2026-04-29 09:10:00', '192.168.0.10', TRUE),
(2, 2, '2026-04-29 09:15:00', '2026-04-29 09:45:00', '192.168.0.11', TRUE),
(3, 3, '2026-04-29 10:00:00', '2026-04-29 10:05:00', '192.168.0.12', FALSE),
(4, 4, '2026-04-29 10:20:00', '2026-04-29 10:50:00', '192.168.0.13', TRUE),
(5, 5, '2026-04-29 11:00:00', '2026-04-29 11:30:00', '192.168.0.14', FALSE);



INSERT INTO AuthService (user_id, max_login_attempts, token_expiry_time)
VALUES
  (1, 5, 3600),
(2, 3, 7200),
(3, 10, 1800),
(4, 5, 3600),
(5, 7, 5400);



INSERT INTO Admin (user_id, admin_level, permissions)
VALUES
(1, 3, 'ALL_ACCESS'),
(3, 2, 'MANAGE_USERS,VIEW_REPORTS')

