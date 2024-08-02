#!/usr/bin/env bash

remove_locks() {
    sudo rm /var/lib/dpkg/lock-frontend
    sudo rm /var/cache/apt/archives/lock
}

upgrade() {
    remove_locks
    sudo apt update
    sudo apt dist-upgrade -y
}

full_upgrade_and_clean() {
    upgrade
    sudo apt autoclean
    sudo apt autoremove -y
    flatpak update -y
    flatpak remove --unused -y
    snap refresh
}

upgrade

PPAS=(ppa:neovim-ppa/unstable ppa:papirus/papirus)
for ppa in ${PPAS[@]}; do
    sudo add-apt-repository ${ppa} -y
done

sudo apt update

PKGS=(
    neovim papirus-icon-theme clangd clang-format gdb tmux zsh kitty stow cmake
    flameshot latexmk biber zathura steam curl python3-pip libssl-dev snapd
    wget gnupg lsb-release apt-transport-https ca-certificates shfmt xsel
    python$(python3 --version | awk "{print $2}" | cut -d"." -f1-2)-venv
)

remove_locks
sudo apt install ${PKGS[@]} -y

upgrade

# librewolf
distro=$(if echo " una bookworm vanessa focal jammy bullseye vera uma " | grep -q " $(lsb_release -sc) "; then lsb_release -sc; else echo focal; fi)
wget -O- https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg
sudo tee /etc/apt/sources.list.d/librewolf.sources <<EOF >/dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: $distro
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF
remove_locks
sudo apt update
sudo apt install librewolf -y

FLATPAKS=(
    org.qbittorrent.qBittorrent
    org.videolan.VLC
    org.localsend.localsend_app
    com.heroicgameslauncher.hgl
    com.parsecgaming.parsec
    com.discordapp.Discord
    com.obsproject.Studio
    io.github.ungoogled_software.ungoogled_chromium
)
flatpak install flathub ${FLATPAKS[@]} -y

SNAPS=(nordpass btop)
sudo snap install ${SNAPS[@]}

full_upgrade_and_clean

PIPS=(grip black pipenv)
pip install ${PIPS[@]}

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
UNLOCKED_CRATES=(cargo-update eza bat ripgrep tree-sitter-cli)
cargo install ${UNLOCKED_CRATES[@]}
LOCKED_CRATES=(zoxide bat serie)
cargo install --locked ${LOCKED_CRATES[@]}

# install oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s

# make zsh the default shell
chsh -s $(which zsh)

# enable catppuccin latte theme
bat cache --build

# catppuccin
git clone https://github.com/catppuccin/chrome.git $HOME/repos/catppuccin-chrome --depth=1
git clone https://github.com/catppuccin/heroic.git $HOME/repos/catppuccin-heroic --depth=1

CATSYNTAX="$HOME/repos/catppuccin-zsh-syntax-highlighting"
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git $CATSYNTAX --depth=1
cp -f $CATSYNTAX/themes/*latte*.zsh $HOME/.zsh/

# tmux plugin manager
git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm --depth=1

# fonts
git clone https://github.com/ryanoasis/nerd-fonts.git $HOME/repos/nerd-fonts --depth=1
git clone https://github.com/google/fonts.git $HOME/repos/google-fonts --depth=1

./$HOME/dotfiles/scripts/google_fonts.sh
