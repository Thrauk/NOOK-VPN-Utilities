#!/bin/bash

# NOOK VPN Utilities Backup Script
set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BACKUP_DIR="backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="nook_vpn_backup_${TIMESTAMP}.tar.gz"

echo -e "${GREEN}NOOK VPN Utilities Backup${NC}"
echo "This script will backup your NOOK VPN Utilities configurations."

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Stop services if requested
read -p "Stop services before backup? [y/N]: " STOP_SERVICES
if [[ "${STOP_SERVICES}" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Stopping services...${NC}"
    docker-compose down
fi

# Create backup
echo -e "${YELLOW}Creating backup...${NC}"
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" \
    wireguard/config \
    pihole/etc-pihole \
    pihole/etc-dnsmasq.d \
    portainer/data \
    uptime-kuma/data \
    dashboard/config \
    docker-compose.yml

echo -e "${GREEN}Backup created: ${BACKUP_DIR}/${BACKUP_FILE}${NC}"

# Restart services if they were stopped
if [[ "${STOP_SERVICES}" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Restarting services...${NC}"
    docker-compose up -d
fi

echo -e "${GREEN}Backup complete!${NC}"

# Restore instructions
echo -e "${YELLOW}To restore this backup, run:${NC}"
echo -e "  ./scripts/restore.sh ${BACKUP_DIR}/${BACKUP_FILE}" 