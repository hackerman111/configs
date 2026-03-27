#!/bin/bash

# ============================================================================
# Скрипт автоматической установки зависимостей для dotfiles
# Система: Arch Linux
# Автор: Создано на основе анализа конфигурационных файлов
# ============================================================================

set -e  # Остановка при ошибке


# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_REPO="https://github.com/hackerman111/configs.git"

# Папка, куда будет скачан репозиторий
DOTFILES_DIR="$HOME/configs"

# Функции для красивого вывода
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Проверка прав суперпользователя
if [ "$EUID" -eq 0 ]; then 
    print_error "Не запускайте этот скрипт от имени root!"
    print_info "Скрипт сам запросит пароль sudo когда потребуется."
    exit 1
fi

# ============================================================================
# 1. ОБНОВЛЕНИЕ СИСТЕМЫ
# ============================================================================

print_section "1. Обновление системы"
print_info "Обновление базы данных пакетов и системы..."
sudo pacman -Syu --noconfirm
print_success "Система обновлена"

# ============================================================================
# 2. УСТАНОВКА БАЗОВЫХ ИНСТРУМЕНТОВ
# ============================================================================

print_section "2. Установка базовых инструментов"

BASIC_TOOLS=(
    base-devel          # Инструменты для сборки
    git                 # Система контроля версий
    curl                # Утилита для загрузки
    wget                # Альтернатива curl
    unzip               # Распаковка архивов
    xdg-utils          # Утилиты XDG
    polkit             # Аутентификация
    man-db             # Справочные страницы
    man-pages          # Дополнительные man-страницы
)

print_info "Установка: ${BASIC_TOOLS[*]}"
sudo pacman -S --needed --noconfirm "${BASIC_TOOLS[@]}"
print_success "Базовые инструменты установлены"

# ============================================================================
# 3. УСТАНОВКА HYPRLAND И WAYLAND
# ============================================================================

print_section "3. Установка Hyprland и компонентов Wayland"

HYPRLAND_PACKAGES=(
    hyprland           # Оконный менеджер
    hyprpaper          # Обои для Hyprland
    xdg-desktop-portal-hyprland  # Desktop portal
)

print_info "Установка: ${HYPRLAND_PACKAGES[*]}"
sudo pacman -S --needed --noconfirm "${HYPRLAND_PACKAGES[@]}"
print_success "Hyprland установлен"

# ============================================================================
# 4. УСТАНОВКА WAYBAR И УТИЛИТ
# ============================================================================

print_section "4. Установка Waybar и системных утилит"

WAYBAR_PACKAGES=(
    waybar             # Статус-бар
    wofi               # Меню приложений
    rofi-wayland       # Альтернативное меню
    dunst              # Уведомления (опционально)
    brightnessctl      # Управление яркостью
    playerctl          # Управление медиаплеером
    pamixer            # Управление звуком (альтернатива)
    pavucontrol        # GUI для звука
    networkmanager     # Управление сетью
    network-manager-applet  # Апплет NetworkManager
    bluez              # Bluetooth стек
    bluez-utils        # Утилиты Bluetooth
    lm_sensors         # Датчики температуры
    upower             # Управление питанием
    pacman-contrib     # checkupdates
)

print_info "Установка: ${WAYBAR_PACKAGES[*]}"
sudo pacman -S --needed --noconfirm "${WAYBAR_PACKAGES[@]}"
print_success "Waybar и утилиты установлены"

# Включение Bluetooth
print_info "Включение Bluetooth..."
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# ============================================================================
# 6. УСТАНОВКА ТЕРМИНАЛОВ И ШЕЛЛА
# ============================================================================

print_section "6. Установка терминалов и оболочки"

TERMINAL_PACKAGES=(
    kitty              # Основной терминал
    alacritty          # Альтернативный терминал
    tmux               # Мультиплексор терминала
    zsh                # Z Shell
    zsh-completions    # Дополнения для Zsh
)

