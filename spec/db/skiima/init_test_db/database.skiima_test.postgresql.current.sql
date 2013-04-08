DROP DATABASE IF EXISTS &database;
--================
DROP USER IF EXISTS &testuser;
--================
CREATE USER &testuser WITH PASSWORD '&testpass';
--================
CREATE DATABASE &database;
--================
GRANT ALL PRIVILEGES ON DATABASE &database to &testuser;
