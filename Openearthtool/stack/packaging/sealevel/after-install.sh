#!/bin/bash
# Create the configuration files
[[ -d /etc/supervisor.conf.d ]] && ln -s /var/www/apps/sealevel/supervisor.conf /etc/supervisor.conf.d/sealevel
[[ -d /etc/python27-supervisor.conf.d ]] && ln -s /var/www/apps/sealevel/supervisor.conf /etc/python27-supervisor.conf.d/sealevel.conf

