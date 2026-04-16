#! /usr/bin/bash

while true;do
    psql -U postgres -h 127.0.0.1 -p 5678 -c "insert into hello(id) values(generate_series(1,111111));"
    sleep 1
done
