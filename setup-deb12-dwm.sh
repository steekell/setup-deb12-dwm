#!/bin/bash

# ---------------------------
# Script d'installation Debian 12 personnalisé pour Acer Travelmate P214
# ---------------------------

set -e

# ---------------------------
# Boucle principale pour relancer si aucune option n'est sélectionnée
# ---------------------------
while true; do
  # Définir l'utilisateur à configurer à chaque boucle
  USERNAME=$(whiptail --inputbox "Entrez le nom de l'utilisateur à configurer :" 10 60 --title "Utilisateur" 3>&1 1>&2 2>&3)

  if [ -z "$USERNAME" ]; then
    whiptail --title "Erreur" --msgbox "Vous devez renseigner un nom d'utilisateur valide." 10 60
    continue
  fi

  OPTIONS=$(whiptail --title "Installation Debian 12 personnalisée" --checklist \ 
  "Choisissez les options à activer avec Espace puis Entrée :" 20 78 13 \ 
  "wifi" "Activer le Wi-Fi" OFF \ 
  "bluetooth" "Activer le Bluetooth" OFF \ 
  "fingerprint" "Activer le lecteur d'empreintes" OFF \ 
  "nvme" "Utiliser le SSD NVMe" ON \ 
  "i5" "Optimiser pour CPU i5-10210U" OFF \ 
  "batterie" "Optimisation batterie (TLP + réglages ACPI)" OFF \ 
  "sudo" "Ajouter l'utilisateur au groupe sudo" ON \ 
  "dwm" "Installer DWM avec gaps depuis les sources" ON \ 
  "multimedia" "Configurer les touches multimédia (volume, luminosité...)" ON \ 
  3>&1 1>&2 2>&3)

  if [ -n "$OPTIONS" ]; then
    break
  else
    whiptail --title "Aucune sélection" --msgbox "Vous devez sélectionner au moins une option." 10 60
  fi

done

contains() {
    [[ "$OPTIONS" == *"$1"* ]] && return 0 || return 1
}

# ---------------------------
# Modules d'installation
# ---------------------------

if contains "sudo"; then
    echo "➕ Ajout de $USERNAME au groupe sudo..."
    usermod -aG sudo "$USERNAME"
fi

if contains "wifi"; then
    echo "🔧 Installation et configuration du Wi-Fi..."
    apt install -y firmware-iwlwifi network-manager
    systemctl enable NetworkManager
fi

if contains "bluetooth"; then
    echo "🔧 Installation du Bluetooth..."
    apt install -y bluetooth bluez blueman
    systemctl enable bluetooth
fi

if contains "fingerprint"; then
    echo "🔧 Installation du lecteur d'empreintes..."
    apt install -y fprintd libpam-fprintd
fi

if contains "nvme"; then
    echo "⚙️ Optimisation SSD NVMe..."
    systemctl enable fstrim.timer
fi

if contains "i5"; then
    echo "⚙️ Optimisation CPU Intel i5-10210U..."
    apt install -y intel-microcode cpufrequtils
    echo 'GOVERNOR="ondemand"' > /etc/default/cpufrequtils
    systemctl enable cpufrequtils
fi

if contains "batterie"; then
    echo "🔋 Optimisation batterie..."
    apt install -y tlp tlp-rdw acpi acpid
    systemctl enable tlp
    systemctl start tlp
fi

if contains "dwm"; then
    echo "🪟 Installation de DWM avec gaps (FLEXTILE_DELUXE_LAYOUT uniquement)..."
    apt install -y git build-essential libx11-dev libxft-dev libxinerama-dev
    mkdir -p /home/$USERNAME/.local/src && cd /home/$USERNAME/.local/src
    git clone https://github.com/bakkeby/dwm-flexipatch dwm
    cd dwm

    # Activer uniquement le layout FLEXTILE_DELUXE
    sed -i 's|.*#define FLEXTILE_DELUXE_LAYOUT.*|#define FLEXTILE_DELUXE_LAYOUT 1|' config.def.h
    sed -i 's|.*#define VANITYGAPS_PATCH.*|// #define VANITYGAPS_PATCH|' config.def.h

    make && make install

    echo 'exec dwm' > /home/$USERNAME/.xinitrc
    chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc
fi

if contains "multimedia"; then
    echo "🎚️ Configuration des touches multimédia..."
    apt install -y xbindkeys xbacklight amixer acpi-support
    cat > /home/$USERNAME/.xbindkeysrc <<EOF
"amixer set Master 5%+"
    XF86AudioRaiseVolume

"amixer set Master 5%-"
    XF86AudioLowerVolume

"xbacklight -inc 10"
    XF86MonBrightnessUp

"xbacklight -dec 10"
    XF86MonBrightnessDown
EOF
    chown $USERNAME:$USERNAME /home/$USERNAME/.xbindkeysrc
fi

# Fin du script
clear
whiptail --title "Terminé" --msgbox "L'installation personnalisée est terminée !" 10 60
exit 0