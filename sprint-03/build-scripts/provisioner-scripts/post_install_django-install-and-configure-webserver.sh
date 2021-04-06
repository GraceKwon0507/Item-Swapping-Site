#!/bin/bash

# Script to configure Django automatically out of the box
# Set the etc hosts values
echo "$WEBSERVERIP     frontend    frontend.class.edu"  | sudo tee -a /etc/hosts
echo "$DATABASESERVERIP    backend    backend.class.edu"    | sudo tee -a /etc/hosts

##############################################################################################
# Install Django pre-reqs
##############################################################################################
sudo apt-get install -y libexpat1 ssl-cert python3-dev python3-pip python3-setuptools

##############################################################################################
# Install Django mysqlclient library pre-reqs
##############################################################################################
sudo apt-get install -y default-libmysqlclient-dev build-essential
python3 -m pip install mysqlclient

##############################################################################################
# Inject all environment variables into a .my.cnf file
# Here we can construct the .my.cnf file and append the value to the .my.cnf file we will 
# create in the home directory
##############################################################################################
echo "[client]" >> /home/vagrant/.my.cnf
echo "database = $DATABASENAME" >> /home/vagrant/.my.cnf
echo "user = worker" >> /home/vagrant/.my.cnf
echo "password = $DBPASS" >> /home/vagrant/.my.cnf
echo "default-character-set = utf8" >> /home/vagrant/.my.cnf

##############################################################################################
# Install Django
##############################################################################################
python3 -m pip install django django-admin django-common

###########################################################################
# Django Backup and restore program
########################################################################### 
#https://pypi.org/project/django-dbbackup/
python3 -m pip install django-dbbackup

##############################################################################################
# Create Django project
##############################################################################################
django-admin startproject mysite

##############################################################################################
# CHANGE THE VALUES ~/2021-team-sample TO YOUR TEAM REPO AND ADJUST THE PATH ACCORDINGLY     #
# Adjust the paths below in line 35-37, and 44 and 46                                        #
##############################################################################################
sudo chown -R vagrant:vagrant ~/2021-team06r

sudo cp -v /home/vagrant/2021-team06r/sprint-03/code/django/settings.py /home/vagrant/mysite/mysite/

##############################################################################################
# Using sed to replace the blank settings value with the secret key
##############################################################################################
echo "Replacing default secret key: \n"
sed -i "s/SECRET_KEY = \'\'/SECRET_KEY = '$DJANGOSECRETKEY\'/g" /home/vagrant/2021-team06r/sprint-03/code/django/settings.py
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = [\'$WEBSERVERIP'\]/g" /home/vagrant/2021-team06r/sprint-03/code/django/settings.py
sed -i "s/'HOST': '',/'HOST': \'$DATABASESERVERIP\',/g" /home/vagrant/2021-team06r/sprint-03/code/django/settings.py

##############################################################################################
# Overwriting default files from sed commands
##############################################################################################
cp -v /home/vagrant/2021-team06r/sprint-03/code/django/settings.py /home/vagrant/mysite/mysite
sudo chown -R vagrant:vagrant mysite

##############################################################################################
# Create super user account from the ENV variables we passed in
##############################################################################################
python3 manage.py createsuperuser --noinput

##############################################################################################
# Copy systemd start script to runserver at boot
##############################################################################################
sudo cp -v ~/2021-team06r/sprint-03/code/django/django-server.service /lib/systemd/system/
sudo systemctl enable django-server
sudo systemctl start django-server

##############################################################################################
# Set firewall section
# We will need to enable to port and the IP to receive a connection from for our system
##############################################################################################
# https://serverfault.com/questions/809643/how-do-i-use-ufw-to-open-ports-on-ipv4-only
# https://serverfault.com/questions/790143/ufw-enable-requires-y-prompt-how-to-automate-with-bash-script
ufw --force enable
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 8000