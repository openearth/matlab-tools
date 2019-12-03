 # Overwrite the config files
# restart tomcat


#  [ ! -f /etc/tomcat6/Catalina/localhost/thredds.xml ] && echo "${threddsxml}" > /etc/tomcat6/Catalina/localhost/thredds.xml #


# create a content directory and symlink it
[ ! -d /var/lib/tomcat6/content ] && mkdir /var/lib/tomcat6/content
[ ! -L /usr/share/tomcat6/content ] && ln -s /var/lib/tomcat6/content /usr/share/tomcat6/content

# # Create a data directory
# [ ! -d /var/lib/opendap ] && mkdir /var/lib/opendap

# tomcat may write content
chmod 775 /var/lib/tomcat6/content
chown root:tomcat /var/lib/tomcat6/content

# # tomcat may read data
# chmod 775 /var/lib/opendap
# chown root:tomcat /var/lib/opendap


# restart tomcat
service tomcat6 restart


