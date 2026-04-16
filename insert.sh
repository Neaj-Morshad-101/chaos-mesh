#!/usr/bin/bash
sum=0
row=1

while true; do
    sleep .05
    
    # Ensure table exists
    psql -U postgres -h 127.0.0.1 -p 5678 -d postgres \
         -c "create table if not exists hello(id int);"
    
    # Try the insert
    if psql -U postgres -h 127.0.0.1 -p 5678 -d postgres \
             -c "insert into hello(id) values(generate_series(1,$row));"
    then
        ((sum += row))
    else
        echo "Insert failed, not incrementing sum"
    fi
    
    echo "total=$sum"
    echo
done