print_info "Установка: ${TERMINAL_PACKAGES[*]}"
sudo pacman -S --needed --noconfirm "${TERMINAL_PACKAGES[@]}"
print_success "Терминалы установлены"

# Установка Zsh как оболочки по умолчанию
print_info "Установка Zsh как оболочки по умолчанию..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    print_success "Zsh установлен как оболочка по умолчанию"
else
    print_info "Zsh уже является оболочкой по умолчанию"
fi

# ============================================================================
# 7. УСТАНОВКА NERD FONTS
# ============================================================================

print_section "7. Установка Nerd Fonts"

FONT_PACKAGES=(
    ttf-jetbrains-mono-nerd  # JetBrains Mono Nerd Font
    ttf-meslo-nerd           # Meslo Nerd Font
    ttf-firacode-nerd        # Fira Code Nerd Font (опционально)
    noto-fonts              # Поддержка Unicode
    noto-fonts-emoji        # Emoji
    ttf-liberation          # Liberation fonts
    ttf-dejavu              # DejaVu fonts
)

print_info "Установка: ${FONT_PACKAGES[*]}"
sudo pacman -S --needed --noconfirm "${FONT_PACKAGES[@]}"
print_success "Шрифты установлены"

# ============================================================================
# 8. УСТАНОВКА УТИЛИТ КОМАНДНОЙ СТРОКИ
# ============================================================================

print_section "8. Установка утилит командной строки"

CLI_TOOLS=(
    fzf                # Fuzzy finder
    ripgrep            # Быстрый grep
    fd                 # Быстрый find
    bat                # Cat с подсветкой
    eza                # Современный ls
    zoxide             # Умный cd
    starship           # Промпт
    lazygit            # TUI для Git
    thefuck            # Исправление команд
    tree               # Дерево каталогов
    htop               # Монитор процессов
    ncdu               # Анализатор дисков
    tldr               # Упрощенные man-страницы
    yazi 
    ffmpeg 
    7zip 
    jq 
    poppler 
    fd 
    ripgrep 
    fzf 
    zoxide 
    resvg 
    stow
    just 
    git-delta
    yq
)

print_info "Установка: ${CLI_TOOLS[*]}"
sudo pacman -S --needed --noconfirm "${CLI_TOOLS[@]}"
print_success "Утилиты командной строки установлены"

# ============================================================================
# 9. УСТАНОВКА NEOVIM И ЗАВИСИМОСТЕЙ
# ============================================================================

print_section "9. Установка Neovim и зависимостей"

NEOVIM_PACKAGES=(
    neovim             # Редактор
    python             # Python 3
    python-pip         # pip для Python
    nodejs             # Node.js для LSP
    npm                # npm для Node.js
    lua                # Lua
    luarocks           # Менеджер пакетов Lua
    tree-sitter        # Parser generator
    sqlite             # База данных
    xclip              # Буфер обмена X11
    wl-clipboard       # Буфер обмена Wayland
    gcc                # Компилятор C
    clang              # Компилятор C/C++
    make               # Build tool
    cmake              # Build system
    ninja              # Build system
)

print_info "Установка: ${NEOVIM_PACKAGES[*]}"
sudo pacman -S --needed --noconfirm "${NEOVIM_PACKAGES[@]}"
print_success "Neovim и зависимости установлены"

# Установка Python пакетов
print_info "Установка Python пакетов..."
#pip install --user --upgrade pip
#pip install --user pynvim black isort ruff pyright --break-system-packages
#print_success "Python пакеты установлены"

# ============================================================================
# 10. УСТАНОВКА LATEX
# ============================================================================

print_section "10. Установка LaTeX"

