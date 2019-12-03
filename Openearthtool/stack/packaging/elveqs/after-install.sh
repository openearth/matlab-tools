#!/bin/bash
# Create the configuration files

[[ -d /etc/supervisor.conf.d ]] && ln -s /var/www/apps/elveqs/supervisor.conf /etc/supervisor.conf.d/elveqs
[[ -d /etc/python27-supervisor.conf.d ]] && ln -s /var/www/apps/elveqs/supervisor.conf /etc/python27-supervisor.conf.d/elveqs.conf

