#!/bin/bash -eu

# The BSD License
# Copyright (c) 2023 Qbotics Labs Pvt Ltd

#set -x

echo "################################################################"
echo ""
echo ">>> {Uninstalling ROS Humble Installation from your computer}"
echo ""
echo ">>> {It will take around few minutes to complete}"
echo ""
sudo apt-get purge ros-*
echo ""
echo "#################################################################"
echo ""
echo ">>> {Auto removing dependent packages}"
sudo apt-get autoremove
echo ""
echo ">>> {Done: ROS Humble Uninstall}"
echo "#################################################################"

