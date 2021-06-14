#!/bin/bash

# User for which we install crontab
user=root

# Python version
pyver=python3

# EVENT PROCESSING every time system is booted
EVENT_PROCESSING="@reboot sleep 300 && cd /env/INAF_PRISMA/PRISMA/PRISMA_EVENT_PROCESSING/ && $(which "$pyver") ProcessEvent.py >> /env/INAF_PRISMA/logs/PRISMA_event_processing.log 2>&1"

# FREETURE DRIVER every day at midnight
EVENT_GENERATION="0 0 * * * cd /env/INAF_PRISMA/PRISMA/PRISMA_FREETURE_DRIVER/ && $(which "$pyver") EventGeneration.py >> /env/INAF_PRISMA/logs/PRISMA_event_generation.log 2>&1"

# CALIBRATION every day at 12:00
CALIBRATION="0 12 * * * cd /env/INAF_PRISMA/PRISMA/PRISMA_CALIBRATION/ && $(which "$pyver") ProcessCalibration.py >> /env/INAF_PRISMA/logs/PRISMA_calibration.log 2>&1"

# Log files creation
mkdir /env/INAF_PRISMA/logs/
touch /env/INAF_PRISMA/logs/PRISMA_event_processing.log
touch /env/INAF_PRISMA/logs/PRISMA_event_generation.log
touch /env/INAF_PRISMA/logs/PRISMA_calibration.log

# Jobs setup
(crontab -u "$user" -l ; echo "$EVENT_PROCESSING") | crontab -u "$user" -
(crontab -u "$user" -l ; echo "$EVENT_GENERATION") | crontab -u "$user" -
(crontab -u "$user" -l ; echo "$CALIBRATION") | crontab -u "$user" -
