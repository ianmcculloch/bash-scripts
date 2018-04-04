#!/bin/bash

#Update the list and confirm success
notify-send 'Working...' --icon=process-working
echo "Working..."
apt-get update -qq
echo "Lists updated"

#Upgrade all the packages whitout asking for confirmation and confirm success
apt-get upgrade -qq --force-yes
echo "Packages upgraded"

#Remove unneeded packages and confirm success
apt-get autoremove -qq
#echo "Old packages removed"

#Remve unneeded packages and confirm success, alternate version
apt-get autoclean -qq
echo "Old packages removed"
