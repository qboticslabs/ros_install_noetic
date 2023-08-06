#!/bin/bash -eu

# The BSD License
# Copyright (c) 2020 Qbotics Labs Pvt Ltd
# Copyright (c) 2014 OROCA and ROS Korea Users Group

#set -x
#
# DEBUGING errors while installations? Run below command to find any package that is problematic
# sudo dpkg --configure -a
#
# purge remove the packages that're listed from above command
# ex: sudo apt remove --purge python3-rosinstall-generator python3-rosdistro-modules python3-rosdep-modules python3-rospkg-modules python3-rosdistro ....
#
# If there's further problems with a specific package, we can find and remove those files, first by listing them
# sudo ls -l /var/lib/dpkg/info | grep -i package_name
#
# and once we know where they're, remove them manually
# sudo rm -r /var/lib/dpkg/info/package-name.*
#
# and finally update the packages by running
# sudo apt update
#
echo "Add the GPG key to the system"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F42ED6FBAB17C654

name_ros_distro=noetic 
user_name=$(whoami)
echo "#######################################################################################################################"
echo ""
echo ">>> {Starting ROS Noetic Installation}"
echo ""
echo ">>> {Checking your Ubuntu version} "
echo ""
#Getting version and release number of Ubuntu
version=`lsb_release -sc`
relesenum=`grep DISTRIB_DESCRIPTION /etc/*-release | awk -F 'Ubuntu ' '{print $2}' | awk -F ' LTS' '{print $1}'`
echo ">>> {Your Ubuntu version is: [Ubuntu $version $relesenum]}"
#Checking version is focal, if yes proceed othervice quit
case $version in
  "focal" )
  ;;
  *)
    echo ">>> {ERROR: This script will only work on Ubuntu Focal (20.04).}"
    exit 0
esac

echo ""
echo ">>> {Ubuntu Focal 20.04 is fully compatible with Ubuntu Focal 20.04}"
echo ""
echo "#######################################################################################################################"
echo ">>> {Step 1: Configure your Ubuntu repositories}"
echo ""
#Configure your Ubuntu repositories to allow "restricted," "universe," and "multiverse." You can follow the Ubuntu guide for instructions on doing this. 
#https://help.ubuntu.com/community/Repositories/Ubuntu

sudo add-apt-repository universe
sudo add-apt-repository restricted
sudo add-apt-repository multiverse

sudo apt update

echo ""
echo ">>> {Done: Added Ubuntu repositories}"
echo ""
echo "#######################################################################################################################"
echo ">>> {Step 2: Setup your sources.list}"
echo ""

#This will add the ROS Noetic package list to sources.list 
sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${version} main\" > /etc/apt/sources.list.d/ros-latest.list"

#Checking file added or not
if [ ! -e /etc/apt/sources.list.d/ros-latest.list ]; then
  echo ">>> {Error: Unable to add sources.list, exiting}"
  exit 0
fi

echo ">>> {Done: Added sources.list}"
echo ""
echo "#######################################################################################################################"
echo ">>> {Step 3: Set up your keys}"
echo ""
echo ">>> {Installing curl for adding keys}"
#Installing curl: Curl instead of the apt-key command, which can be helpful if you are behind a proxy server: 
#TODO:Checking package is not working sometimes, so disabling it
#Checking curl is installed or not
#name=curl
#which $name > /dev/null 2>&1

#if [ $? == 0 ]; then
#    echo "Curl is already installed!"
#else
#    echo "Curl is not installed,Installing Curl"

sudo apt install -y curl
#fi

echo "#######################################################################################################################"
echo ""
#Adding keys
echo ">>> {Waiting for adding keys, it will take few seconds}"
echo ""
ret=$(curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -)

#Checking return value is OK
case $ret in
  "OK" )
  ;;
  *)
    echo ">>> {ERROR: Unable to add ROS keys}"
    exit 0
esac

echo ">>> {Done: Added Keys}"
echo ""
echo "#######################################################################################################################"
echo ">>> {Step 4: Updating Ubuntu package index, this will take few minutes depend on your network connection}"
echo ""
sudo apt update
echo ""
echo "#######################################################################################################################"
echo ">>> {Step 5: Install ROS, you pick how much of ROS you would like to install.}"
echo "     [1. Desktop-Full Install: (Recommended) : Everything in Desktop plus 2D/3D simulators and 2D/3D perception packages ]"
echo ""
echo "     [2. Desktop Install: Everything in ROS-Base plus tools like rqt and rviz]"
echo ""
echo "     [3. ROS-Base: (Bare Bones) ROS packaging, build, and communication libraries. No GUI tools.]"
echo ""
#Assigning default value as 1: Desktop full install
read -p "Enter your install (Default is 1):" answer 

case "$answer" in
  1)
    package_type="desktop-full"
    ;;
  2)
    package_type="desktop"
    ;;
  3)
    package_type="ros-base"
    ;;
  * )
    package_type="desktop-full"
    ;;
