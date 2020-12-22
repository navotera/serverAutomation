#!/bin/bash

# System requirement 
# Ubuntu 18.X, 20.X Memory Min 1GB
# pada beberapa vps instalasi bisa gagal misalnya ada pesan DPKG is being used by another process, hal ini disebabkan oleh vps yang tidak terkonfigurasi
# bisa dikarenakan source yang gagal atau hal lainnya, bisa juga error saat mengganti mysql authentication. Solusinya ganti / rebulild ulang VPS sebelum digunakan lagi.
#log disimpan di serverInstal.log
# Features : 
    # Webmin port 9191, securing ssh,  fail2ban auto config, http2, php installed from 7.3 to 7.4 including package
    # Htop, imagick, cron to disable webmin on each 4 hours, ubuntu optimization
    # Apache2 http/2 - event mode, ModSecurity, Mod_GeoIP2

#phpmyadmin user : root_db password can be found on server.config file
#webmin pass : can be found on server.config file
#created by navotera : share-system.com

JAIL_CONFIG_URL='https://up.openjournaltheme.com/serv/serverInit/jail.local'
CORE_FILE_URL='https://up.openjournaltheme.com/serv/UbuntuServerInitiateBeforeReboot.sh'


RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 18 | head -n 1)
IP_ADDRESS=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')

#create file and variable 
echo "PASSWORD=$PASSWD" > server.config 
echo 
echo "${GREEN}Starting the installation process \n (php package 7.3-7.4, Webmin, ModGeoIP2, Fail2ban, timezone to Asia/Makassar,mysql root admin, webmin root authentication, mod security, ssh private keys and other optimization..${NC}"
echo 
echo "root & root_db password : ${YELLOW}${PASSWD}${NC}"
echo "Password can only be used for webmin & phpmyadmin access, ssh access should use id_rsa authentication"
echo 
echo "Webmin url : ${YELLOW}https://${IP_ADDRESS}:9191${NC}"
echo 
echo "Log can be found on ${GREEN}installServer.log${NC}"
echo 
echo "Created By navotera : https://share-system.com"
echo "No Warranty is provided"
echo 
echo "${GREEN}Please enjoy and wait for about 15 to 25 minutes to finish all the process then rebooting...${NC}"

sleep 10

#creating log file : install.log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>installServer.log 2>&1

mkdir serverInit
#cd serverInit
wget --user roba@up.openjournaltheme.com --password roba JAIL_CONFIG_URL -P /serverInit
chmod 755 /serverInit/jail.local



#get and initiate the  
wget --user roba@up.openjournaltheme.com --password roba CORE_FILE_URL && chmod +x UbuntuServerInitiateBeforeReboot.sh 
sh -x UbuntuServerInitiateBeforeReboot.sh

#create user root_db with credential provided
service mysql start &&  sudo echo "CREATE USER 'root_db'@'localhost' IDENTIFIED BY '$PASSWD'; GRANT ALL PRIVILEGES ON * . * TO 'root_db'@'localhost'; FLUSH PRIVILEGES;" | mysql  

#cannot change password for webmin on bash
#sudo sh -c 'echo root:$ROOT_PASSWORD | chpasswd'
echo 
echo "${GREEN}rebooting..${NC}"
echo 

/usr/share/webmin/changepass.pl /etc/webmin root $PASSWD

sudo rm Ubuntu* 
sudo rm fail2ban*
sudo rm install.sh
sudo rm -rf serverInit

#disable other user read this file
chmod 640 server.config 

sudo reboot
# reboot here  
