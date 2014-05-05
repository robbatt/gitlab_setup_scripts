#!/bin/bash
set -e # stop on first error

echo
echo "########################################################"
echo "###### 4. Database                                ######"
echo "########################################################"
echo

# Install the database packages
if [[ -z "$GITLAB_DB_ROOT_PASS" ]] ; then
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $GITLAB_DB_ROOT_PASS"
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password GITLAB_DB_ROOT_PASS"
	
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server mysql-client libmysqlclient-dev expect
	
	else
	
	sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev expect
fi


# Ensure you have MySQL version 5.5.14 or later
MYSQL_VERSION_FULL=`mysql --version`

### TODO check version

# Pick a database root password (can be anything), type it and press enter
# Retype the database root password and press enter

# Secure your installation.
SECURE_MYSQL=$(expect -c "
 
set timeout 10
spawn mysql_secure_installation
 
expect \"Enter current password for root (enter for none):\"
send \"$GITLAB_DB_ROOT_PASS\r\"
 
expect \"Change the root password?\"
send \"n\r\"
 
expect \"Remove anonymous users?\"
send \"y\r\"
 
expect \"Disallow root login remotely?\"
send \"y\r\"
 
expect \"Remove test database and access to it?\"
send \"y\r\"
 
expect \"Reload privilege tables now?\"
send \"y\r\"
 
expect eof
")
 
sudo echo "$SECURE_MYSQL"
 
sudo apt-get purge -y expect


# Ensure you can use the InnoDB engine which is necessary to support long indexes.
# If this fails, check your MySQL config files (e.g. `/etc/mysql/*.cnf`, `/etc/mysql/conf.d/*`) for the setting "innodb = off"
mysql -u root -p$GITLAB_DB_ROOT_PASS -e \
"SET storage_engine=INNODB;"

# Create the GitLab production database
mysql -u root -p$GITLAB_DB_ROOT_PASS -e \
"CREATE DATABASE IF NOT EXISTS gitlabhq_production DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

# Create a user for GitLab if not exists
# Grant the GitLab user necessary permissions on the table.
cmd="GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON gitlabhq_production.* TO git@localhost IDENTIFIED BY '$GITLAB_DB_PASS';"
mysql -u root -p$GITLAB_DB_ROOT_PASS -e "$cmd"

# Try connecting to the new database with the new user
sudo -u git -H mysql -u git -p$GITLAB_DB_PASS -D gitlabhq_production -e "SHOW TABLES;"




















# Install the database packages
#sudo apt-get install -y postgresql-9.1 postgresql-client libpq-dev

# Login to PostgreSQL
#sudo -u postgres psql -d template1

# Create a user for GitLab.
#template1=# CREATE USER git;

# Create the GitLab production database & grant all privileges on database
#template1=# CREATE DATABASE gitlabhq_production OWNER git;

# Quit the database session
#template1=# \q

# Try connecting to the new database with the new user
#sudo -u git -H psql -d gitlabhq_production