LATEX_PACKAGES=(
    texlive-basic      # Базовый TeX Live
    texlive-latex      # LaTeX
    texlive-latexextra # Дополнительные пакеты
    texlive-fontsextra # Дополнительные шрифты
    texlive-mathscience # Математика
    texlive-luatex     # LuaTeX
    texlive-xetex      # XeTeX
    texlive-binextra
    biber              # Библиографии
    zathura            # PDF viewer
    zathura-pdf-mupdf  # PDF плагин для Zathura
    zathura-djvu  # PDF плагин для Zathura
    zathura-pdf-poppler
    zathura-ps
    zathura-cb
    inkscape           # Векторная графика (для inkscape-figures)
)

print_info "Начинается установка LaTeX (может занять время, ~2GB)..."
print_info "Установка: ${LATEX_PACKAGES[*]}"
sudo pacman -S --needed --noconfirm "${LATEX_PACKAGES[@]}"
print_success "LaTeX установлен"

# ============================================================================
# 11. УСТАНОВКА ДОПОЛНИТЕЛЬНЫХ ПРИЛОЖЕНИЙ
# ============================================================================

print_section "11. Установка дополнительных приложений"

EXTRA_APPS=(
    firefox            # Браузер
    dolphin            # Файловый менеджер
    ark                # Архиватор
    gwenview           # Просмотр изображений
    mpv                # Видеоплеер
    imv                # Просмотр изображений (легковесный)
)

print_info "Установка: ${EXTRA_APPS[*]}"
sudo pacman -S --needed --noconfirm "${EXTRA_APPS[@]}"
print_success "Дополнительные приложения установлены"

# ============================================================================
# 11.1 УСТАНОВКА ВСЕХ ПАКЕТОВ ИЗ pkglist-repo.txt
# ============================================================================

print_section "11.1 Установка пакетов из pkglist-repo.txt"

