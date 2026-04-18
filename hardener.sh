#!/bin/bash

# --- Arch-AI-Hardener v1.3: Network Aware ---
# Author: Suditro Pratama

# Definisi Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

score=0
fix_needed=false
log_file="/home/ditr/Arch-AI-Hardener/audit.log"
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

echo -e "${BLUE}--- [ Arch-AI-Hardener: Smart Audit ] ---${NC}"

# --- BAGIAN 1: AUDIT FIREWALL & SYSTEM ---
if sudo ufw status | grep -q "active"; then
    echo -e "[${GREEN}✔${NC}] Firewall Aktif (+40 pts)"
    ((score+=40))
else
    echo -e "[${RED}✘${NC}] Firewall MATI!"
    fix_needed=true
fi

if sudo ufw status | grep -q "22"; then
    echo -e "[${YELLOW}!${NC}] Port SSH Masih Terbuka! (-20 pts)"
    fix_needed=true
else
    echo -e "[${GREEN}✔${NC}] Port SSH Tertutup (+30 pts)"
    ((score+=30))
fi

if [[ $(stat -c "%a" /etc/shadow) == "600" ]]; then
    echo -e "[${GREEN}✔${NC}] File Shadow Terkunci Aman (+30 pts)"
    ((score+=30))
else
    echo -e "[${RED}✘${NC}] File Shadow Terlalu Terbuka!"
    fix_needed=true
fi

# --- BAGIAN 2: NETWORK DISCOVERY ---
echo -e "${BLUE}--- [ Network Discovery ] ---${NC}"
interface=$(nmcli -t -f DEVICE,STATE device | grep ":connected" | cut -d: -f1 | head -n1)

if [ -z "$interface" ]; then
    echo -e "[${RED}!${NC}] Status: DISCONNECTED"
else
    echo -e "[${GREEN}✔${NC}] Interface: $interface"
    ip_addr=$(ip addr show $interface | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    echo -e "[${GREEN}✔${NC}] Local IP: ${YELLOW}$ip_addr${NC}"
    
    public_ip=$(curl -s --max-time 2 ifconfig.me)
    if [ -n "$public_ip" ]; then
        echo -e "[${GREEN}✔${NC}] Public IP: ${YELLOW}$public_ip${NC}"
    else
        echo -e "[${YELLOW}!${NC}] Public IP: Offline/Timed Out"
    fi
fi
echo -e "${BLUE}---------------------------------------${NC}"

# --- BAGIAN 3: SCORE & LOGGING ---
echo -e "SECURITY SCORE ANDA: ${YELLOW}$score / 100${NC}"
echo -e "${BLUE}---------------------------------------${NC}"

echo "[$timestamp] Audit Score: $score/100 | IP: $ip_addr" >> $log_file

# Auto-Fix
if [ "$fix_needed" = true ] && [ -t 0 ]; then
    read -p "Sistem belum optimal. Jalankan Auto-Fix? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        sudo ufw --force enable > /dev/null
        sudo ufw delete allow 22 > /dev/null
        sudo chmod 600 /etc/shadow
        echo "[$timestamp] AUTO-FIX EXECUTED" >> $log_file
        echo -e "${GREEN}[✔] Perbaikan selesai!${NC}"
    fi
fi
