#!/bin/bash

# NOOK VPN Utilities Status Script
set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}NOOK VPN Utilities Status${NC}"
echo "Checking status of all services..."

# Check if docker is running
if ! systemctl is-active --quiet docker; then
    echo -e "${RED}Docker service is not running.${NC}"
    echo "Try starting it with: sudo systemctl start docker"
    exit 1
fi

# Check if containers are running
CONTAINERS=("wireguard" "pihole" "portainer" "uptime-kuma" "homer" "n8n")
FAILED=0

echo -e "\n${BLUE}Container Status:${NC}"
printf "%-20s %-10s %-20s\n" "SERVICE" "STATUS" "UPTIME"
printf "%.0s-" {1..50}
echo ""

for container in "${CONTAINERS[@]}"; do
    STATUS=$(docker ps --format "{{.Names}},{{.Status}}" | grep "^$container," 2>/dev/null || echo "$container,Not running")
    
    NAME=$(echo $STATUS | cut -d',' -f1)
    CONTAINER_STATUS=$(echo $STATUS | cut -d',' -f2)
    
    if [[ "$CONTAINER_STATUS" == *"Up"* ]]; then
        UPTIME=$(echo $CONTAINER_STATUS | sed 's/Up //')
        printf "${GREEN}%-20s${NC} %-10s %-20s\n" "$NAME" "Running" "$UPTIME"
    else
        printf "${RED}%-20s${NC} %-10s %-20s\n" "$NAME" "Stopped" "N/A"
        FAILED=1
    fi
done

# Check container health if available
echo -e "\n${BLUE}Container Health:${NC}"
printf "%-20s %-30s\n" "SERVICE" "HEALTH"
printf "%.0s-" {1..50}
echo ""

for container in "${CONTAINERS[@]}"; do
    HEALTH=$(docker inspect --format "{{if .State.Health}}{{.State.Health.Status}}{{else}}No health check{{end}}" "$container" 2>/dev/null || echo "Not running")
    
    if [[ "$HEALTH" == "healthy" ]]; then
        printf "${GREEN}%-20s${NC} %-30s\n" "$container" "$HEALTH"
    elif [[ "$HEALTH" == "No health check" ]]; then
        printf "${YELLOW}%-20s${NC} %-30s\n" "$container" "$HEALTH"
    else
        printf "${RED}%-20s${NC} %-30s\n" "$container" "$HEALTH"
    fi
done

# Print network info
echo -e "\n${BLUE}Network Information:${NC}"
MAIN_IP=$(hostname -I | awk '{print $1}')
echo -e "Main IP: ${GREEN}$MAIN_IP${NC}"

# List WireGuard configs
if [ -d "wireguard/config" ]; then
    echo -e "\n${BLUE}WireGuard Configurations:${NC}"
    ls -1 wireguard/config/peer* 2>/dev/null | while read -r peer; do
        PEER_NAME=$(basename "$peer")
        echo -e "- ${GREEN}$PEER_NAME${NC}"
    done
fi

# Print service URLs
echo -e "\n${BLUE}Service URLs:${NC}"
echo -e "- Pi-hole: ${GREEN}http://$MAIN_IP:8080/admin${NC}"
echo -e "- Portainer: ${GREEN}http://$MAIN_IP:9000${NC}"
echo -e "- Uptime Kuma: ${GREEN}http://$MAIN_IP:3001${NC}"
echo -e "- Homer Dashboard: ${GREEN}http://$MAIN_IP:8081${NC}"
echo -e "- n8n: ${GREEN}http://$MAIN_IP:5678${NC}"

echo -e "\n${BLUE}System Information:${NC}"
echo -e "RAM Usage: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
echo -e "Disk Usage: $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
echo -e "CPU Load: ${CPU_LOAD}%"

if [ $FAILED -eq 1 ]; then
    echo -e "\n${RED}Some services are not running properly.${NC}"
    echo -e "Use 'docker-compose logs <service_name>' to check for errors."
    echo -e "Use 'docker-compose up -d' to start all services."
    exit 1
else
    echo -e "\n${GREEN}All services are running.${NC}"
    exit 0
fi 