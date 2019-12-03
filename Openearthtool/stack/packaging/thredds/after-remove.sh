# clean up extracted files 


# remove the content
service tomcat6 stop

# remove the security settings
[ -f /etc/tomcat6/Catalina/localhost/thredds.xml ] && rm /etc/tomcat6/Catalina/localhost/thredds.xml
# if /var/lib/opendap is a directory, remove it, but don't bother if it doesn't work
[ -d /var/lib/opendap ] && rmdir /var/lib/opendap 2>/dev/null


# remove the extracted war file
rm -r /var/lib/tomcat6/webapps/thredds

# remove the directory if it only has the thredds in there
rm -r /var/lib/tomcat6/content/thredds 

# remove the directory if it is empty 
# and if it is removed, also remove the symlink if it exists
rmdir /var/lib/tomcat6/content 2>/dev/null && [ -L /usr/share/tomcat6/content ] && rm /usr/share/tomcat6/content

# restart tomcat
service tomcat6 start

