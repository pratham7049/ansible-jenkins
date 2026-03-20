# Infrastructure Flow and Architecture

This document describes the complete flow of how the infrastructure is provisioned, from preparing the local environment to deploying the final application on Kubernetes.

## 1. High-Level Flow Diagram

![Infrastructure Flow Diagram](./architecture-diagram.png)

## 2. Detailed Component Breakdown

### Step 1: Local Environment Preparation (`install.sh`)
The `install.sh` script prepares the machine where you run your deployments (such as an EC2 bastion host). It installs essential CLI tools:
- **Docker**: For running or building containerized workloads.
- **Terraform**: The Infrastructure as Code (IaC) tool used to interact with AWS APIs.
- **AWS CLI**: To securely authenticate with your AWS account and fetch cluster credentials.
- **kubectl**: The Kubernetes command-line tool, used to communicate with the EKS cluster to deploy applications.

### Step 2: Remote State Backend (`bootstrap/`)
Terraform requires a place to store its "state" (a map of what it has created). Instead of storing this locally, we use a remote backend for safety and collaboration.
- **S3 Bucket**: Securely stores the `terraform.tfstate` file with encryption and versioning.
- **DynamoDB Table**: Provides a locking mechanism. When you run `terraform apply`, it locks the table so multiple users cannot apply changes simultaneously, preventing state corruption.

### Step 3: Infrastructure Provisioning (`terraform/`)
This is the core of the project. Terraform reads its `.tf` configurations and provisions a production-ready environment in a structured, modular way:
- **`modules/vpc`**: Creates an isolated network (VPC) with Public subnets (for external traffic/LoadBalancers) and Private subnets (for the worker nodes). It also creates an Internet Gateway and NAT Gateway so private nodes can reach the internet securely without being exposed directly.
- **`modules/security`**: Creates Security Groups (virtual firewalls) dictating what network traffic is allowed in and out of the cluster.
- **`modules/iam`**: Sets up AWS Identity and Access Management (IAM) Roles to give the EKS control plane and worker nodes the exact declarative permissions they need to operate.
- **`modules/eks`**: Provisions the actual Kubernetes control plane (managed by AWS) and spins up an Auto Scaling Group of EC2 instances (based on configured instance types) as worker nodes to run your containers.

### Step 4: Application Deployment (`k8s/`)
Once the infrastructure is ready, we deploy our sample application using standard Kubernetes YAML manifests inside the `k8s/` folder.
- **Namespace**: Creates an `nginx` namespace to logically isolate the application resources.
- **Deployment**: Configures a ReplicaSet to ensure a specific number of Nginx pods are always running.
- **Service**: Creates a service of `type: LoadBalancer`. In EKS, this automatically commands AWS to provision a Classic or Network Load Balancer that routes external internet traffic directly into the Nginx pod running in your cluster.
