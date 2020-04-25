#!/bin/bash
#################################################
# description: Install Tactic 4.1 in Ubuntu 14.04
# date: 11-16-2014
# by: Daniel Bair
#################################################


echo -e "\e[1;31m\n*** Installing required ubuntu packages\e[0m\n"
sleep 3
sudo apt-get install apache2 gcc imagemagick libjpeg-dev libjpeg-turbo8 libjpeg-turbo8-dev liblcms1-dev libpng-dev libxml2-dev libxslt1-dev make ntp ntpdate openssh-server postgresql postgresql-server-dev-all python python-crypto python-dev python-pil python-pythonmagick python-psycopg2 python-pycryptopp python-lxml python-imaging python-simplejson python-sql samba unzip vim vim-nox zlib1g-dev  
# This will fail on Ubuntu 14.04 without the trusty-media ppa
sudo apt-get install ffmpeg 

echo -e "\e[1;31m\n*** Apparmor can cause conflicts with tactic\e[0m"
read -r -p "Do you want to remove it? [y/N] " response
response=${response,,}    # tolower
if [[ $response =~ ^(yes|y)$ ]]
then
	echo -e "\n\t Removing apparmor to avoid conflicts with tactic\e[0m\n"
	sleep 3
	sudo /etc/init.d/apparmor stop
	sudo update-rc.d -f apparmor remove
	sudo apt-get remove apparmor apparmor-utils
fi

echo -e "\e[1;31m\n*** Dash is configured by default for /bin/sh and can cause conflicts with tactic\e[0m"
read -r -p "Do you want to change it? [y/N] " response
response=${response,,}    # tolower
if [[ $response =~ ^(yes|y)$ ]]
then
	echo -e "\n\t Reconfiguring now...\e[0m"
	sleep 3
	sudo dpkg-reconfigure dash
fi

echo -e "\e[1;31m\n*** For your convience, you can change the root user password now\e[0m"
read -r -p "Do you want to change it? [y/N] " response
response=${response,,}    # tolower
if [[ $response =~ ^(yes|y)$ ]]
then
	echo
	sudo passwd root
fi

echo -e "\e[1;31m\n*** Adding apache user and group\e[0m\n"
sleep 3
sudo groupadd --gid 48 apache
sudo useradd -c Apache -d /home/apache -s /bin/bash --uid 48 --gid 48 -m apache
sudo usermod -c Apache -d /home/apache -s /bin/bash apache
sudo mkdir -v -p /home/apache
sudo chown -R apache:apache /home/apache
sudo chmod -R a+rx /home/apache

echo -e "\e[1;31m\n*** Please set apache user password now\e[0m\n"
sleep 3
sudo passwd apache

echo -e "\e[1;31m\n*** Please add the line below after '# User privilege specification' \e[0m\n\tapache ALL=(ALL) ALL"
sleep 10
sudo visudo

echo -e "\e[1;31m\n*** Copying second install script to apache user home directory\e[0m\n"
sleep 3
sudo -u apache mkdir -v -p /home/apache/install_packages
sudo -u apache cp -v ./tactic_apache_install.sh /home/apache/install_packages/

# This checks to see if TACTIC zip file is already downloaded
dfile="TACTIC-4.5.0.v01.zip"
if [ -f "./$dfile" ]
then
	echo -e "\e[1;31m\n*** $dfile found. Copying to apache home directory\e[0m\n"
	sudo -u apache cp -v "./$dfile" /home/apache/install_packages/
fi

sudo chown -R apache:apache /home/apache
sudo chmod -R a+rx /home/apache

# Now logging in as apache user and running the second install script
echo -e "\e[1;31m\n*** Logging in as apache user and running second install script now...\e[0m\n"
sleep 5
exec sudo -i -u apache /bin/bash /home/apache/install_packages/tactic_apache_install.sh

