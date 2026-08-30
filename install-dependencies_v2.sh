#!/bin/bash

# ============================================================================
# Скрипт автоматической установки зависимостей для dotfiles
# Система: Arch Linux
# Композитор: Hyprland + niri, минимальный стек (без KDE Plasma/GNOME/XFCE)
# ============================================================================

set -e # Остановка при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_REPO="https://github.com/hackerman111/configs.git"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"

# Папка, куда будет скачан репозиторий
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/configs}"
CONFIG_BACKUP_DIR=""

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

install_pkg_group() {
    local description="$1"
    local -n pkgs_ref="$2"

    print_info "Установка: ${description} (${#pkgs_ref[@]} пакетов)"
    sudo pacman -S --needed --noconfirm "${pkgs_ref[@]}"
    print_success "${description} установлены"
}

backup_path_if_needed() {
    local target="$1"
    local source="$2"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        return 0
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        CONFIG_BACKUP_DIR="${CONFIG_BACKUP_DIR:-$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)}"
        mkdir -p "$CONFIG_BACKUP_DIR"
        print_warning "Существующий $target перенесен в $CONFIG_BACKUP_DIR"
        mv "$target" "$CONFIG_BACKUP_DIR/$(basename "$target")"
    fi
}

link_config_path() {
    local relative_source="$1"
    local relative_target="$2"
    local source="$DOTFILES_DIR/$relative_source"
    local target="$HOME/$relative_target"

    if [ ! -e "$source" ]; then
        print_warning "Пропускаю $relative_source: нет такого пути в репозитории"
        return 0
    fi

    backup_path_if_needed "$target" "$source"
    mkdir -p "$(dirname "$target")"
    ln -sfn "$source" "$target"
    print_info "$target -> $source"
}

deploy_dotfiles_configs() {
    print_info "Развертывание конфигов из $DOTFILES_DIR"

    link_config_path ".zshrc" ".zshrc"
    link_config_path ".tmux.conf" ".tmux.conf"
    link_config_path ".config/hypr" ".config/hypr"
    link_config_path ".config/kitty" ".config/kitty"
    link_config_path ".config/neofetch" ".config/neofetch"
    link_config_path ".config/waybar" ".config/waybar"
    link_config_path ".config/yazi" ".config/yazi"
    link_config_path "nvim/.config/nvim" ".config/nvim"
    link_config_path "tmux/.config/tmux" ".config/tmux"
    link_config_path "zathura/.config/zathura" ".config/zathura"

    find "$DOTFILES_DIR/.config/waybar/scripts" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
    [ -f "$DOTFILES_DIR/.config/hypr/wall-switcher.sh" ] && chmod +x "$DOTFILES_DIR/.config/hypr/wall-switcher.sh"

    print_success "Конфиги развернуты"
}

