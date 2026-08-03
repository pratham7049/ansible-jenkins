# Enterprise AWS EKS Infrastructure & Kubernetes Learning Platform

A production-grade, highly available Infrastructure as Code (IaC) repository for provisioning an **Amazon Elastic Kubernetes Service (EKS)** cluster using **Terraform** on AWS, paired with a structured, step-by-step **Kubernetes Fundamentals Learning Pathway**.

Designed by Senior DevOps & Kubernetes Platform Engineers, this project provides hands-on practice with core Kubernetes primitives, network isolation, security, auto-scaling, and native AWS Application Load Balancer (ALB) ingress integration in the **`ap-south-1`** (Mumbai) region.

---

## 🌟 Key Features

* **Modular Infrastructure as Code**: Reusable, DRY Terraform modules (`vpc`, `security`, `iam`, `eks`, `ec2`) following AWS Well-Architected guidelines.
* **Remote State Management**: Encrypted S3 backend for central state storage combined with DynamoDB for state locking and concurrency control.
* **Multi-AZ Network Architecture**: Multi-Availability Zone VPC topology featuring isolated public and private subnets, Internet Gateways, and NAT Gateways in `ap-south-1`.
* **Managed EKS Control Plane & Worker Nodes**: AWS EKS cluster paired with managed EC2 Auto-Scaling node groups running in private subnets.
* **Native AWS ALB Ingress Integration**: Uses the AWS Load Balancer Controller to dynamically provision AWS Application Load Balancers directly from Kubernetes `Ingress` resources.
* **Structured Kubernetes Learning Pathway**: Sequentially organized stage folders (`01` through `07`) with individual documentation explaining concepts, manifests, debugging, and DevOps interview questions.

---

## 🏗️ High-Level Architecture

### 1. Infrastructure Resource Flow

```text
Terraform CLI Engine
      │
      ▼
S3 State Backend + DynamoDB Lock
      │
      ├───────────────────────┬───────────────────────┐
      ▼                       ▼                       ▼
VPC Module              Security Module          IAM Module
(Subnets/IGW/NAT)       (Security Groups)     (Roles/IRSA/OIDC)
      │                       │                       │
      └───────────────────────┼───────────────────────┘
                              ▼
                        EKS Module
                    (Control & Nodes)
                              │
                              ▼
                     Kubernetes Cluster
```

### 2. Application & Ingress Traffic Flow

```text
                                [ Client / Internet ]
                                         │
                                         │ HTTP Port 80
                                         ▼
                 ┌───────────────────────────────────────────────┐
                 │    AWS Application Load Balancer (ALB)        │
                 │  Public Subnets (ap-south-1a / ap-south-1b)   │
                 └───────────────────────┬───────────────────────┘
                                         │
                                         │ Target Group Routing (Direct Pod IP)
                                         ▼
                 ┌───────────────────────────────────────────────┐
                 │       Kubernetes Ingress Resource             │
                 │    (Managed by AWS Load Balancer Controller)  │
                 └───────────────────────┬───────────────────────┘
                                         │
                                         │ Internal DNS / Endpoints
                                         ▼
                 ┌───────────────────────────────────────────────┐
                 │      Kubernetes Service (ClusterIP)           │
                 └───────────────────────┬───────────────────────┘
                                         │
                                         │ IPTables / VPC CNI Routing
                                         ▼
                 ┌───────────────────────────────────────────────┐
                 │            Kubernetes Deployment              │
                 └───────────────────────┬───────────────────────┘
                                         │
                         ┌───────────────┴───────────────┐
                         ▼                               ▼
                 ┌───────────────┐               ┌───────────────┐
                 │ Pod 1 Container│               │ Pod 2 Container│
                 │ Private Subnet│               │ Private Subnet│
                 └───────────────┘               └───────────────┘
```

---

## 📁 Project Structure

