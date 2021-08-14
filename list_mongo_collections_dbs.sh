#!/usr/bin/env bash

#####################################################
# This script list all collections of all databases #
#                                                   #
# Script made by Luis Amaro - Exabeam               #
# AA i46                                            #
#####################################################

MONGO_DBS=$(docker exec -it mongodb-router-host1 /usr/bin/mongo --quiet --eval 'db.getMongo().getDBNames()' | sed -e 's/"//g' -e 's/,//g' -e 's/[ \t]*//'  -e 's/\r//g' | grep -vE '\[|\]')
for DB in ${MONGO_DBS}; do
  COLLECTIONS=$(docker exec -it mongodb-router-host1 /usr/bin/mongo "${DB}" --quiet --eval 'db.getCollectionNames()' | sed -e 's/"//g' -e 's/,//g' -e 's/[ \t]*//' | grep -vE '\[|\]')
  for COLLECTION in ${COLLECTIONS}; do
    echo "${DB}.${COLLECTION}"
  done
done