run_optional_step() {
    local description="$1"
    shift

    if "$@"; then
        print_success "$description"
    else
        print_warning "$description не выполнено; можно повторить вручную позже"
    fi
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
# 2. BOOTSTRAP-ЗАВИСИМОСТИ (нужны скрипту/системе, не входят в pkglist)
# ============================================================================

print_section "2. Bootstrap-инструменты"

BOOTSTRAP_TOOLS=(
    curl            # Утилита для загрузки
    ca-certificates # TLS для curl/git на чистой системе
    gnupg           # Проверка подписей
    sudo            # Эскалация прав
    unzip           # Распаковка архивов
    xdg-utils       # Утилиты XDG
    polkit          # Аутентификация
    man-db          # Справочные страницы
)

install_pkg_group "Bootstrap-инструменты" BOOTSTRAP_TOOLS

# ============================================================================
# 3. ПАКЕТЫ ИЗ pkglist (распределены по категориям)
#
# Ниже -- финальный, уже вычищенный от дублей набор (KDE Plasma/GNOME/XFCE,
# лишние терминалы/браузеры/VPN-клиенты/PDF- и image-viewer'ы удалены;
# см. историю чистки pkglist-repo.txt / pkglist-aur.txt).
# ============================================================================

print_section "3.1 Базовая система"
PKG_BASE_SYSTEM=(
    base
    base-devel
    git
    man-pages
    rsync
    wget
)
install_pkg_group "Базовая система" PKG_BASE_SYSTEM

print_section "3.2 Ядро, драйверы, Xorg-совместимость"
PKG_KERNEL_HARDWARE=(
    cuda
    efibootmgr
    grub
    guvcview
    intel-ucode
    libratbag
    linux
    linux-firmware
    linux-headers
    memtester
    nvidia-open-dkms
    nvidia-settings
    nvidia-utils
    os-prober
    piper
    wacomtablet
    xf86-video-vesa
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
)
install_pkg_group "Ядро и драйверы" PKG_KERNEL_HARDWARE

print_section "3.3 Hyprland/niri, Wayland-порталы, статус-бар"
PKG_HYPRLAND_WAYLAND=(
    brightnessctl
    hypridle
    hyprland
    hyprlock
    hyprpaper
    hyprpicker
    hyprshot
    niri
    pamixer
    pavucontrol
    pipewire-pulse
    playerctl
    rofi
    waybar
    wl-clipboard
    wofi
    xclip
    xdg-desktop-portal-gnome
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-kde
    xdg-desktop-portal-wlr
    xdg-user-dirs-gtk
)
install_pkg_group "Hyprland/niri и Wayland" PKG_HYPRLAND_WAYLAND

# Дополнительные демоны, нужные скриптам waybar (сенсоры/питание), не входят в pkglist
WAYBAR_RUNTIME_EXTRA=(
    lm_sensors
    upower
)
install_pkg_group "Демоны для waybar (сенсоры/питание)" WAYBAR_RUNTIME_EXTRA

print_section "3.4 Сеть, Bluetooth, VPN-инфраструктура"
PKG_NETWORK_BLUETOOTH_VPN=(
    bind
    blueman
    bluetui
    bluez
    bluez-utils
    dnsmasq
    easy-rsa
    ipcalc
    ipset
    libnetfilter_queue
    network-manager-applet
    networkmanager
    networkmanager-openvpn
    nftables
    openbsd-netcat
    openvpn
    proxychains-ng
    smartdns
    sshpass
    whois
    wireless_tools
)
install_pkg_group "Сеть/Bluetooth/VPN" PKG_NETWORK_BLUETOOTH_VPN

print_info "Включение Bluetooth..."
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

print_section "3.5 Терминал и оболочка"
PKG_TERMINAL_SHELL=(
    dunst
    ghostty
    kitty
    navi
    starship
    tealdeer
    thefuck
    tmux
    zsh
    zsh-completions
)
install_pkg_group "Терминал и shell" PKG_TERMINAL_SHELL

# Установка Zsh как оболочки по умолчанию
print_info "Установка Zsh как оболочки по умолчанию..."
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" "$USER"
    print_success "Zsh установлен как оболочка по умолчанию"
else
    print_info "Zsh уже является оболочкой по умолчанию"
fi

print_section "3.6 Шрифты"
PKG_FONTS=(
    noto-fonts
    ttf-dejavu
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    ttf-liberation
    ttf-meslo-nerd
)
install_pkg_group "Шрифты" PKG_FONTS
sudo pacman -S --needed --noconfirm noto-fonts-emoji # emoji-покрытие, не входит в pkglist

print_section "3.7 Утилиты командной строки"
PKG_CLI_TOOLS=(
    7zip
    android-tools
    archiso
    asciinema
    bat
    bats
    bleachbit
    borg
    cpio
    cups
    docker
    docker-buildx
    docker-compose
    dust
    espeak-ng
    expac
    eza
    fd
    fzf
    gdu
    git-delta
    gitui
    go
    jq
    just
    lazygit
    luarocks
    meson
    nano
    ncdu
    ninja
    ntfs-3g
    ntp
    pacman-contrib
    patchelf
    podman
    python-pip
    python-pipx
    qwen-code
    reflector
    resvg
    ripgrep
    sagemath
    stow
    syncthing
    transmission-cli
    tree
    tumbler
    yazi
    yq
    zoxide
)
install_pkg_group "CLI-утилиты" PKG_CLI_TOOLS
sudo pacman -S --needed --noconfirm ffmpeg # нужен для скриптов конвертации аудио/видео

print_section "3.8 Neovim и инструментарий разработки"
PKG_NEOVIM_DEV=(
    clang
    cmake
    mingw-w64-gcc
    neovim
    nodejs
    npm
    tree-sitter
    tree-sitter-cli
    vim
    vim-spell-ru
)
install_pkg_group "Neovim и dev-тулчейн" PKG_NEOVIM_DEV

# Рантайм-зависимости для сборки плагинов Neovim, не входят в pkglist
# (gcc/make уже приходят транзитивно с base-devel)
NEOVIM_RUNTIME_EXTRA=(
    python
    sqlite
    lua
)
install_pkg_group "Рантайм для Neovim-плагинов" NEOVIM_RUNTIME_EXTRA

print_section "3.9 LaTeX, академический пайплайн, PDF"
PKG_LATEX_ACADEMIC=(
    biber
    inkscape
    pdftk
    python-pymupdf
    python-pytesseract
    qpdf
    tectonic
    tesseract-data-eng
    tesseract-data-rus
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
    zathura
    zathura-djvu
    zathura-pdf-mupdf
)
print_info "Начинается установка LaTeX (может занять время, ~2GB)..."
install_pkg_group "LaTeX/академический пайплайн" PKG_LATEX_ACADEMIC

print_section "3.10 Графика, медиа, офисные приложения"
PKG_GRAPHICS_MEDIA_APPS=(
    calibre
    imv
    isoimagewriter
    k3b
    kdenlive
    mpv
    obs-studio
    obsidian
)
install_pkg_group "Графика/медиа/офис" PKG_GRAPHICS_MEDIA_APPS

print_section "3.11 Автономные KDE-утилиты (без Plasma-сессии)"
PKG_KDE_STANDALONE_UTILS=(
    ark
    breeze
    breeze-gtk
    gnome-keyring
    gsmartcontrol
    gvfs
    gvfs-afc
    gvfs-dnssd
    gvfs-goa
    gvfs-gphoto2
    gvfs-mtp
    gvfs-nfs
    gvfs-onedrive
    gvfs-smb
    gvfs-wsdd
    kdeconnect
    kdiskmark
    keepassxc
    keysmith
    kleopatra
    kwayland
    ocean-sound-theme
    oxygen
    oxygen-sounds
    partitionmanager
    polkit-kde-agent
    qrca
    sddm-kcm
    skanpage
)
install_pkg_group "KDE standalone-утилиты" PKG_KDE_STANDALONE_UTILS

print_section "3.12 Мониторинг (CPU/GPU)"
PKG_MONITORING=(
    btop
    nvtop
)
install_pkg_group "Мониторинг" PKG_MONITORING

print_section "3.13 Мессенджеры"
PKG_MESSENGERS=(
    telegram-desktop
)
install_pkg_group "Мессенджеры" PKG_MESSENGERS

# ============================================================================
# 4. УСТАНОВКА AUR HELPER (YAY)
# ============================================================================

print_section "4. Установка AUR Helper (yay)"

if ! command -v yay &>/dev/null; then
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
# 5. УСТАНОВКА AUR ПАКЕТОВ
# ============================================================================

print_section "5. Установка пакетов из AUR"

AUR_PACKAGES=(
    agg
    aimp
    antigravity
    carapace-bin
    djvu2pdf
    grub-customizer
    hiddify-app-bin
    iprange
    jdownloader2
    latex-mk
    librewolf-bin
    localsend-bin
    logiops
    neofetch-git
    qmd
    sing-box
    ventoy-bin
    visual-studio-code-bin
    xkb-switch
    xray-core
    yay-bin
    bookokrat-bin
    zotero-git

)

print_info "Установка из AUR: ${AUR_PACKAGES[*]}"
FAILED_AUR_PACKAGES=()
for package in "${AUR_PACKAGES[@]}"; do
    if yay -Q "$package" &>/dev/null; then
        print_info "$package уже установлен"
    else
        print_info "Установка $package..."
        if yay -S --needed --noconfirm "$package"; then
            print_success "$package установлен"
        else
            print_warning "$package не установлен; продолжаю установку остальных AUR пакетов"
            FAILED_AUR_PACKAGES+=("$package")
        fi
    fi
done
if [ "${#FAILED_AUR_PACKAGES[@]}" -gt 0 ]; then
    print_warning "AUR пакеты, которые нужно проверить вручную: ${FAILED_AUR_PACKAGES[*]}"
fi
print_success "AUR пакеты установлены"

# ============================================================================
# 6. НАСТРОЙКА ДОПОЛНИТЕЛЬНЫХ КОМПОНЕНТОВ
# ============================================================================

print_section "6. Настройка дополнительных компонентов"

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
# 7. НАСТРОЙКА LSP И ФОРМАТТЕРОВ ДЛЯ NEOVIM
# ============================================================================

print_section "7. Установка LSP серверов и форматтеров"

# Эти пакеты будут установлены через Mason в Neovim при первом запуске,
# но некоторые ставим системно для надежности (не входят в pkglist)
LSP_FORMATTERS=(
    lua-language-server # Lua LSP
    stylua              # Lua formatter
    prettier            # Форматтер для многих языков
)

install_pkg_group "LSP-серверы и форматтеры" LSP_FORMATTERS

print_info "Дополнительные LSP серверы будут установлены через Mason при первом запуске Neovim"

# ============================================================================
# 8. НАСТРОЙКА DOTFILES (STOW)
# ============================================================================

print_section "8. Перенос конфигурации"

print_info "Используется репозиторий: $DOTFILES_REPO"

# Клонирование или обновление репозитория
if [ ! -d "$DOTFILES_DIR" ]; then
    print_info "Клонирование репозитория..."
    git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
elif [ ! -d "$DOTFILES_DIR/.git" ]; then
    CONFIG_BACKUP_DIR="${CONFIG_BACKUP_DIR:-$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)}"
    print_warning "$DOTFILES_DIR уже существует и не является git checkout; переношу в $CONFIG_BACKUP_DIR"
    mkdir -p "$CONFIG_BACKUP_DIR"
    mv "$DOTFILES_DIR" "$CONFIG_BACKUP_DIR/$(basename "$DOTFILES_DIR")"
    git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    print_info "Обновление репозитория..."
    git -C "$DOTFILES_DIR" pull --ff-only
fi

# Применение конфигов. Явно разворачиваем только реальные dotfiles-пути
# текущего репозитория; stow */ не захватывает .config и тащит служебные папки.
if [ -d "$DOTFILES_DIR" ]; then
    deploy_dotfiles_configs
fi

# ============================================================================
# 9. ФИНАЛЬНЫЕ НАСТРОЙКИ
# ============================================================================

print_section "9. Финальные настройки"

# Обновление базы данных шрифтов
print_info "Обновление кэша шрифтов..."
fc-cache -fv >/dev/null 2>&1
print_success "Кэш шрифтов обновлен"

# Включение необходимых служб
print_info "Включение системных служб..."
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service
run_optional_step "Docker service включен" sudo systemctl enable --now docker.service
run_optional_step "Пользователь добавлен в группу docker" sudo usermod -aG docker "$USER"
run_optional_step "CUPS service включен" sudo systemctl enable --now cups.service
run_optional_step "Reflector timer включен" sudo systemctl enable --now reflector.timer

# Автоустановка плагинов после раскладки конфигов
if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    run_optional_step "Tmux plugins установлены" "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

if command -v zsh >/dev/null 2>&1; then
    run_optional_step "Zinit/Zsh plugins обновлены" zsh -lic 'zinit update --all'
fi

if command -v nvim >/dev/null 2>&1 && [ -d "$HOME/.config/nvim" ]; then
    run_optional_step "Neovim Lazy plugins синхронизированы" nvim --headless '+Lazy! sync' '+qa'
fi

# ============================================================================
# ИТОГОВАЯ ИНФОРМАЦИЯ
# ============================================================================

print_section "✓ УСТАНОВКА ЗАВЕРШЕНА"

echo -e "${GREEN}Все зависимости успешно установлены!${NC}\n"

echo -e "${YELLOW}Следующие шаги:${NC}"
echo "1. Перезапустите систему или выйдите/войдите для применения изменений"
echo "2. Конфиги уже развернуты симлинками из $DOTFILES_DIR"
echo "3. При первом запуске Neovim выполните :Lazy sync для установки плагинов"
echo "4. В Tmux нажмите <prefix> + I для установки плагинов (Ctrl+Space + I)"
echo "5. Запустите 'hyprctl reload' после входа в Hyprland (или перезайдите в niri)"

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

# Статистика установки
print_info "Статистика установки:"
echo "- Установлено пакетов из официальных репозиториев: ~$(pacman -Q | wc -l)"

exit 0
