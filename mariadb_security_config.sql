# Set root password
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('P@ssw0rd');

# Remove anonymous users
DELETE FROM mysql.user WHERE User='';

# Disallow remote root login
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

# Remove test database
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';