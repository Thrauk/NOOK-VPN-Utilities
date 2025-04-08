#!/bin/bash

# NOOK VPN Utilities Update Script
set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}NOOK VPN Utilities Update${NC}"
echo "This script will update all services to their latest versions."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Notice: Running without root privileges. Some operations may fail.${NC}"
    echo "Consider running with sudo if you encounter permission issues."
fi

# Create backup first
echo -e "${YELLOW}Creating backup before update...${NC}"
./scripts/backup.sh

# Check if backup was created successfully
if [ $? -ne 0 ]; then
    echo -e "${RED}Backup failed. Aborting update.${NC}"
    exit 1
fi

echo -e "${YELLOW}Updating Docker images...${NC}"
docker-compose pull

echo -e "${YELLOW}Recreating containers with updated images...${NC}"
docker-compose up -d

# Clean up old images
echo -e "${YELLOW}Cleaning up old and unused images...${NC}"
docker image prune -f

# Check if all services are running
echo -e "${YELLOW}Checking if all services are running...${NC}"
./scripts/status.sh

echo -e "${GREEN}Update complete!${NC}"
echo -e "${YELLOW}If you encounter any issues, you can restore from the backup created before the update.${NC}" 