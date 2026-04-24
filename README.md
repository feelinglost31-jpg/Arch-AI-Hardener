# 🛡️ Arch-AI-Hardener: Telegram Command Center & Watchdog

[![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-blue?logo=arch-linux)](https://archlinux.org/)
[![Status](https://img.shields.io/badge/Status-Active%20Monitoring-success)]()

**Arch-AI-Hardener** adalah sistem monitoring dan keamanan terintegrasi yang dirancang khusus untuk laptop ASUS TUF A15 yang menjalankan Arch Linux. Project ini menggabungkan otomasi Bash dengan Telegram Bot API untuk memberikan kontrol penuh dan peringatan keamanan secara real-time.

## 🚀 Key Features

* **📊 Interactive Dashboard**: Menggunakan Inline Keyboard Telegram untuk kontrol sistem satu klik.
* **⚠️ Security Watchdog**: Notifikasi instan via Telegram jika terdeteksi percobaan login gagal (Sudo/Auth/SSH).
* **🌡️ Cooling Edition Monitoring**: Pantau suhu CPU Ryzen 7 dan penggunaan RAM secara real-time untuk mencegah overheating.
* **⚔️ Automated Security Audit**: Menjalankan script hardening untuk mengevaluasi skor keamanan sistem (0-100).
* **📸 Stealth Screenshot**: Mengambil screenshot layar secara remote untuk memastikan aktivitas sistem aman.
* **🌐 Network Watchdog**: Memantau koneksi internet aktif untuk mendeteksi *external hits* yang mencurigakan.

## 🛠️ Tech Stack

- **OS**: Arch Linux (KDE Plasma / Hyprland)
- **Language**: Bash Scripting
- **API**: Telegram Bot API
- **Tools**: `jq`, `curl`, `lm_sensors`, `spectacle`, `iproute2`, `systemd-journald`

## 📂 Project Structure
```text
Arch-AI-Hardener/
├── commander.sh      # Core Bot & Dashboard Logic
├── hardener.sh       # Security Audit Engine
└── README.md         # Documentation
