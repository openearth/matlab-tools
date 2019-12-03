#!/bin/sh
# clean up extracted files 

rm -Rf /usr/share/tomcat6/webapps/geoserver/

# restart tomcat
service tomcat6 start

#EOF