```text
ansible-jenkins-k8s-TF/
├── 📄 ARCHITECTURE.md              # Deep-dive architecture and network topology docs
├── 📄 README.md                    # Main repository master guide
├── 📄 install.sh                   # Bastion host environment setup script
├── 📄 .gitignore                   # Git ignore patterns for local state and secrets
│
├── 📂 bootstrap/                   # S3 Bucket & DynamoDB Remote State Backend
│   ├── main.tf                     # S3 bucket (AES256) & DynamoDB table configuration
│   ├── outputs.tf                  # Remote backend outputs
│   └── variables.tf                # Backend configuration variables
│
├── 📂 keys/                        # Key pairs for SSH / Ansible node access
│   ├── ansible-key                 # Private SSH key
│   └── ansible-key.pub             # Public SSH key
│
├── 📂 k8s/                         # Progressive Kubernetes Learning Stages
│   ├── 📂 01-namespace/            # Stage 1: Resource boundaries & Multi-tenancy
│   │   ├── namespace.yaml
│   │   └── README.md
│   ├── 📂 02-configmap/            # Stage 2: App configuration decoupling
│   │   ├── configmap.yaml
│   │   └── README.md
│   ├── 📂 03-secret/               # Stage 3: Sensitive data & credential management
│   │   ├── secret.yaml
│   │   └── README.md
│   ├── 📂 04-deployment/           # Stage 4: Workload lifecycle, rolling updates & health probes
│   │   ├── deployment.yaml
│   │   └── README.md
│   ├── 📂 05-service/              # Stage 5: Internal service discovery (ClusterIP)
│   │   ├── service.yaml
│   │   └── README.md
│   ├── 📂 06-ingress/              # Stage 6: External layer 7 routing via AWS ALB
│   │   ├── ingress.yaml
│   │   └── README.md
│   └── 📂 07-hpa/                  # Stage 7: Horizontal Pod Autoscaler (CPU/Memory metrics)
│       ├── hpa.yaml
│       └── README.md
│
└── 📂 terraform/                   # Main Infrastructure as Code
    ├── backend.tf                  # Remote S3 backend declaration
    ├── main.tf                     # Root module orchestration
    ├── outputs.tf                  # Cluster endpoints, OIDC provider, subnet outputs
    ├── terraform.tfvars            # Environment variable values (Default: ap-south-1)
    ├── variables.tf                # Input variable definitions
    └── 📂 modules/                 # Modular Infrastructure Components
        ├── 📂 ec2/                 # Bastion host instance module
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── 📂 eks/                 # Managed EKS Control Plane & Node Group module
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── 📂 iam/                 # EKS Roles, Node Roles & OIDC IRSA policies
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── 📂 security/            # Security group rules for VPC & EKS
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── 📂 vpc/                 # Multi-AZ VPC, Subnets, Route Tables, IGW & NAT
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```

---

## 🎓 Kubernetes Learning Roadmap

The project is structured to guide engineers through core Kubernetes concepts sequentially:

| Stage | Resource | Concept Learned | Technical Purpose |
| :--- | :--- | :--- | :--- |
| **01** | `01-namespace` | **Namespaces** | Creates virtual cluster boundaries (`demo-app`) for workload multi-tenancy. |
| **02** | `02-configmap` | **ConfigMaps** | Injects key-value configuration variables into container environments. |
| **03** | `03-secret` | **Secrets** | Mounts base64-encoded credentials into pod volumes/envs securely. |
| **04** | `04-deployment` | **Deployments** | Manages application container lifecycle, replicas, readiness & liveness probes. |
| **05** | `05-service` | **Services** | Provides stable internal IP addresses and DNS endpoints for pod communication. |
| **06** | `06-ingress` | **Ingress (AWS ALB)** | Configures HTTP layer 7 routing to automatically provision an AWS ALB. |
| **07** | `07-hpa` | **Horizontal Pod Autoscaler** | Dynamically scales pod replicas based on CPU and Memory telemetry. |
| **08** | Extended | **Storage (PV/PVC)** | Persistent storage management with EBS Container Storage Interface (CSI). |
| **09** | Extended | **RBAC** | Role-Based Access Control enforcing granular cluster permissions. |
| **10** | Extended | **Network Policies** | Fine-grained firewall rule enforcement between pod namespaces. |

