#!/bin/bash

# --- Arch-AI-Hardener Dasar ---
# Author: Suditro Pratama (feelinglost31-jpg)

echo "[+] Memulai Proses Hardening Sistem..."

# 1. Cek Permission File Sensitif
echo "[!] Mengetatkan izin akses file sensitif (/etc/shadow, /etc/passwd)..."
sudo chmod 600 /etc/shadow
sudo chmod 644 /etc/passwd
sudo chmod 600 /etc/gshadow
sudo chmod 644 /etc/group

# 2. Pengaturan Firewall (Menggunakan UFW agar simpel dan cepat)
echo "[!] Mengatur Firewall (UFW)..."
if ! command -v ufw &> /dev/null; then
    echo "[-] UFW belum terinstall. Menginstall sekarang..."
    sudo pacman -S ufw --noconfirm
fi
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh  # Biar kamu nggak terkunci kalau remote
sudo ufw --force enable

# 3. Audit Log Sistem Dasar
echo "[!] Melakukan Audit Log Dasar (Cek login gagal)..."
echo "--- Percobaan Login Gagal Terakhir ---"
sudo journalctl _SYSTEMD_UNIT=sshd.service | grep "Failed password" | tail -n 5
lastb | head -n 5

echo "[+] Hardening Selesai! Sistem sekarang lebih aman."
