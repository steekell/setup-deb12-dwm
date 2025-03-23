#!/bin/bash

# Définir l'utilisateur à configurer
read -p "Entrez le nom d'utilisateur à configurer : " USERNAME

# Affiche une checklist interactive
OPTIONS=$(whiptail --title "Installation Debian 12 personnalisée" --checklist \
"Choisissez les options à activer avec Espace puis Entrée :" 20 78 12 \
"sudo" "Ajouter l'utilisateur au groupe sudo" OFF \
"wifi" "Activer le Wi-Fi" OFF \
"bluetooth" "Activer le Bluetooth" OFF \
"fingerprint" "Activer le lecteur d'empreintes" OFF \
"nvme" "Utiliser le SSD NVMe" OFF \
"i5" "Optimiser pour CPU i5-10210U" OFF \
"batterie" "Optimisation batterie (TLP + réglages ACPI)" OFF \
"dwm" "Installer DWM depuis les sources avec gape" OFF \
"multimedia" "Configurer les touches multimédia (volume, luminosité...)" OFF \
3>&1 1>&2 2>&3)

# Fonction utilitaire
contains() {
    [[ "$OPTIONS" == *"$1"* ]] && return 0 || return 1
}

# ---- Modules d'installation ----

if contains "sudo"; then
    echo "➕ Ajout de $USERNAME au groupe sudo..."
    usermod -aG sudo "$USERNAME"
fi

if contains "wifi"; then
    echo "🔧 Installation et configuration du Wi-Fi..."
    # apt install firmware-iwlwifi network-manager
fi

if contains "bluetooth"; then
    echo "🔧 Installation du Bluetooth..."
    # apt install bluetooth bluez blueman
fi

if contains "fingerprint"; then
    echo "🔧 Installation du lecteur d'empreintes..."
    # apt install fprintd libpam-fprintd
fi

if contains "nvme"; then
    echo "⚙️ Optimisation SSD NVMe..."
    # systemctl enable fstrim.timer
fi

if contains "i5"; then
    echo "⚙️ Optimisation CPU Intel i5-10210U..."
    # apt install intel-microcode cpufrequtils
    # echo 'GOVERNOR="ondemand"' > /etc/default/cpufrequtils
fi

if contains "batterie"; then
    echo "🔋 Optimisation batterie..."
    # apt install tlp tlp-rdw acpi acpid
    # systemctl enable tlp
    # systemctl start tlp
fi

if contains "dwm"; then
    echo "🪟 Installation de DWM avec gaps (FLEXTILE_DELUXE_LAYOUT uniquement)..."
    apt install -y git build-essential libx11-dev libxft-dev libxinerama-dev
    mkdir -p /home/$USERNAME/.local/src && cd /home/$USERNAME/.local/src
    git clone https://github.com/bakkeby/dwm-flexipatch dwm
    cd dwm

    # Activer les gaps dans le config.h
    sed -i 's|.*#define FLEXTILE_DELUXE_LAYOUT.*|#define FLEXTILE_DELUXE_LAYOUT 1|' config.def.h
    sed -i 's|.*#define VANITYGAPS_PATCH.*|#define VANITYGAPS_PATCH 1|' config.def.h
    
    make && make install

    echo 'exec dwm' > /home/$USERNAME/.xinitrc
    chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc
fi

if contains "multimedia"; then
    echo "🎚️ Configuration des touches multimédia..."
    # apt install xbindkeys xbacklight amixer acpi-support
    # touch ~/.xbindkeysrc && echo "\"amixer set Master 5%+\"\n   XF86AudioRaiseVolume" >> ~/.xbindkeysrc
    # # Ajouter plus de mappings pour XF86AudioLowerVolume, XF86MonBrightnessUp, etc.
fi