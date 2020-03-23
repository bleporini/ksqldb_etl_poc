#!/usr/bin/env bash


wait_for_status(){
    local status=$1
    local query=$2
    local nbTries=$3
    local maxTries=$((120))
    local sleepTime=$((2))

    if [ -z "$nbTries" ]; then nbTries=0 ; fi

    if [ $nbTries -gt $maxTries ]
    then
        echo Tried $maxTries to get see if the status is $status, exiting...
        exit -1
    fi

    query_res=$($2)
    echo Status is $query_res, expecting $status ...

    if [ "$query_res" = "$status" ]
    then
        echo "OK"
    else
        nbTries=$(($nbTries + 1))
        sleep $sleepTime
        wait_for_status "$status" $query $nbTries
    fi
}


docker-compose up -d sr debezium

check_sr(){
    docker-compose exec sr curl -ksvf localhost:8081/subjects > /dev/null && echo "OK" || echo "KO"
}

wait_for_status "OK" check_sr 20

docker-compose up -d ksqldb-server ksqldb-cli

check_ksqldb(){
    docker-compose exec ksqldb-server curl -ksvf localhost:8088/healthcheck > /dev/null && echo "OK" || echo "KO"
}

wait_for_status "OK" check_ksqldb 30

echo Uploading queries

queries=$(tr -d '\n' < init.ksql)

docker-compose exec ksqldb-server curl -H "Content-Type: application/json" \
    -ksv -XPOST -d "{\"ksql\": \"$queries\"}" localhost:8088/ksql

echo DB initialization
docker-compose up db-population