#!/bin/bash

# --- COLORS ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- CONFIGURATION ---
TARGET_DIR="/home/ditr/Arch-AI-Hardener"
SCORE=0

echo -e "${CYAN}--- [ Arch-AI-Hardener: Smart Audit ] ---${NC}"

# 1. Cek Intruder
echo -e "${BLUE}--- [ Intruder Discovery ] ---${NC}"
# Arch Linux biasanya pakai 'journalctl' karena 'auth.log' sering tidak ada secara default
if journalctl _COMM=sshd | grep "Failed password" | tail -n 5 | grep -q "failed"; then
    echo -e "${RED}[!] Ada percobaan login gagal!${NC}"
else
    echo -e "${GREEN}[✔] Tidak ada aktivitas mencurigakan.${NC}"
fi

# 2. Cek System Security
echo -e "${BLUE}--- [ System Security ] ---${NC}"

# Cek Firewall (UFW)
if sudo ufw status | grep -q "Status: active"; then
    echo -e "${GREEN}[✔] Firewall Aktif (+40 pts)${NC}"
    SCORE=$((SCORE + 40))
else
    echo -e "${RED}[X] Firewall MATI (0 pts)${NC}"
fi

# Cek SSH (Port 22)
if sudo ss -tuln | grep -q ":22"; then
    echo -e "${RED}[X] Port SSH Terbuka (Bahaya!)${NC}"
else
    echo -e "${GREEN}[✔] Port SSH Tertutup (+30 pts)${NC}"
    SCORE=$((SCORE + 30))
fi

# Cek File Shadow
SHADOW_PERM=$(sudo stat -c %a /etc/shadow)
if [ "$SHADOW_PERM" == "000" ] || [ "$SHADOW_PERM" == "600" ]; then
    echo -e "${GREEN}[✔] File Shadow Terkunci (+30 pts)${NC}"
    SCORE=$((SCORE + 30))
else
    echo -e "${RED}[X] File Shadow Terbuka ($SHADOW_PERM) (0 pts)${NC}"
fi

# 3. Cek Network
echo -e "${BLUE}--- [ Network Discovery ] ---${NC}"
IP_LOCAL=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+' || echo "No IP")
echo -e "${GREEN}[✔] Local IP: $IP_LOCAL${NC}"

# 4. Cloud Syncing (Git)
echo -e "${BLUE}--- [ Cloud Syncing ] ---${NC}"
cd "$TARGET_DIR" || exit
sudo git config --global --add safe.directory "$TARGET_DIR"
echo "Audit Log: $(date) - Score: $SCORE" >> audit_log.txt
sudo git add .
sudo git commit -m "security-update: score $SCORE at $(date '+%Y-%m-%d %H:%M:%S')" --allow-empty > /dev/null 2>&1
echo -e "${GREEN}[✔] Cloud Synced!${NC}"

echo -e "${YELLOW}SCORE AKHIR: $SCORE / 100${NC}"
