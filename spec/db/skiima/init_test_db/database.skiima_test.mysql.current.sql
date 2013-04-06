DROP DATABASE IF EXISTS &database;
--================
CREATE USER '&testuser'@'localhost' IDENTIFIED BY '&testpass';
--================
CREATE DATABASE &database;
--================
GRANT ALL PRIVILEGES ON &database.* TO '&testuser'@'localhost';
