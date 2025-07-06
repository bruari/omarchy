#!/bin/bash

# Master installation script - combines all individual install scripts

# 1-yay.sh
sudo pacman -S --needed --noconfirm base-devel

if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd ~
  rm -rf yay-bin
fi

# 2-identification.sh
# Need gum to query for input
# yay -S --noconfirm --needed gum

# Configure identification
#echo -e "\nEnter identification for git and autocomplete..."
#export OMARCHY_USER_NAME=$(gum input --placeholder "Enter full name" --prompt "Name> ")
#export OMARCHY_USER_EMAIL=$(gum input --placeholder "Enter email address" --prompt "Email> ")

# 3-terminal.sh
yay -S --noconfirm --needed \
  wget \
  curl \
  unzip \
  inetutils \
  fd \
  eza \
  fzf \
  ripgrep \
  zoxide \
  bat \
  wl-clipboard \
  fastfetch \
  btop \
  man \
  tldr \
  vim \
  less \
  whois \
  plocate \
  alacritty

# 4-config.sh
# Copy over Omarchy configs
cp -R ~/.local/share/omarchy/config/* ~/.config/

# Ensure application directory exists for update-desktop-database
mkdir -p ~/.local/share/applications

# Shell configuration removed - installation is now shell-agnostic

# Login directly as user, rely on disk encryption + hyprlock for security
#sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
#sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<'EOF'
#[Service]
#ExecStart=
#ExecStart=-/usr/bin/agetty --autologin $USER --login-program /usr/bin/bash --login-options "-c hyprland"
#Environment="XDG_SESSION_TYPE=wayland"
#Type=idle
#EOF

# Set common git aliases
#git config --global alias.co checkout
#git config --global alias.br branch
#git config --global alias.ci commit
#git config --global alias.st status
#git config --global pull.rebase true
#git config --global init.defaultBranch master

# Set identification from install inputs
#if [[ -n "${OMARCHY_USER_NAME//[[:space:]]/}" ]]; then
#  git config --global user.name "$OMARCHY_USER_NAME"
#fi

#if [[ -n "${OMARCHY_USER_EMAIL//[[:space:]]/}" ]]; then
#  git config --global user.email "$OMARCHY_USER_EMAIL"
#fi

# Set default XCompose that is triggered with CapsLock
#tee ~/.XCompose >/dev/null <<EOF
#include "%H/.local/share/omarchy/default/xcompose"

# Identification
#<Multi_key> <space> <n> : "$OMARCHY_USER_NAME"
#<Multi_key> <space> <e> : "$OMARCHY_USER_EMAIL"
#EOF

# asdcontrol.sh
# Install asdcontrol for controlling brightness on Apple Displays
if ! command -v asdcontrol &>/dev/null; then
  git clone https://github.com/nikosdion/asdcontrol.git /tmp/asdcontrol
  cd /tmp/asdcontrol
  make
  sudo make install
  cd -
  rm -rf /tmp/asdcontrol

  # Setup sudo-less controls
  echo "$USER ALL=(ALL) NOPASSWD: /usr/local/bin/asdcontrol" | sudo tee /etc/sudoers.d/asdcontrol
  sudo chmod 440 /etc/sudoers.d/asdcontrol
fi

# backgrounds.sh
BACKGROUNDS_DIR=~/.config/omarchy/backgrounds/

download_background_image() {
  local url="$1"
  local path="$2"
  gum spin --title "Downloading $url as $path..." -- curl -sL -o "$BACKGROUNDS_DIR/$path" "$url"
}

for t in ~/.local/share/omarchy/themes/*; do source "$t/backgrounds.sh"; done

# bluetooth.sh
# Install bluetooth controls
yay -S --noconfirm --needed blueberry

# Turn on bluetooth by default
sudo systemctl enable --now bluetooth.service

# desktop.sh
yay -S --noconfirm --needed \
  brightnessctl \
  playerctl \
  pamixer \
  pavucontrol \
  wireplumber \
  fcitx5 \
  fcitx5-gtk \
  fcitx5-qt \
  fcitx5-configtool \
  wl-clip-persist \
  clipse-bin \
  nautilus \
  sushi \
  ffmpegthumbnailer \
  gnome-calculator \
  \
  chromium \
  mpv \
  evince \
  imv \
  localsend-bin
# 1password-beta # 1password-cli \

# development.sh
yay -S --noconfirm --needed \
  cargo \
  clang \
  llvm \
  mise \
  imagemagick \
  mariadb-libs \
  postgresql-libs \
  github-cli \
  lazygit \
  lazydocker-bin

# docker.sh
yay -S --noconfirm --needed \
  docker \
  docker-compose

# Limit log size to avoid running out of disk
sudo mkdir -p /etc/docker
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

# Start Docker automatically
sudo systemctl enable docker

# Give this user privileged Docker access
sudo usermod -aG docker ${USER}

# fonts.sh
yay -Sy --noconfirm --needed \
  ttf-font-awesome \
  noto-fonts \
  noto-fonts-emoji \
  noto-fonts-cjk \
  noto-fonts-extra

mkdir -p ~/.local/share/fonts

if ! fc-list | grep -qi "CaskaydiaMono Nerd Font"; then
  cd /tmp
  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip
  unzip CascadiaMono.zip -d CascadiaFont
  cp CascadiaFont/CaskaydiaMonoNerdFont-Regular.ttf ~/.local/share/fonts
  cp CascadiaFont/CaskaydiaMonoNerdFont-Bold.ttf ~/.local/share/fonts
  cp CascadiaFont/CaskaydiaMonoNerdFont-Italic.ttf ~/.local/share/fonts
  cp CascadiaFont/CaskaydiaMonoNerdFont-BoldItalic.ttf ~/.local/share/fonts
  rm -rf CascadiaMono.zip CascadiaFont
  fc-cache
  cd -
fi

if ! fc-list | grep -qi "iA Writer Mono S"; then
  cd /tmp
  wget -O iafonts.zip https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip
  unzip iafonts.zip -d iaFonts
  cp iaFonts/iA-Fonts-master/iA\ Writer\ Mono/Static/iAWriterMonoS-*.ttf ~/.local/share/fonts
  rm -rf iafonts.zip iaFonts
  fc-cache
  cd -
fi

# hyprlandia.sh
yay -S --noconfirm --needed \
  hyprland \
  hyprshot \
  hyprpicker \
  hyprlock \
  hypridle \
  hyprpolkitagent \
  hyprland-qtutils \
  wofi \
  waybar \
  mako \
  swaybg \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk

# Start Hyprland automatically (shell-agnostic via .profile)
# Create .profile that works with any POSIX shell
#tee ~/.profile >/dev/null <<'EOF'
# Auto-start Hyprland on TTY1
#if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
#    exec Hyprland
#fi
#EOF

# mimetypes.sh
update-desktop-database ~/.local/share/applications

# Open all images with imv
xdg-mime default imv.desktop image/png
xdg-mime default imv.desktop image/jpeg
xdg-mime default imv.desktop image/gif
xdg-mime default imv.desktop image/webp
xdg-mime default imv.desktop image/bmp
xdg-mime default imv.desktop image/tiff

# Open PDFs with the Document Viewer
xdg-mime default org.gnome.Evince.desktop application/pdf

# Use Chromium as the default browser
xdg-settings set default-web-browser chromium.desktop
xdg-mime default chromium.desktop x-scheme-handler/http
xdg-mime default chromium.desktop x-scheme-handler/https

# Open video files with mpv
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/x-flv
xdg-mime default mpv.desktop video/x-ms-wmv
xdg-mime default mpv.desktop video/mpeg
xdg-mime default mpv.desktop video/ogg
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/quicktime
xdg-mime default mpv.desktop video/3gpp
xdg-mime default mpv.desktop video/3gpp2
xdg-mime default mpv.desktop video/x-ms-asf
xdg-mime default mpv.desktop video/x-ogm+ogg
xdg-mime default mpv.desktop video/x-theora+ogg
xdg-mime default mpv.desktop application/ogg

# nvidia.sh
# ==============================================================================
# Hyprland NVIDIA Setup Script for Arch Linux
# ==============================================================================
# This script automates the installation and configuration of NVIDIA drivers
# for use with Hyprland on Arch Linux, following the official Hyprland wiki.
#
# Author: https://github.com/Kn0ax
#
# ==============================================================================

# --- GPU Detection ---
#if [ -n "$(lspci | grep -i 'nvidia')" ]; then
# --- Driver Selection ---
# Turing (16xx, 20xx), Ampere (30xx), Ada (40xx), and newer recommend the open-source kernel modules
#  if echo "$gpu_info" | grep -q -E "RTX [2-9][0-9]|GTX 16"; then
#    NVIDIA_DRIVER_PACKAGE="nvidia-open-dkms"
#  else
#    NVIDIA_DRIVER_PACKAGE="nvidia-dkms"
#  fi

# Check which kernel is installed and set appropriate headers package
#  KERNEL_HEADERS="linux-headers" # Default
#  if pacman -Q linux-zen &>/dev/null; then
#    KERNEL_HEADERS="linux-zen-headers"
#  elif pacman -Q linux-lts &>/dev/null; then
#    KERNEL_HEADERS="linux-lts-headers"
#  elif pacman -Q linux-hardened &>/dev/null; then
#    KERNEL_HEADERS="linux-hardened-headers"
#  fi

# Enable multilib repository for 32-bit libraries
#  if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
#    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
#  fi

# Install packages
#  PACKAGES_TO_INSTALL=(
#    "${KERNEL_HEADERS}"
#    "${NVIDIA_DRIVER_PACKAGE}"
#    "nvidia-utils"
#    "lib32-nvidia-utils"
#    "egl-wayland"
#    "libva-nvidia-driver" # For VA-API hardware acceleration
#    "qt5-wayland"
#    "qt6-wayland"
#  )

#  yay -Syu --needed --noconfirm "${PACKAGES_TO_INSTALL[@]}"

# Configure modprobe for early KMS
#  echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null

# Configure mkinitcpio for early loading
# MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# Define modules
#  NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

# Create backup
#  sudo cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.backup"

# Remove any old nvidia modules to prevent duplicates
#  sudo sed -i -E 's/ nvidia_drm//g; s/ nvidia_uvm//g; s/ nvidia_modeset//g; s/ nvidia//g;' "$MKINITCPIO_CONF"
# Add the new modules at the start of the MODULES array
#  sudo sed -i -E "s/^(MODULES=\\()/\\1${NVIDIA_MODULES} /" "$MKINITCPIO_CONF"
# Clean up potential double spaces
#  sudo sed -i -E 's/  +/ /g' "$MKINITCPIO_CONF"

#  sudo mkinitcpio -P

# Add NVIDIA environment variables to hyprland.conf
#  HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
#  if [ -f "$HYPRLAND_CONF" ]; then
#    cat >>"$HYPRLAND_CONF" <<'EOF'

# NVIDIA environment variables
#env = NVD_BACKEND,direct
#env = LIBVA_DRIVER_NAME,nvidia
#env = __GLX_VENDOR_LIBRARY_NAME,nvidia
#EOF
#  fi
#fi

# nvim.sh
if ! command -v nvim &>/dev/null; then
  yay -S --noconfirm --needed \
    nvim \
    luarocks \
    tree-sitter-cli

  # Install LazyVim
  rm -rf ~/.config/nvim
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  cp -R ~/.local/share/omarchy/config/nvim/* ~/.config/nvim/
  rm -rf ~/.config/nvim/.git
  echo "vim.opt.relativenumber = false" >>~/.config/nvim/lua/config/options.lua
fi

# power.sh
# Setting the performance profile can make a big difference. By default, most systems seem to start in balanced mode,
# even if they're not running off a battery. So let's make sure that's changed to performance.
yay -S --noconfirm \
  power-profiles-daemon

if ls /sys/class/power_supply/BAT* &>/dev/null; then
  # This computer runs on a battery
  powerprofilesctl set balanced || true
else
  # This computer runs on power outlet
  powerprofilesctl set performance || true
fi

# printer.sh
#sudo pacman -S --noconfirm \
#  cups \
#  cups-pdf \
#  cups-filters \
#  system-config-printer
#sudo systemctl enable --now cups.service

# ruby.sh
# Install Ruby using gcc-14 for compatibility
#yay -S --noconfirm --needed \
#  gcc14
#mise settings set ruby.ruby_build_opts "CC=gcc-14 CXX=g++-14"

# Trust .ruby-version
#mise settings add idiomatic_version_file_enable_tools ruby

# theme.sh
# Use dark mode for QT apps too (like kdenlive)
sudo pacman -S --noconfirm \
  kvantum-qt5

# Prefer dark mode everything
sudo pacman -S --noconfirm \
  gnome-themes-extra # Adds Adwaita-dark theme
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Setup theme links
mkdir -p ~/.config/omarchy/themes
for f in ~/.local/share/omarchy/themes/*; do ln -s "$f" ~/.config/omarchy/themes/; done

# Set initial theme
mkdir -p ~/.config/omarchy/current
ln -snf ~/.config/omarchy/themes/tokyo-night ~/.config/omarchy/current/theme
source ~/.local/share/omarchy/themes/tokyo-night/backgrounds.sh
ln -snf ~/.config/omarchy/backgrounds/tokyo-night ~/.config/omarchy/current/backgrounds
ln -snf ~/.config/omarchy/current/backgrounds/1-Pawel-Czerwinski-Abstract-Purple-Blue.jpg ~/.config/omarchy/current/background

# Set specific app links for current theme
ln -snf ~/.config/omarchy/current/theme/hyprlock.conf ~/.config/hypr/hyprlock.conf
ln -snf ~/.config/omarchy/current/theme/wofi.css ~/.config/wofi/style.css
ln -snf ~/.config/omarchy/current/theme/neovim.lua ~/.config/nvim/lua/plugins/theme.lua
mkdir -p ~/.config/btop/themes
ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme
mkdir -p ~/.config/mako
ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config

# webapps.sh
#source ~/.local/share/omarchy/default/bash/functions
#web2app "WhatsApp" https://web.whatsapp.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/whatsapp.png
#web2app "Google Photos" https://photos.google.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-photos.png
#web2app "Google Contacts" https://contacts.google.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-contacts.png
#web2app "Google Messages" https://messages.google.com/web/conversations https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-messages.png
#web2app "ChatGPT" https://chatgpt.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png
#web2app "YouTube" https://youtube.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png
#web2app "GitHub" https://github.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-light.png
#web2app "X" https://x.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/x-light.png

# xtras.sh
#yay -S --noconfirm --needed \
#  signal-desktop \
#  spotify \
#  dropbox-cli \
#  zoom \
#  obsidian-bin \
#  typora \
#  libreoffice \
#  obs-studio \
#  kdenlive \
#  pinta \
#  xournalpp

# motd.sh
# Set up Message of the Day
sudo tee /etc/motd >/dev/null <<'EOF'

 ▄██████▄    ▄▄▄▄███▄▄▄▄      ▄████████    ▄████████  ▄████████    ▄█    █▄    ▄██   ▄  
███    ███ ▄██▀▀▀███▀▀▀██▄   ███    ███   ███    ███ ███    ███   ███    ███   ███   ██▄
███    ███ ███   ███   ███   ███    ███   ███    ███ ███    █▀    ███    ███   ███▄▄▄███
███    ███ ███   ███   ███   ███    ███  ▄███▄▄▄▄██▀ ███         ▄███▄▄▄▄███▄▄ ▀▀▀▀▀▀███
███    ███ ███   ███   ███ ▀███████████ ▀▀███▀▀▀▀▀   ███        ▀▀███▀▀▀▀███▀  ▄██   ███
███    ███ ███   ███   ███   ███    ███ ▀███████████ ███    █▄    ███    ███   ███   ███
███    ███ ███   ███   ███   ███    ███   ███    ███ ███    ███   ███    ███   ███   ███
 ▀██████▀   ▀█   ███   █▀    ███    █▀    ███    ███ ████████▀    ███    █▀     ▀█████▀ 
                                          ███    ███                                    
Welcome to Omarchy!

Get ready to build your own experience. To dive into the graphical environment, run:
$ hyprland

Enjoy the ride!

EOF

# Copy over Omarchy applications
source ~/.local/share/omarchy/bin/omarchy-sync-applications || true