PKGLIST_REPO=(
    7zip
    accessibility-inspector
    akonadi-calendar-tools
    akonadi-import-wizard
    akonadiconsole
    akregator
    alacritty
    alligator
    angelfish
    arianna
    ark
    artikulate
    asciinema
    audex
    audiocd-kio
    audiotube
    aurorae
    baobab
    base
    base-devel
    bat
    biber
    bind
    blinken
    bluedevil
    blueman
    bluetui
    bluez
    bluez-utils
    bomber
    bovo
    breeze
    breeze-gtk
    breeze-plymouth
    brightnessctl
    calibre
    calligra
    cantor
    clang
    cmake
    colord-kde
    decibels
    discover
    docker
    docker-buildx
    docker-compose
    dolphin
    dolphin-plugins
    dragon
    drkonqi
    dunst
    easy-rsa
    efibootmgr
    elisa
    epiphany
    espeak-ng
    exo
    eza
    falkon
    fd
    ffmpegthumbs
    filelight
    firefox
    flatpak-kcm
    francis
    fzf
    garcon
    gdm
    ghostwriter
    git
    gnome-backgrounds
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-color-manager
    gnome-connections
    gnome-console
    gnome-contacts
    gnome-control-center
    gnome-disk-utility
    gnome-font-viewer
    gnome-keyring
    gnome-logs
    gnome-maps
    gnome-menus
    gnome-music
    gnome-remote-desktop
    gnome-session
    gnome-settings-daemon
    gnome-shell
    gnome-software
    gnome-system-monitor
    gnome-text-editor
    gnome-tour
    gnome-user-docs
    gnome-user-share
    gnome-weather
    granatier
    grantlee-editor
    grilo-plugins
    grub
    gvfs
    gvfs-afc
    gvfs-dnssd
    gvfs-goa
    gvfs-google
    gvfs-gphoto2
    gvfs-mtp
    gvfs-nfs
    gvfs-onedrive
    gvfs-smb
    gvfs-wsdd
    gwenview
    htop
    hyprland
    hyprlock
    hyprpaper
    hyprshot
    imv
    inkscape
    intel-ucode
    ipset
    isoimagewriter
    itinerary
    jq
    juk
    k3b
    kactivitymanagerd
    kaddressbook
    kajongg
    kalarm
    kalgebra
    kalk
    kalm
    kalzium
    kamera
    kamoso
    kanagram
    kapman
    kapptemplate
    kasts
    kate
    katomic
    kbackup
    kblackbox
    kblocks
    kbounce
    kbreakout
    kbruch
    kcachegrind
    kcalc
    kcharselect
    kclock
    kcolorchooser
    kcron
    kde-cli-tools
    kde-dev-scripts
    kde-dev-utils
    kde-gtk-config
    kde-inotify-survey
    kdebugsettings
    kdeconnect
    kdecoration
    kdegraphics-thumbnailers
    kdenetwork-filesharing
    kdenlive
    kdepim-addons
    kdeplasma-addons
    kdesdk-kio
    kdesdk-thumbnailers
    kdevelop
    kdevelop-php
    kdevelop-python
    kdf
    kdialog
    kdiamond
    keditbookmarks
    keysmith
    kfind
    kfourinline
    kgamma
    kgeography
    kget
    kglobalacceld
    kgoldrunner
    kgpg
    kgraphviewer
    khangman
    khelpcenter
    kig
    kigo
    killbots
    kimagemapeditor
    kinfocenter
    kio-admin
    kio-gdrive
    kio-zeroconf
    kirigami-gallery
    kiriki
    kiten
    kitty
    kjournald
    kjumpingcube
    kleopatra
    klettres
    klickety
    klines
    kmag
    kmahjongg
    kmail
    kmail-account-wizard
    kmenuedit
    kmines
    kmix
    kmousetool
    kmouth
    kmplot
    knavalbattle
    knetwalk
    knights
    knighttime
    koko
    kolf
    kollision
    kolourpaint
    kompare
    kongress
    konqueror
    konquest
    konsole
    kontact
    kontrast
    konversation
    korganizer
    kpat
    kpipewire
    krdc
    krdp
    krecorder
    kreversi
    krfb
    kruler
    kscreen
    kscreenlocker
    kshisen
    ksirk
    ksnakeduel
    kspaceduel
    ksquares
    ksshaskpass
    ksudoku
    ksystemlog
    ksystemstats
    kteatime
    ktimer
    ktorrent
    ktouch
    ktrip
    ktuberling
    kturtle
    kubrick
    kwallet-pam
    kwalletmanager
    kwave
    kwayland
    kweather
    kwin
    kwin-x11
    kwordquiz
    kwrited
    layer-shell-qt
    lazygit
    libkscreen
    libksysguard
    libnetfilter_queue
    libplasma
    lightdm
    lightdm-gtk-greeter
    linux
    linux-firmware
    linux-headers
    lokalize
    loupe
    lskat
    luarocks
    malcontent
    man-pages
    marble
    markdownpart
    massif-visualizer
    mbox-importer
    merkuro
    milou
    minuet
    mousepad
    mpv
    nano
    nautilus
    ncdu
    neochat
    neovim
    network-manager-applet
    networkmanager
    networkmanager-openvpn
    nftables
    ninja
    nodejs
    noto-fonts
    npm
    ntfs-3g
    ntp
    nvidia-open-dkms
    nvidia-settings
    nvidia-utils
    nyxt
    obsidian
    ocean-sound-theme
    okular
    openbsd-netcat
    openvpn
    orca
    os-prober
    oxygen
    oxygen-sounds
    pacman-contrib
    palapeli
    pamixer
    papers
    parley
    parole
    partitionmanager
    pavucontrol
    pdftk
    picmi
    pim-data-exporter
    pim-sieve-editor
    plasma-activities-stats
    plasma-browser-integration
    plasma-desktop
    plasma-disks
    plasma-firewall
    plasma-integration
    plasma-nm
    plasma-pa
    plasma-sdk
    plasma-systemmonitor
    plasma-thunderbolt
    plasma-vault
    plasma-welcome
    plasma-workspace
    plasma-workspace-wallpapers
    plasma5support
    plasmatube
    playerctl
    plymouth-kcm
    polkit-kde-agent
    powerdevil
    poxml
    print-manager
    pulseaudio
    pulseaudio-bluetooth
    python-pip
    qpdf
    qqc2-breeze-style
    qrca
    resvg
    ripgrep
    ristretto
    rocs
    rofi
    rygel
    sagemath
    sddm-kcm
    showtime
    simple-scan
    skanlite
    skanpage
    skladnik
    snapshot
    spectacle
    starship
    step
    stow
    sushi
    svgpart
    sweeper
    systemsettings
    tecla
    telegram-desktop
    telly-skout
    texlive-basic
    texlive-bibtexextra
    texlive-binextra
    texlive-fontsextra
    texlive-langcyrillic
    texlive-latex
    texlive-latexextra
    texlive-luatex
    texlive-mathscience
    texlive-xetex
    thefuck
    thunar
    thunar-archive-plugin
    thunar-media-tags-plugin
    thunar-volman
    tldr
    tmux
    tokodon
    tree
    tree-sitter
    tree-sitter-cli
    ttf-dejavu
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    ttf-liberation
    ttf-meslo-nerd
    tumbler
    umbrello
    vim
    vim-spell-ru
    wacomtablet
    waybar
    wget
    wireless_tools
    wl-clipboard
    wofi
    xclip
    xdg-desktop-portal-gnome
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-kde
    xdg-user-dirs-gtk
    xf86-video-vesa
    xfburn
    xfce4-appfinder
    xfce4-artwork
    xfce4-battery-plugin
    xfce4-clipman-plugin
    xfce4-cpufreq-plugin
    xfce4-cpugraph-plugin
    xfce4-dict
    xfce4-diskperf-plugin
    xfce4-eyes-plugin
    xfce4-fsguard-plugin
    xfce4-genmon-plugin
    xfce4-mailwatch-plugin
    xfce4-mount-plugin
    xfce4-mpc-plugin
    xfce4-netload-plugin
    xfce4-notes-plugin
    xfce4-notifyd
    xfce4-panel
    xfce4-places-plugin
    xfce4-power-manager
    xfce4-pulseaudio-plugin
    xfce4-screensaver
    xfce4-screenshooter
    xfce4-sensors-plugin
    xfce4-session
    xfce4-settings
    xfce4-smartbookmark-plugin
    xfce4-systemload-plugin
    xfce4-taskmanager
    xfce4-terminal
    xfce4-time-out-plugin
    xfce4-timer-plugin
    xfce4-verve-plugin
    xfce4-wavelan-plugin
    xfce4-weather-plugin
    xfce4-whiskermenu-plugin
    xfce4-xkb-plugin
    xfconf
    xfdesktop
    xfwm4
    xfwm4-themes
    xorg-bdftopcf
    xorg-docs
    xorg-font-util
    xorg-fonts-100dpi
    xorg-fonts-75dpi
    xorg-fonts-encodings
    xorg-iceauth
    xorg-mkfontscale
    xorg-server
    xorg-server-common
    xorg-server-devel
    xorg-server-src
    xorg-server-xephyr
    xorg-server-xnest
    xorg-server-xvfb
    xorg-sessreg
    xorg-setxkbmap
    xorg-smproxy
    xorg-x11perf
    xorg-xauth
    xorg-xbacklight
    xorg-xcmsdb
    xorg-xcursorgen
    xorg-xdpyinfo
    xorg-xdriinfo
    xorg-xev
    xorg-xgamma
    xorg-xhost
    xorg-xinput
    xorg-xkbcomp
    xorg-xkbevd
    xorg-xkbutils
    xorg-xkill
    xorg-xlsatoms
    xorg-xlsclients
    xorg-xmodmap
    xorg-xpr
    xorg-xrandr
    xorg-xrdb
    xorg-xrefresh
    xorg-xset
    xorg-xsetroot
    xorg-xvinfo
    xorg-xwayland
    xorg-xwd
    xorg-xwininfo
    xorg-xwud
    yakuake
    yazi
    yelp
    zanshin
    zathura
    zathura-pdf-mupdf
    zoxide
    zsh
    zsh-completions
)

