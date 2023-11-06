CREATE DATABASE mifostenant-default;
CREATE USER 'mifos'@'localhost' IDENTIFIED BY 'ismoilovdev';
GRANT ALL PRIVILEGES ON mifostenant-default.* TO 'mifos'@'localhost';
FLUSH PRIVILEGES;
EXIT;
