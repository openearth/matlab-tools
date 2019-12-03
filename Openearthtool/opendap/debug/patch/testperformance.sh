#!/bin/bash
url=http://localhost:8080/opendap/data/coads_climatology.nc.ascii?COADSX
R=20
output=results.txt
format='%{time_namelookup};%{time_connect};%{time_pretransfer};%{time_starttransfer};%{time_total};%{http_code}\n'
echo "Lookup time;Connect time;Pretransfer time;Starttransfer time;Total time;Response" > $output
for i in `seq 1 $R`;
do
 curl -w "$format" -o /dev/null -s $url >> $output
 sleep 1 # add sleep big enough to make sure, no load effects are measured
done

