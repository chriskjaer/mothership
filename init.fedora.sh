#!/usr/bin/env bash

set -e

USER=$1
USERHOME=/home/$USER

# Configure user
# Set $USER as password and force a new password on first login.
useradd -p "$(openssl passwd -1 "$USER")" $USER
chage -d 0 $USER

# Copy the Digital Ocean supplied ssh keys to this user
mkdir $USERHOME/.ssh
cat ~/.ssh/authorized_keys >>$USERHOME/.ssh/authorized_keys
chown -R $USER:$USER $USERHOME/.ssh

# Grant sudo priveleges
usermod -a -G wheel $USER

# Install stuff
sudo dnf -y copr enable seeitcoming/rcm
sudo dnf -y install rcm
sudo dnf -y install mosh
sudo dnf -y install git
sudo dnf -y install vim
sudo dnf -y install neovim
sudo dnf -y install zsh
sudo dnf -y install tmux
sudo dnf -y install curl
sudo dnf -y install nodejs
sudo dnf -y install fzf
sudo dnf -y install util-linux-user
sudo dnf -y install python2 # For nvim
sudo dnf -y install python3 # For nvim

curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo dnf -y install yarn

sudo usermod -s $(which zsh) $USER

# nvim setup
pip2 install neovim
pip3 install neovim
yarn global add neovim

# prepare projects dir
mkdir $USERHOME/projects

# Clone dotfiles and install them with rcup
git clone https://github.com/chriskjaer/dotfiles.git $USERHOME/.dotfiles
chown -R $USER:$USER $USERHOME/.dotfiles
sudo -H -u $USER bash -c 'cd ~/.dotfiles && rcup'
