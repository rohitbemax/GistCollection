#!/bin/bash

#Size in MB to dump (1024 * x) = y for GB
dumpSize=9200

while :
do 
    pid="$(ps -eaf | grep -i 'serviceName=connectors-classic' | grep -i [j]ava  | awk '{print $2}')"
    
    heapSizeUsed="$(jstat -gc $pid | tail -f | awk '{split($0,a," "); sum=((a[3]+a[4]+a[6]+a[8])/1024); if(sum > 0) print sum};')" 
    echo "Current heap size used in MB:>$heapSizeUsed<"

    heapSizeIntUsed="$(printf %.0f $heapSizeUsed)"
    if [ $heapSizeIntUsed -gt $dumpSize ]
    then
        echo "Heap reached threshold $heapSizeIntUsed, will start dumping heap now"
        jmap -dump:live,file=./connector28aug123.bin $pid

        if [ -f ./connector28aug123.bin ]
        then
            echo "Heap Dump completed & file created, will exit"
            exit
        else
            echo "Heap dump not found will continue"
        fi
    fi

    echo "Will sleep, heap still below threshold"
    sleep 5
done
