#!/bin/bash
#################################################
# description: Install Tactic 4.1 in Ubuntu 14.04
# date: 11-16-2014
# by: Daniel Bair
#################################################

tfile="TACTIC-4.5.0.v01.zip"
tdir="${tfile%\.*}"

cd /home/apache
mkdir -v -p /home/apache/install_packages
cd /home/apache/install_packages

echo -e "\e[0;32m\n*** Downloading $tfile \e[0m\n"
sleep 3
if [ -f "./$tfile" ]
then
	echo -e "\t $tfile found, skipping download."
	sleep 3
else
	wget "http://community.southpawtech.com/downloads/TACTIC%20-%20Enterprise/$tfile"
fi

echo -e "\e[0;32m\n*** Unzipping $tfile \e[0m\n"
sleep 5
rm -rf /home/apache/install_packages/$tdir
unzip $tfile
cd /home/apache/install_packages/$tdir/src/install/

echo -e "\e[0;32m\n*** Setting up python2.7 environment for tactic\e[0m\n"
sleep 3
sudo mkdir -v -p /usr/lib/python2.7/dist-packages/tacticenv
sudo chmod 755 /usr/lib/python2.7/dist-packages/tacticenv
echo "
TACTIC_INSTALL_DIR='/home/apache/tactic' 
TACTIC_SITE_DIR=''
TACTIC_DATA_DIR='/home/apache/tactic_data'" | sudo tee -a data/tactic_paths.py > /dev/null
sudo cp -v data/*.py /usr/lib/python2.7/dist-packages/tacticenv
sudo chmod a+r /usr/lib/python2.7/dist-packages/tacticenv/*.py

echo -e "\e[0;32m\n*** Installing tactic service\e[0m\n"
sleep 3
sudo cp -v service/tactic /etc/init.d/
sudo chmod 775 /etc/init.d/tactic

echo -e "\e[0;32m\n*** Installing tactic postgres config\e[0m\n"
sleep 3
pgver=`pg_lsclusters -h | head -n1 | cut -d' ' -f1`
sudo mv -v -n /etc/postgresql/$pgver/main/pg_hba.conf /etc/postgresql/$pgver/main/pg_hba.conf--ORIG
sudo cp -v postgresql/pg_hba.conf /etc/postgresql/$pgver/main/
sudo chown postgres:postgres /etc/postgresql/$pgver/main/pg_hba.conf
sudo /etc/init.d/postgresql restart

echo -e "\e[0;32m\n*** Installing tactic apache2 config\e[0m\n"
sleep 3
sudo a2enmod lbmethod_byrequests
sudo a2enmod proxy_balancer
sudo a2enmod proxy_http
sudo a2enmod rewrite

echo -e "\e[0;32m\n*** Uncommenting the two apache 2.4 config lines 'Require all granted' now\e[0m\n"
sleep 3
sed -i "s/#Req/Req/g" apache/tactic.conf
sudo cp -v apache/tactic.conf /etc/apache2/conf-available/
sudo ln -v -f -s /etc/apache2/conf-available/tactic.conf /etc/apache2/conf-enabled/

echo -e "\e[0;32m\n*** Restarting apache2 service\e[0m\n"
sleep 3
sudo service apache2 restart

echo -e "\e[0;32m\n*** Creating /var/www/index.html redirect\e[0m\n"
sleep 3
echo '<META http-equiv="refresh" content="0;URL=/tactic">' | sudo tee /var/www/index.html > /dev/null
sudo mkdir -v -p /var/www/html
sudo cp -v /var/www/index.html /var/www/html/

echo -e "\e[0;32m\n*** Running main tactic installer...\e[0m\n"
sleep 3
sudo python2.7 install.py

echo -e "\e[0;32m\n*** Installing tactic license\e[0m\n"
sleep 3
sudo chown -R apache:apache /home/apache
cp -v /home/apache/tactic/src/install/start/config/tactic-license.xml /home/apache/tactic_data/config/

echo -e "\e[0;32m\n*** Running tactic database upgrade...\e[0m\n"
sleep 3
python /home/apache/tactic/src/bin/upgrade_db.py

echo -e "\e[0;32m\n*** Fist-run tactic test\e[0m\n\t Press Ctrl-C when done...\e[0m\n"
sleep 3
python /home/apache/tactic/src/bin/startup_dev.py

echo -e "\e[0;32m\n*** Setting tactic service to start at boot\e[0m\n"
sleep 3
sudo update-rc.d tactic defaults

echo -e "\e[0;32m\n*** Starting tactic service\e[0m\n"
sleep 3
sudo service tactic start

echo -e '\e[0;32m\n*** All Done!\e[0m\n'

