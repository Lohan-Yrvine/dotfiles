#!/bin/sh

# ----------------------------- VARIÁVEIS ----------------------------- #
PPA_LIBRATBAG="ppa:libratbag-piper/piper-libratbag-git"
PPA_CHROMIUM="ppa:xalt7x/chromium-deb-vaapi"

URL_DISCORD="https://discord.com/api/download?platform=linux&format=deb"

DOWNLOAD_FOLDER="$HOME/Downloads/programs"

GITHUB_REPOSITORIOS=(
    https://github.com/Lohan-Yrvine/config-files
    https://github.com/alacritty/alacritty.git
    https://github.com/Lohan-Yrvine/wallpapers
)

PROGRAMAS_APT=(
    snapd
    flatpak
    flameshot
    htop
    bat
    neofetch
    neovim
    ratbagd
    piper
    chromium-browser
    chromium-codecs-ffmpeg
    yarn
    nodejs
    zsh
    cmake
    pkg-config
    libfreetype6-dev
    libfontconfig1-dev
    libxcb-xfixes0-dev
    libxkbcommon-dev
    python3
    fonst-firacode
    exuberant-ctags
    ccls
    vlc
    timeshift
    curl
    wallch
    tmux
)

PROGRAMAS_CURL=(
    "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs
)

# ----------------------------- REQUISITOS ----------------------------- #
sudo rm /var/lib/apt/lists/lock
sudo rm /var/lib/dpkg/lock
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

sudo apt update

sudo apt-add-repository "$PPA_LIBRATBAG" -y
sudo apt-add-repository "$PPA_CHROMIUM" -y
sudo apt-add-repository universe

for repositorio in ${GITHUB_REPOSITORIOS}; do
    git clone $repositorio
done

# ----------------------------- EXECUÇÃO ----------------------------- #
sudo apt update

mkdir "$DOWNLOAD_FOLDER" 
wget -c "$URL_DISCORD" -P "$DOWNLOAD_FOLDER"

sudo dpkg -i $DOWNLOAD_FOLDER/*.deb

for programa in ${PROGRAMAS_APT}; do
    if ! dpkg -l | grep -q $programa; then
        sudo apt install $programa -y
    else
        echo "[INSTALADO] - $programa"
    fi
done

for programa in ${PROGRAMAS_CURL}; do
    sh -c $programa
done

# zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

rustup override set stable
rustup update stable

## Pacotes Flakpak ##

## Pacotes Snap ##
sudo snap install spotify

## Alacritty ##
cd alacritty
cargo build --release

### Terminfo ###
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info

### Desktop Entry ###
sudo cp target/release/alacritty /usr/local/bin
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

### Manual Page ###
sudo mkdir -p /usr/local/share/man/man1
gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null

cd

# ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #
sudo apt update
sudo apt dist-upgrade
flatpak update
sudo apt autoclean
sudo apt autoremove -y
sudo dpkg --configure -a

git config --global user.name "Lohan Pinheiro"
git config --global user.email "o.lohan.yrvine@gmail.com"

mkdir ~/.config/nvim
mkdir ~/.config/alacritty
cp -f ~/config-files/init.vim ~/.config/nvim
cp -f ~/config-files/coc-settings.json ~/.config/nvim
cp -f ~/config-files/alacritty.yml ~/.config/alacritty
cp -f ~/config-files/.zshrc ~/
cp -f ~/config-files/.tmux.conf ~/

echo "---------- LISTA DE AJUSTES MANUAIS QUE PRECISAM SER FEITOS ----------"
echo "setar o flameshot para iniciar com o SO"
echo "mudar o PrtSc para printar com o flameshot por padrão (flameshot gui)"
echo "configurar o coc.nvim"
echo "configurar o timeshift"
echo "setar o zsh como shell padrão"
echo "setar o alacritty como terminal padrão"
echo "configurar wallch"
echo "configurar mouse no piper"
echo "setar source-file do tmux com <C-b> :source-file ~/.tmux.conf"
