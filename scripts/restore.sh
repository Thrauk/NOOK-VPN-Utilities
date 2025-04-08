#!/bin/bash

# NOOK VPN Utilities Restore Script
set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}NOOK VPN Utilities Restore${NC}"
echo "This script will restore your NOOK VPN Utilities configurations from a backup."

# Check if backup file is specified
if [ "$#" -ne 1 ]; then
    echo -e "${RED}Error: No backup file specified.${NC}"
    echo "Usage: $0 <backup_file.tar.gz>"
    exit 1
fi

BACKUP_FILE=$1

# Check if backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: Backup file '${BACKUP_FILE}' not found.${NC}"
    exit 1
fi

# Stop services
echo -e "${YELLOW}Stopping services...${NC}"
docker-compose down || true

# Backup current configurations
echo -e "${YELLOW}Backing up current configurations...${NC}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CURRENT_BACKUP_DIR="backups/before_restore_${TIMESTAMP}"
mkdir -p "${CURRENT_BACKUP_DIR}"

# Only backup if directories exist
for dir in wireguard/config pihole/etc-pihole pihole/etc-dnsmasq.d portainer/data uptime-kuma/data dashboard/config; do
    if [ -d "$dir" ]; then
        mkdir -p "${CURRENT_BACKUP_DIR}/$(dirname $dir)"
        cp -r "$dir" "${CURRENT_BACKUP_DIR}/$(dirname $dir)/"
    fi
done

if [ -f "docker-compose.yml" ]; then
    cp docker-compose.yml "${CURRENT_BACKUP_DIR}/"
fi

echo -e "${GREEN}Current configurations backed up to ${CURRENT_BACKUP_DIR}${NC}"

# Restore from backup
echo -e "${YELLOW}Restoring from backup...${NC}"
tar -xzf "${BACKUP_FILE}" -C ./

echo -e "${GREEN}Configurations restored from ${BACKUP_FILE}${NC}"

# Start services
echo -e "${YELLOW}Starting services...${NC}"
docker-compose up -d

echo -e "${GREEN}Restore complete!${NC}"
echo -e "${YELLOW}Access your services at the configured IP addresses.${NC}" 