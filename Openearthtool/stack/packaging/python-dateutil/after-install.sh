#/bin/sh
# fix permissions
find /opt/python2.7/lib/python2.7/site-packages/dateutil -type d -print0 | xargs -0 chmod 0755
find /opt/python2.7/lib/python2.7/site-packages/dateutil -type f -print0 | xargs -0 chmod 0644
find /opt/python2.7/lib/python2.7/site-packages/python_dateutil*.egg-info -type d -print0 | xargs -0 chmod 0755
find /opt/python2.7/lib/python2.7/site-packages/python_dateutil*.egg-info -type f -print0 | xargs -0 chmod 0644
