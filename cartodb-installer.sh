#!/bin/sh

#System requirements

sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
sudo apt-get install autoconf binutils-doc bison build-essential flex -y
sudo apt-get install git -y
sudo apt-get install python-software-properties -y

#PostgreSQL

sudo add-apt-repository ppa:cartodb/postgresql-9.3 -y
sudo apt-get update
sudo apt-get install libpq5 libpq-dev postgresql-client-9.3 postgresql-client-common -y
sudo apt-get install postgresql-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3 postgresql-plpython-9.3 -y

sudo service postgresql restart

sudo createuser publicuser --no-createrole --no-createdb --no-superuser -U postgres
sudo createuser tileuser --no-createrole --no-createdb --no-superuser -U postgres

git clone https://github.com/CartoDB/cartodb-postgresql.git
cd cartodb-postgresql
sudo make all install

#GIS dependencies

sudo add-apt-repository ppa:cartodb/gis -y
sudo apt-get update

sudo apt-get install proj proj-bin proj-data libproj-dev -y
sudo apt-get install libjson0 libjson0-dev python-simplejson -y
sudo apt-get install libgeos-c1v5 libgeos-dev -y
sudo apt-get install gdal-bin libgdal1-dev libgdal-dev -y
sudo apt-get install gdal2.1-static-bin -y

#PostGIS

sudo apt-get install libxml2-dev -y
sudo apt-get install liblwgeom-2.1.8 postgis postgresql-9.3-postgis-2.2 postgresql-9.3-postgis-scripts -y

sudo createdb -T template0 -O postgres -U postgres -E UTF8 template_postgis
sudo createlang plpgsql -U postgres -d template_postgis
psql -U postgres template_postgis -c 'CREATE EXTENSION postgis;CREATE EXTENSION postgis_topology;'
sudo ldconfig

sudo PGUSER=postgres make installcheck
sudo service postgresql restart

#Redis

sudo add-apt-repository ppa:cartodb/redis -y
sudo apt-get update

sudo apt-get install redis-server -y

#NodeJS

sudo add-apt-repository ppa:cartodb/nodejs-010 -y
sudo apt-get update

sudo apt-get install nodejs -y

sudo npm install -g npm@2.14.16

#SQL API

cd
git clone git://github.com/CartoDB/CartoDB-SQL-API.git
cd CartoDB-SQL-API

npm install

cp config/environments/development.js.example config/environments/development.js

#MAPS API
cd
git clone git://github.com/CartoDB/Windshaft-cartodb.git
cd Windshaft-cartodb

sudo apt-get install libpango1.0-dev -y
npm install

cp config/environments/development.js.example config/environments/development.js

#Ruby

cd
wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
tar -xzvf ruby-install-0.5.0.tar.gz
cd ruby-install-0.5.0/
sudo make install

sudo apt-get install libreadline6-dev openssl -y

sudo ruby-install ruby 2.2.3

export PATH=$PATH:/opt/rubies/ruby-2.2.3/bin

gem install bundler
gem install compass

#Editor

cd
git clone --recursive https://github.com/CartoDB/cartodb.git
cd cartodb

sudo wget  -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
sudo python /tmp/get-pip.py


sudo apt-get install python-all-dev -y
sudo apt-get install imagemagick unp zip -y

RAILS_ENV=development bundle install
npm install

export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
export PATH=$PATH:/usr/include/gdal

sudo pip install --no-use-wheel -r python_requirements.txt

export PATH=$PATH:$PWD/node_modules/grunt-cli/bin

bundle install
bundle exec grunt --environment development

cp config/app_config.yml.sample config/app_config.yml
cp config/database.yml.sample config/database.yml

RAILS_ENV=development bundle exec rake db:create
RAILS_ENV=development bundle exec rake db:migrate
RAILS_ENV=development bundle exec rake cartodb:db:setup_user

export SUBDOMAIN=development

echo "127.0.0.1 ${SUBDOMAIN}.localhost.lan" | sudo tee -a /etc/hosts

sh script/create_dev_user ${SUBDOMAIN}