esac
echo "#######################################################################################################################"
echo ""
echo ">>>  {Starting ROS installation, this will take about 20 min. It will depends on your internet  connection}"
echo ""
sudo apt-get install -y ros-${name_ros_distro}-${package_type} 
echo ""
echo ""
echo "#######################################################################################################################"
echo ">>> {Step 6: Setting ROS Environment, This will add ROS environment to .bashrc.}" 
echo ">>> { After adding this, you can able to access ROS commands in terminal}"
echo ""
echo "source /opt/ros/${name_ros_distro}/setup.bash" >> /home/$user_name/.bashrc
source /home/$user_name/.bashrc
sudo apt install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
sudo rosdep init
rosdep update
echo ""
echo "#######################################################################################################################"
echo ">>> {Step 7: Testing ROS installation, checking ROS version.}"
echo ""
echo ">>> {Type [ rosversion -d ] to get the current ROS installed version}"
echo ""
echo "#######################################################################################################################"


pip3 install opencv-python
sudo apt install --reinstall gdal-bin libgdal-dev python3-gdal

# I got errors install this package about dependant packages
# sudo apt-get install ros-noetic-cv-bridge

sudo apt-get install ros-${name_ros_distro}-tf ros-${name_ros_distro}-message-filters ros-${name_ros_distro}-image-transport

### As part of Ceres installation http://ceres-solver.org/installation.html#linux
# CMake
sudo apt-get install cmake
# google-glog + gflags
sudo apt-get install libgoogle-glog-dev libgflags-dev
# Use ATLAS for BLAS & LAPACK
sudo apt-get install libatlas-base-dev
# Eigen3
sudo apt-get install libeigen3-dev
# SuiteSparse (optional)
sudo apt-get install libsuitesparse-dev


### build, test, and install Ceres.
tar zxf ceres-solver-2.1.0.tar.gz
mkdir ceres-bin
cd ceres-bin
cmake ../ceres-solver-2.1.0
make -j3
make test
# Optionally install Ceres, it can also be exported using CMake which
# allows Ceres to be used without requiring installation, see the documentation
# for the EXPORT_BUILD_DIR option for more information.
make install

## source bash profile to make sure following commands can find the packages
source /home/$user_name/.bashrc

## OpenCV installation
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.x.zip
unzip opencv.zip
mv opencv-4.x opencv
rm opencv.zip

mkdir -p build && cd build

# Configure - generate build scripts for the preferred build system
cmake ../opencv
# Build - run actual compilation process
make -j4
# will install openCV to /usr/local/
sudo make install



## Boost package installation
wget https://boostorg.jfrog.io/artifactory/main/release/1.81.0/source/boost_1_81_0.tar.gz
mkdir boost-ver && cd boost-ver
tar -xzf ../boost_*.tar.gz
cd boost_*/
./bootstrap.sh
# building and installing
sudo ./b2 install


## install cv-bridge now
# first install all dependencies for libboost-dev
sudo apt-get install libboost-atomic-dev libboost-chrono-dev libboost-container-dev libboost-context-dev libboost-coroutine-dev libboost-date-time-dev libboost-dev libboost-exception-dev libboost-fiber-dev libboost-filesystem-dev libboost-graph-dev libboost-graph-parallel-dev libboost-iostreams-dev libboost-locale-dev libboost-log-dev libboost-math-dev libboost-mpi-dev libboost-mpi-python-dev libboost-numpy-dev libboost-program-options-dev libboost-python-dev libboost-random-dev libboost-regex-dev libboost-serialization-dev libboost-stacktrace-dev libboost-system-dev libboost-test-dev libboost-thread-dev libboost-timer-dev libboost-tools-dev libboost-type-erasure-dev libboost-wave-dev libboost-mpi1.71-dev libboost-mpi-python1.71-dev mpi-default-dev libopenmpi-dev libibverbs-dev libnl-3-200=3.4.0-1 libnl-route-3-200=3.4.0-1 libnl-3-dev libnl-route-3-dev
# and all dependencies for libopencv-dev
sudo apt-get install libc6 libgcc-s1 libilmbase-dev libopencv-calib3d-dev libopencv-calib3d4.2 libopencv-contrib-dev libopencv-contrib4.2 libopencv-core-dev libopencv-core4.2 libopencv-dnn-dev libopencv-features2d-dev libopencv-features2d4.2 libopencv-flann-dev libopencv-highgui-dev libopencv-highgui4.2 libopencv-imgcodecs-dev libopencv-imgcodecs4.2 libopencv-imgproc-dev libopencv-imgproc4.2 libopencv-ml-dev libopencv-objdetect-dev libopencv-photo-dev libopencv-shape-dev libopencv-stitching-dev libopencv-superres-dev libopencv-ts-dev libopencv-video-dev libopencv-videoio-dev libopencv-videoio4.2 libopencv-videostab-dev libopencv-viz-dev libopencv4.2-java libstdc++6 libgphoto2-dev libgphoto2-6=2.5.24-1
## this might remove following packages that can be installed later, if needed
#libgphoto2-6:i386 libsane:i386 libwine:i386 wine32:i386
# and finally try installing the opencv-bridge
sudo apt install ros-noetic-cv-bridge