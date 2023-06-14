#Must be run as root user in the scripted directory

#Bhavya Shah ACIT 4640
# A01023981

#Create admin user
useradd admin
echo P@ssw0rd | passwd admin --stdin
usermod -aG wheel admin

#Add public key
sudo hostname wp.snp.acit; 
sudo yum -d1 install wget -y;
#this doesn't work as the site is no longer active
wget https://4640.acit.site/code/ssh_setup/acit_admin_id_rsa.pub -P ~/ --user student --password w1nt3r2019;
mkdir ~/.ssh && touch ~/.ssh/authorized_keys;
cat ~/acit_admin_id_rsa >> ~/.ssh/authorized_keys;

#disable linuxsel
sudo setenforce 0;
sudo sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config;


#install packages and update them
sudo yum -d1 install @core epel-release vim git tcpdump nmap-ncat curl bzip tar -y;
sudo yum -d1 update -y;

#firewall rules
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent;
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent;
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent;
sudo firewall-cmd --reload;

#Install nginx
sudo yum -d1 install nginx -y;
sudo systemctl start nginx;
sudo systemctl enable nginx;


#install mariadb
sudo yum -d1 install mariadb-server mariadb -y;
sudo systemctl start mariadb;

#configure mariadb files
mysql -u root < ~/mariadb_security_config.sql;
sudo systemctl enable mariadb;

#install php
sudo yum -d1 install php php-mysql php-fpm -y;


#configure php
sudo mv ~/nginx.conf /etc/nginx 
sudo sed -i '763s/.*/cgi.fix_pathinfo=0/' /etc/php.ini;
sudo mv ~/www.conf /etc/php-fpm.d/ 
sudo systemctl start php-fpm;
sudo systemctl enable php-fpm;

sudo echo "<?php phpinfo(); ?>" >> ~/info.php;
sudo mv ~/info.php /usr/share/nginx/html/;
sudo systemctl restart nginx;

#Wordpress Setup
mysql -u root --password=P@ssw0rd < ~/wp_mariadb_config.sql;
#mysql -u root -e "SELECT user FROM mysql.user;"
#mysql -u root -e "SHOW DATABASES;"

#download and extracting wordpress
wget https://wordpress.org/latest.tar.gz -F ~/;
cd ~;
tar xzvf latest.tar.gz;
#Copy the wordpress sample
#cp wordpress/wp-config-sample.php wordpress/wp-config.php
cp -f wp-config.php wordpress/wp-config.php
sudo rsync -avP ~/wordpress/ /usr/share/nginx/html;
sudo mkdir /usr/share/nginx/html/wp-content/uploads;
sudo chown -R admin:nginx /usr/share/nginx/html/*;
# Installing pre-requisities
sudo yum -d1 install kernel-devel kernel-headers dkms gcc gcc-c++ kexec-tools -y

# Don't know if we need lines 90-94
# Creating mount point, mounting, and installing VirtualBox Guest Additions
# Assumes that the virtualbox guest additions CD is in /dev/cdrom
sudo yum install bzip2 tar -y;
mkdir vbox_cd
sudo mount /dev/sr1 ./vbox_cd
./vbox_cd/VBoxLinuxAdditions.run
umount ./vbox_cd
rmdir ./vbox_cd