print_info "Установка всех пакетов из pkglist-repo.txt (${#PKGLIST_REPO[@]} пакетов)..."
sudo pacman -S --needed --noconfirm "${PKGLIST_REPO[@]}"
print_success "Все пакеты из pkglist-repo.txt установлены"

# ============================================================================
# 12. УСТАНОВКА AUR HELPER (YAY)
# ============================================================================

print_section "12. Установка AUR Helper (yay)"

if ! command -v yay &> /dev/null; then
    print_info "Установка yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
    print_success "yay установлен"
else
    print_info "yay уже установлен"
fi

# ============================================================================
# 13. УСТАНОВКА AUR ПАКЕТОВ
# ============================================================================

print_section "13. Установка пакетов из AUR"

AUR_PACKAGES=(
    hyprshot           # Скриншоты для Hyprland
    warpd              # Управление курсором с клавиатуры
    bluetui            # Bluetooth TUI
    tmuxifier          # Tmux layout manager
    wordnet-cli        # Словарь (для Neovim blink-cmp)
    obsidian
    xkb-switch         # Переключатель раскладки (полезно для Neovim)
    neofetch
    # Все пакеты из pkglist-aur.txt
    agg
    antigravity
    djvu2pdf
    google-chrome
    grub-customizer
    jdownloader2
    latex-mk
    neofetch-git
    visual-studio-code-bin
    yandex-browser
    yay-bin
    yay-bin-debug
    zotero-git
)