---

## 🛠️ Prerequisites & Local Setup

### System Requirements
* **AWS CLI** (v2.x) configured with credentials: `aws configure`
* **Terraform** (v1.0+)
* **kubectl** matching EKS cluster version
* **eksctl** CLI utility
* Default AWS Region: **`ap-south-1`**

### Bastion / Ubuntu Helper Script
If deploying from an Ubuntu workstation or EC2 bastion host, run `install.sh` to initialize dependencies automatically:
```bash
chmod +x install.sh
./install.sh
```

---

## 🚀 Step-by-Step Deployment Guide

### Step 1: Provision Remote Backend Storage
Initialize state tracking in S3 with DynamoDB locking:
```bash
cd bootstrap
terraform init
terraform apply -auto-approve
cd ..
```

### Step 2: Provision Infrastructure with Terraform
Deploy the custom VPC, IAM roles, Security Groups, and EKS Cluster in `ap-south-1`:
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### Step 3: Configure Local Cluster Authentication
Update your local `~/.kube/config` to connect `kubectl` to the newly provisioned EKS cluster:
```bash
aws eks update-kubeconfig --region ap-south-1 --name ecs-project-cluster
```

Verify node connectivity:
```bash
kubectl get nodes -o wide
```

---

### Step 4: Install AWS Load Balancer Controller

To enable Kubernetes `Ingress` resources to provision AWS Application Load Balancers dynamically:

1. **Associate IAM OIDC Provider**:
   ```bash
   eksctl utils associate-iam-oidc-provider --cluster ecs-project-cluster --region ap-south-1 --approve
   ```

2. **Create IAM Policy & Controller Roles**:
   ```bash
   curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

   aws iam create-policy \
       --policy-name AWSLoadBalancerControllerIAMPolicy \
       --policy-document file://iam_policy.json

   kubectl apply -f https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.6.0/v2_6_0_full.yaml
   ```

3. **Verify Controller Deployment**:
   ```bash
   kubectl get deployment -n kube-system aws-load-balancer-controller
   ```

---

### Step 5: Install Kubernetes Metrics Server

The **Metrics Server** is required for `HorizontalPodAutoscaler` (HPA) to collect CPU/Memory utilization metrics:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify Metrics Server status
kubectl get deployment metrics-server -n kube-system
```

---

### Step 6: Deploy Kubernetes Learning Workloads

Deploy the stage-by-stage Kubernetes manifests sequentially:

```bash
cd ../k8s

# Stage 01: Create namespace
kubectl apply -f 01-namespace/namespace.yaml

# Stage 02 & 03: Apply ConfigMap and Secret
kubectl apply -f 02-configmap/configmap.yaml
kubectl apply -f 03-secret/secret.yaml

# Stage 04: Deploy application workload
kubectl apply -f 04-deployment/deployment.yaml

# Stage 05: Expose internal ClusterIP service
kubectl apply -f 05-service/service.yaml

# Stage 06: Provision AWS ALB via Ingress
kubectl apply -f 06-ingress/ingress.yaml

