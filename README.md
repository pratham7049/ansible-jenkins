# DevOps Jenkins Project

## 🚀 Overview
This project uses:
- Terraform → Provision EC2
- Ansible → Install Jenkins

## 🛠️ Steps

### 1. Generate SSH Key
ssh-keygen -t rsa -b 2048 -f keys/ansible-key

### 2. Run Terraform
cd terraform
terraform init
terraform apply -auto-approve

### 3. Access Jenkins
http://<EC2_PUBLIC_IP>:8080

### 4. Get Admin Password
ssh -i ../keys/ansible-key ubuntu@<IP>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword