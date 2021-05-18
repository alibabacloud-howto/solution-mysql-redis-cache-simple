#!/bin/bash
source ./env.sh

mysql -u${SG_DBUSER} -p${SG_DBUSERPW} -h${SG_DBHOST} ${SG_DBNAME}