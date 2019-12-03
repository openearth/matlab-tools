#!/bin/bash
simple_url=http://localhost:8080/opendap/data/nc/coads.nc.dods?COADSX
hard_url=http://localhost:8080/opendap/data/nc/coads.nc.dods?SST
R=20
output=results.txt
format='%{time_namelookup};%{time_connect};%{time_pretransfer};%{time_starttransfer};%{time_total};%{http_code}\n'
echo "--- $simple_url ---" > $output
echo "Lookup time;Connect time;Pretransfer time;Starttransfer time;Total time;Response" >> $output
for i in `seq 1 $R`;
do
 curl -w "$format" -o /dev/null -s $simple_url >> $output 
 sleep 1 # add sleep big enough to make sure, no load effects are measured
done
echo "--- $hard_url ---" >> $output
R=5
for i in `seq 1 $R`;
do
    curl -w "$format" -o /dev/null -s $hard_url >> $output
    sleep 1
done

