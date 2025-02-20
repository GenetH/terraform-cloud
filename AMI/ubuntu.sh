#!/bin/bash

# Ensure the system is fully updated
sudo apt update -y
sudo apt upgrade -y

# Add necessary repositories
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt update -y

# Install required packages
sudo apt install -y openjdk-11-jre openjdk-11-jdk net-tools

sudo apt install -y  git mysql-client wget vim telnet htop python3 chrony net-tools