#!/bin/bash
# Create the configuration files

[[ -d /etc/supervisor.conf.d ]] && ln -s /var/www/apps/netCDFKickstarter/supervisor.conf /etc/supervisor.conf.d/netCDFKickstarter
[[ -d /etc/python27-supervisor.conf.d ]] && ln -s /var/www/apps/netCDFKickstarter/supervisor.conf /etc/python27-supervisor.conf.d/netCDFKickstarter.conf

