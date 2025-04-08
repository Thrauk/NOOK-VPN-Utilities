#!/bin/bash

# NOOK VPN Utilities Autostart Setup Script
set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}NOOK VPN Utilities Autostart Setup${NC}"

# Get the absolute path of the project directory
PROJECT_DIR=$(pwd)

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script needs to be run with sudo privileges.${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

# Create a copy of the service file with the correct path
echo -e "${YELLOW}Creating systemd service file...${NC}"
sed "s|/path/to/NOOK-VPN-Utilities|$PROJECT_DIR|g" scripts/nook-vpn.service > /etc/systemd/system/nook-vpn.service

# Reload systemd daemon
echo -e "${YELLOW}Reloading systemd...${NC}"
systemctl daemon-reload

# Enable the service to start on boot
echo -e "${YELLOW}Enabling service to start at boot...${NC}"
systemctl enable nook-vpn.service

# Starting the service
echo -e "${YELLOW}Starting the service...${NC}"
systemctl start nook-vpn.service

# Check status
echo -e "${YELLOW}Checking service status...${NC}"
systemctl status nook-vpn.service

echo -e "${GREEN}NOOK VPN Utilities has been configured to start automatically at system boot.${NC}"
echo -e "${YELLOW}You can check the status anytime with: sudo systemctl status nook-vpn.service${NC}"
echo -e "${YELLOW}To disable autostart: sudo systemctl disable nook-vpn.service${NC}" 