print_info "Установка из AUR: ${AUR_PACKAGES[*]}"
for package in "${AUR_PACKAGES[@]}"; do
    if yay -Q "$package" &> /dev/null; then
        print_info "$package уже установлен"
    else
        print_info "Установка $package..."
        yay -S --noconfirm "$package"
    fi
done
print_success "AUR пакеты установлены"

# Опциональные AUR пакеты
print_info "Опциональные пакеты:"
echo "  - yandex-browser (браузер)"
echo "  - telegram-desktop-bin (мессенджер)"
echo "  - flatpak (для дополнительных приложений)"

read -p "Установить опциональные пакеты? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    OPTIONAL_AUR=(
        telegram-desktop-bin
        flatpak
    )
    for package in "${OPTIONAL_AUR[@]}"; do
        yay -S --noconfirm "$package"
    done
    print_success "Опциональные пакеты установлены"
fi

# ============================================================================
# 14. НАСТРОЙКА ДОПОЛНИТЕЛЬНЫХ КОМПОНЕНТОВ
# ============================================================================

print_section "14. Настройка дополнительных компонентов"

# Установка TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    print_info "Установка TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    print_success "TPM установлен"
else
    print_info "TPM уже установлен"
fi

# Установка Zinit для Zsh
if [ ! -d "${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git" ]; then
    print_info "Установка Zinit..."
    mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
    git clone https://github.com/zdharma-continuum/zinit.git \
        "${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    print_success "Zinit установлен"
else
    print_info "Zinit уже установлен"
fi

# Установка tmuxifier
if [ ! -d "$HOME/.tmuxifier" ]; then
    print_info "Установка tmuxifier..."
    git clone https://github.com/jimeh/tmuxifier.git "$HOME/.tmuxifier"
    print_success "tmuxifier установлен"
else
    print_info "tmuxifier уже установлен"
fi


# ============================================================================
# 15. НАСТРОЙКА LSP И ФОРМАТТЕРОВ ДЛЯ NEOVIM
# ============================================================================

print_section "15. Установка LSP серверов и форматтеров"

