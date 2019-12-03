#!/usr/bin/env bash


wget http://ftp.nluug.nl/pub/os/Linux/distr/fedora-epel/6/i386/epel-release-6-8.noarch.rpm
yum install -y epel-release-6-8.noarch.rpm
yum install -y netcdf.x86_64
yum install -y http://al-ng001.xtr.deltares.nl/yum/CentOS/6/x86_64/OpenEarthStack/thredds-4.3-25.noarch.rpm
service tomcat6 start
yum install -y nco
cp /var/lib/tomcat6/content/thredds/threddsConfig-OpenEarth.xml /var/lib/tomcat6/content/thredds/threddsConfig.xml
cp /var/lib/tomcat6/content/thredds/catalog-OpenEarth.xml /var/lib/tomcat6/content/thredds/catalog.xml
sed -i 's/My\ Group/OpenEarth/g' /var/lib/tomcat6/content/thredds/threddsConfig.xml
sed -i 's/http:\/\/www.my.site\//http:\/\/www.openearth.nl\//g' /var/lib/tomcat6/content/thredds/threddsConfig.xml
sed -i 's/support@my.group/c.denheijer@tudelft.nl/g' /var/lib/tomcat6/content/thredds/threddsConfig.xml
service tomcat6 restart
service iptables stop
