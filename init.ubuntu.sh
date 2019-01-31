#!/usr/bin/env bash

set -e

USERNAME=$1

# Add sudo user and grant privileges
useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"

# Delete invalid password for user if using keys so that a new password
# can be set without providing a previous value
passwd --delete "${USERNAME}"

# Expire the sudo user's password immediately to force a change
chage --lastday 0 "${USERNAME}"

# Create SSH directory for sudo user
home_directory="$(eval echo ~${USERNAME})"
mkdir --parents "${home_directory}/.ssh"

# Copy `authorized_keys` file from root
cp /root/.ssh/authorized_keys "${home_directory}/.ssh"

# Adjust SSH configuration ownership and permissions
chmod 0700 "${home_directory}/.ssh"
chmod 0600 "${home_directory}/.ssh/authorized_keys"
chown --recursive "${USERNAME}":"${USERNAME}" "${home_directory}/.ssh"

# Disable root SSH login with password
sed --in-place 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
if sshd -t -q; then
  systemctl restart sshd
fi

# Add exception for SSH and then enable UFW firewall
ufw allow OpenSSH
ufw --force enable

# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Install stuff
sudo add-apt-repository -y ppa:martin-frost/thoughtbot-rcm
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get -y update

sudo apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl \
  docker-ce \
  git \
  mosh \
  neovim \
  python-pip \
  python3-pip \
  rcm \
  software-properties-common \
  tmux \
  zsh \
  silversearcher-ag

sudo apt-get -y clean

# nvim setup
pip install neovim
pip3 install neovim

# Add user to the docker group, so that we can run it without sudo.
sudo usermod -aG docker ${USERNAME}

# Install docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.23.0-rc3/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone dotfiles
git clone https://github.com/chriskjaer/dotfiles.git "${home_directory}/.dotfiles"
chown --recursive "${USERNAME}":"${USERNAME}" "${home_directory}/.dotfiles"

sudo -H -u $USERNAME bash -c "cd ~/.dotfiles && rcup"
