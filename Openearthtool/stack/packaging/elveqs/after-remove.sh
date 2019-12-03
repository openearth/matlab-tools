#!/bin/bash
# Remove the symbolic links
NAME=elveqs

[[ -h /etc/supervisor.conf.d/elveqs ]] && rm /etc/supervisor.conf.d/elveqs
[[ -h /etc/python27-supervisor.conf.d/elveqs.conf ]] && rm /etc/python27-supervisor.conf.d/elveqs.conf

rm -rf /opt/venvs/$NAME
rm -rf /var/www/apps/$NAME
