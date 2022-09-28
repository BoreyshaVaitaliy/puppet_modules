#!/bin/bash

/usr/bin/puppet agent --test --no-daemonize --onetime -v >>/linuxcash/logs/current/puppet.log
/bin/sleep 100m
/usr/bin/puppet agent --test --no-daemonize --onetime -v >>/linuxcash/logs/current/puppet.log
