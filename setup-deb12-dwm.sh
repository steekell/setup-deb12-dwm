#!/bin/bash

# Affiche une checklist interactive
OPTIONS=$(whiptail --title "Installation Debian 12 personnalisée" --checklist \
"Choisissez les options à activer avec Espace puis Entrée :" 20 78 12 \
"wifi" "Activer le Wi-Fi" OFF \
"bluetooth" "Activer le Bluetooth" OFF \
"fingerprint" "Activer le lecteur d'empreintes" OFF \
"nvme" "Utiliser le SSD NVMe" ON \
"i5" "Optimiser pour CPU i5-10210U" OFF \
"batterie" "Optimisation batterie (TLP + réglages ACPI)" OFF \
"dwm" "Installer DWM depuis les sources avec gape" ON \
"multimedia" "Configurer les touches multimédia (volume, luminosité...)" ON \
3>&1 1>&2 2>&3)

# Fonction utilitaire
contains() {
    [[ "$OPTIONS" == *"$1"* ]] && return 0 || return 1
}

# ---- Modules d'installation ----

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
    echo "🪟 Installation de DWM avec gape..."
    # apt install git build-essential libx11-dev libxft-dev libxinerama-dev
    # git clone https://github.com/gapepi/gape ~/.local/src/gape
    # cd ~/.local/src/gape && ./gape.sh install dwm
    # echo 'exec dwm' > ~/.xinitrc
fi

if contains "multimedia"; then
    echo "🎚️ Configuration des touches multimédia..."
    # apt install xbindkeys xbacklight amixer acpi-support
    # touch ~/.xbindkeysrc && echo "\"amixer set Master 5%+\"\n   XF86AudioRaiseVolume" >> ~/.xbindkeysrc
    # # Ajouter plus de mappings pour XF86AudioLowerVolume, XF86MonBrightnessUp, etc.
fi