#!/bin/bash

# NOOK VPN Utilities Setup Script
set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}NOOK VPN Utilities Setup${NC}"
echo "This script will help you set up your NOOK VPN Utilities on your mini PC."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce
    sudo systemctl enable docker
    sudo systemctl start docker
    echo -e "${GREEN}Docker installed successfully!${NC}"
else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose not found. Installing Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully!${NC}"
else
    echo -e "${GREEN}Docker Compose is already installed.${NC}"
fi

# Get server IP
DEFAULT_IP=$(hostname -I | awk '{print $1}')
read -p "Enter your server IP address [$DEFAULT_IP]: " SERVER_IP
SERVER_IP=${SERVER_IP:-$DEFAULT_IP}

# Update Pi-hole password
read -s -p "Set Pi-hole admin password: " PIHOLE_PASSWORD
echo ""

# Update n8n credentials
read -p "Set n8n username [admin]: " N8N_USERNAME
N8N_USERNAME=${N8N_USERNAME:-admin}
read -s -p "Set n8n password: " N8N_PASSWORD
echo ""

# Create necessary directories
mkdir -p wireguard/config pihole/etc-pihole pihole/etc-dnsmasq.d portainer/data uptime-kuma/data dashboard/config n8n/data

# Update docker-compose.yml file with the server IP and passwords
sed -i "s/ServerIP: 192.168.1.10/ServerIP: $SERVER_IP/g" docker-compose.yml
sed -i "s/WEBPASSWORD: 'pihole_password'/WEBPASSWORD: '$PIHOLE_PASSWORD'/g" docker-compose.yml

# Update n8n configuration
sed -i "s/N8N_BASIC_AUTH_USER=admin/N8N_BASIC_AUTH_USER=$N8N_USERNAME/g" docker-compose.yml
sed -i "s/N8N_BASIC_AUTH_PASSWORD=changeme/N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD/g" docker-compose.yml
sed -i "s/N8N_HOST=192.168.1.10/N8N_HOST=$SERVER_IP/g" docker-compose.yml
sed -i "s#WEBHOOK_URL=http://192.168.1.10:5678/#WEBHOOK_URL=http://$SERVER_IP:5678/#g" docker-compose.yml

# Update URLs in homer dashboard config
sed -i "s/192.168.1.10/$SERVER_IP/g" dashboard/config/config.yml

echo -e "${GREEN}Configuration updated with your IP address: $SERVER_IP${NC}"
echo -e "${YELLOW}Starting services...${NC}"

# Start services
docker-compose up -d

echo -e "${GREEN}Services started successfully!${NC}"
echo -e "${YELLOW}WireGuard config will be available in: ./wireguard/config${NC}"
echo -e "${YELLOW}Access Pi-hole at: http://$SERVER_IP:8080/admin${NC}"
echo -e "${YELLOW}Access Portainer at: http://$SERVER_IP:9000${NC}"
echo -e "${YELLOW}Access Uptime Kuma at: http://$SERVER_IP:3001${NC}"
echo -e "${YELLOW}Access Homer Dashboard at: http://$SERVER_IP:8081${NC}"
echo -e "${YELLOW}Access n8n at: http://$SERVER_IP:5678${NC}"

echo -e "${GREEN}Setup complete!${NC}" 