# Эти пакеты будут установлены через Mason в Neovim при первом запуске
# Но мы можем установить некоторые системно для надежности

LSP_FORMATTERS=(
    lua-language-server  # Lua LSP
    stylua               # Lua formatter
    clang                # Предоставляет clangd и clang-format
    prettier             # Форматтер для многих языков
)

print_info "Установка: ${LSP_FORMATTERS[*]}"
sudo pacman -S --needed --noconfirm "${LSP_FORMATTERS[@]}"
print_success "LSP серверы и форматтеры установлены"

print_info "Дополнительные LSP серверы будут установлены через Mason при первом запуске Neovim"

# ============================================================================
# 3. НАСТРОЙКА DOTFILES (STOW)
# ============================================================================

print_section "16. Перенос конфигурации (Stow)"

print_info "Используется репозиторий: $DOTFILES_REPO"

# Клонирование или обновление репозитория
if [ ! -d "$DOTFILES_DIR" ]; then
    print_info "Клонирование репозитория..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    print_info "Обновление репозитория..."
    cd "$DOTFILES_DIR" && git pull
fi

# Применение конфигов через Stow
if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR"
    print_info "Применение конфигурации..."
    
    # Используем stow для всех папок в репозитории (эквивалент stow */)
    # --restow перезаписывает симлинки, если они изменились
    # Игнорируем .git
    stow --restow --target="$HOME" --ignore=".git" */
    
    print_success "Конфигурация применена!"
fi


# ============================================================================
# 16. ФИНАЛЬНЫЕ НАСТРОЙКИ
# ============================================================================

print_section "17. Финальные настройки"

# Обновление базы данных шрифтов
print_info "Обновление кэша шрифтов..."
fc-cache -fv > /dev/null 2>&1
print_success "Кэш шрифтов обновлен"

# Включение необходимых служб
print_info "Включение системных служб..."
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service

# Создание символических ссылок (если нужно)
print_info "Проверка символических ссылок..."
# Здесь можно добавить создание симлинков на конфиги

# ============================================================================
# ИТОГОВАЯ ИНФОРМАЦИЯ
# ============================================================================

print_section "✓ УСТАНОВКА ЗАВЕРШЕНА"

echo -e "${GREEN}Все зависимости успешно установлены!${NC}\n"

echo -e "${YELLOW}Следующие шаги:${NC}"
echo "1. Перезапустите систему или выйдите/войдите для применения изменений"
echo "2. Скопируйте конфигурационные файлы в ~/.config/"
echo "3. При первом запуске Neovim выполните :Lazy sync для установки плагинов"
echo "4. В Tmux нажмите <prefix> + I для установки плагинов (Ctrl+Space + I)"
echo "5. Запустите 'hyprctl reload' после копирования конфига Hyprland"

echo -e "\n${YELLOW}Дополнительная информация:${NC}"
echo "- Конфигурация Neovim: ~/.config/nvim/"
echo "- Конфигурация Hyprland: ~/.config/hypr/"
echo "- Конфигурация Waybar: ~/.config/waybar/"
echo "- Конфигурация Tmux: ~/.tmux.conf"
echo "- Конфигурация Zsh: ~/.zshrc"

echo -e "\n${BLUE}Полезные команды:${NC}"
echo "- Обновить систему: yay -Syu"
echo "- Проверить зависимости Neovim: nvim --version и :checkhealth"
echo "- Перезагрузить Waybar: killall waybar && waybar &"
echo "- Документация Hyprland: man hyprland"

echo -e "\n${GREEN}Установка завершена успешно! 🎉${NC}\n"

# Опционально: показать статистику
print_info "Статистика установки:"
echo "- Установлено пакетов из официальных репозиториев: ~$(pacman -Q | wc -l)"
echo "- Использовано дискового пространства: ~$(du -sh ~/.local/share ~/.cache 2>/dev/null | awk '{sum+=$1} END {print sum}') MB"

exit 0
