#!/bin/bash

set -e

echo "===== Starting Setup ====="

# Update system
sudo apt-get update -y

echo "===== Installing dependencies ====="
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    unzip

# -------------------------------
# Install Docker
# -------------------------------
echo "===== Installing Docker ====="

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start & enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

echo "Docker installed successfully"

# -------------------------------
# Install Terraform
# -------------------------------
echo "===== Installing Terraform ====="

curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update -y
sudo apt-get install -y terraform

echo "Terraform installed successfully"

# -------------------------------
# Install Ansible
# -------------------------------
echo "===== Installing Ansible ====="

sudo apt-get install -y ansible

echo "Ansible installed successfully"

# -------------------------------
# Verify installations
# -------------------------------
echo "===== Verifying installations ====="

docker --version
terraform -version
ansible --version

echo "===== Setup Completed Successfully ====="