# Stage 07: Apply Horizontal Pod Autoscaler
kubectl apply -f 07-hpa/hpa.yaml
```

Verify all deployed workloads:
```bash
kubectl get all -n demo-app
kubectl get ingress -n demo-app
```

---

## 🛠️ Useful `kubectl` Commands

| Category | Purpose | Command |
| :--- | :--- | :--- |
| **Node Inspection** | List all worker nodes | `kubectl get nodes -o wide` |
| **Pod Operations** | List pods with IPs | `kubectl get pods -n demo-app -o wide` |
| **Detailed Inspection** | Describe pod details & events | `kubectl describe pod <pod-name> -n demo-app` |
| **Log Streaming** | Stream container stdout/stderr | `kubectl logs -f deployment/demo-app-deployment -n demo-app` |
| **Service Discovery** | Inspect active endpoints | `kubectl get endpoints demo-app-service -n demo-app` |
| **Ingress Telemetry** | Inspect ALB public DNS | `kubectl get ingress -n demo-app` |
| **Resource Monitoring**| View pod CPU & Memory usage | `kubectl top pods -n demo-app` |
| **Local Port Forward** | Test internal service locally | `kubectl port-forward svc/demo-app-service 8080:80 -n demo-app` |

---

## 🔍 Troubleshooting Guide

When encountering operational issues, use the following structured diagnosis workflow:

### 1. Cluster & Worker Node Health
```bash
kubectl get nodes
```
*If nodes show `NotReady`, verify NAT Gateway internet connectivity in private subnets and security group egress rules.*

### 2. Global Pod Status Diagnosis
```bash
kubectl get pods -A
```

### 3. Detailed Pod Failure Inspection
Investigate pod startup failures (e.g., `CrashLoopBackOff`, `ImagePullBackOff`, `Pending`):
```bash
kubectl describe pod <pod-name> -n demo-app
```

### 4. Container Logs Inspection
```bash
kubectl logs <pod-name> -n demo-app --all-containers
```

### 5. Ingress & ALB Provisioning Verification
Check if the AWS Load Balancer Controller successfully assigned an ALB address to the Ingress resource:
```bash
kubectl get ingress -n demo-app
```
*If `ADDRESS` remains blank, inspect controller logs:*
```bash
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### 6. Chronological Event Stream
```bash
kubectl get events -n demo-app --sort-by='.metadata.creationTimestamp'
```

---

## 💰 Estimated AWS Cost

Estimated cost breakdown for running this environment in **`ap-south-1`**:

| Component | Quantity | Estimated Cost (USD) |
| :--- | :--- | :--- |
| **EKS Control Plane** | 1 Cluster | ~$0.10 / hour (~$73.00 / month) |
| **EC2 Worker Nodes (`t3.medium`)** | 2 Instances | ~$0.0416 / hour each (~$60.00 / month total) |
| **NAT Gateway** | 1 Gateway | ~$0.045 / hour + data transfer fees (~$32.00 / month) |
| **AWS Application Load Balancer** | 1 ALB | ~$0.0225 / hour + LCU usage (~$18.00 / month) |
| **S3 & DynamoDB Backend** | Minimal Storage | < $1.00 / month |

> ⚠️ **Cost Disclaimer**: Resource costs vary based on uptime, region, and network throughput. To minimize AWS charges, **destroy all resources immediately after completing learning exercises**.

---

## 🧹 Infrastructure Teardown & Cleanup

Follow the strict teardown order to prevent orphaned AWS ALBs or security groups:

### Step 1: Delete Kubernetes Workloads & Ingress
```bash
cd k8s
kubectl delete -f 07-hpa/hpa.yaml
kubectl delete -f 06-ingress/ingress.yaml
kubectl delete -f 05-service/service.yaml
kubectl delete -f 04-deployment/deployment.yaml
kubectl delete -f 03-secret/secret.yaml
kubectl delete -f 02-configmap/configmap.yaml
kubectl delete -f 01-namespace/namespace.yaml
```
*Wait 2–3 minutes for the AWS Load Balancer Controller to release the AWS ALB.*

### Step 2: Destroy Terraform EKS Infrastructure
```bash
cd ../terraform
terraform destroy -auto-approve
```

### Step 3: Destroy Remote State Backend Storage (Optional)
```bash
cd ../bootstrap
terraform destroy -auto-approve
```

---

## 🚫 What is Intentionally Not Included Yet

To focus strictly on **Kubernetes Core Fundamentals and Terraform AWS Infrastructure**, the following enterprise abstractions are intentionally deferred for future extension modules:

* **GitOps Continuous Delivery**: Argo CD, FluxCD
* **Package Managers**: Helm Charts
* **DNS Automation & Custom Domains**: AWS Route53, ExternalDNS
* **Service Mesh Architecture**: Istio, Linkerd
* **Observability & Monitoring Stack**: Prometheus, Grafana, Loki
* **External Secret Managers**: HashiCorp Vault, AWS Secrets Manager integration
* **Advanced Autoscaling**: Karpenter