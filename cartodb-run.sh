#!/bin/sh

cd
cd cartodb

bundle exec script/resque
bundle exec thin start --threaded -p 3000 --threadpool-size 5

cd
cd CartoDB-SQL-API
node app.js development &

cd Windshaft-cartodb
node app.js development &
