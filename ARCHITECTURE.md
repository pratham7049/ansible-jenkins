# Enterprise AWS EKS Infrastructure & Kubernetes System Architecture

This document presents the technical architecture, network topology, security model, and end-to-end traffic routing for the **Amazon EKS Infrastructure & Kubernetes Learning Platform**.

---

## 1. High-Level Architecture Overview

The platform uses a two-tier architectural model:
1. **Infrastructure Tier**: Provisioned with **Terraform**, establishing an isolated Multi-AZ AWS network, IAM security roles, managed EKS control plane, and EC2 node groups.
2. **Platform & Workload Tier**: Orchestrated with **Kubernetes**, deploying application workloads, service discovery, auto-scaling, and native AWS Application Load Balancers via the AWS Load Balancer Controller.

---

## 2. Structural & Infrastructure Flow Diagrams

### Terraform Infrastructure Provisioning Flow

```text
               ┌─────────────────────────────────────────────────┐
               │              Terraform CLI Engine               │
               └────────────────────────┬────────────────────────┘
                                        │
                                        ▼
               ┌─────────────────────────────────────────────────┐
               │     Remote State Backend (S3 + DynamoDB)        │
               └────────────────────────┬────────────────────────┘
                                        │
             ┌──────────────────────────┼──────────────────────────┐
             ▼                          ▼                          ▼
  ┌────────────────────┐     ┌────────────────────┐     ┌────────────────────┐
  │   1. VPC Module    │ ──> │ 2. Security Module │ ──> │   3. IAM Module    │
  │ (Subnets/IGW/NAT)  │     │  (Security Groups) │     │ (Roles/IRSA/OIDC)  │
  └────────────────────┘     └────────────────────┘     └─────────┬──────────┘
                                                                  │
                                                                  ▼
                                                        ┌────────────────────┐
                                                        │   4. EKS Module    │
                                                        │ (Control & Nodes)  │
                                                        └────────────────────┘
```

### End-to-End Application Traffic Flow

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
                                         │ Targets (Direct Pod IP)
                                         ▼
                 ┌───────────────────────────────────────────────┐
                 │       Kubernetes Ingress Resource             │
                 │    (Managed by AWS Load Balancer Controller)  │
                 └───────────────────────┬───────────────────────┘
                                         │
                                         │ Target Group Rule
                                         ▼
                 ┌───────────────────────────────────────────────┐
                 │      Kubernetes Service (ClusterIP)           │
                 │        Endpoint IP & DNS Resolution           │
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

## 3. Network & Security Topology (`ap-south-1`)

### AWS VPC Subnet Layout

```text
AWS Region: ap-south-1 (Mumbai)
VPC CIDR: 10.0.0.0/16

├── Availability Zone 1: ap-south-1a
│   ├── Public Subnet 1  (10.0.1.0/24)  ──> Internet Gateway (IGW)
│   │   └── Tag: kubernetes.io/role/elb = 1
│   └── Private Subnet 1 (10.0.10.0/24) ──> NAT Gateway 1
│       └── Tag: kubernetes.io/role/internal-elb = 1
│
└── Availability Zone 2: ap-south-1b
    ├── Public Subnet 2  (10.0.2.0/24)  ──> Internet Gateway (IGW)
    │   └── Tag: kubernetes.io/role/elb = 1
    └── Private Subnet 2 (10.0.20.0/24) ──> NAT Gateway 1
        └── Tag: kubernetes.io/role/internal-elb = 1
```

---

## 4. Component Technical Matrix

| Component | Technology | AWS / K8s Resource | Function |
| :--- | :--- | :--- | :--- |
| **State Storage** | Terraform | `aws_s3_bucket`, `aws_dynamodb_table` | Encrypted state management and concurrent state locking. |
| **Networking** | Terraform | `aws_vpc`, `aws_subnet`, `aws_nat_gateway` | Multi-AZ network isolation. |
| **Security Groups** | Terraform | `aws_security_group` | Ingress/Egress stateful firewalls for control plane & nodes. |
| **Identity & Access** | Terraform | `aws_iam_role`, OIDC Provider | Service accounts (IRSA) and node execution policies. |
| **Kubernetes Compute**| Terraform | `aws_eks_cluster`, `aws_eks_node_group` | Managed control plane and EC2 auto-scaling worker nodes. |
| **Ingress Controller** | K8s Manifest | AWS Load Balancer Controller | Dynamically creates AWS ALBs based on Ingress YAML rules. |
| **Autoscaling** | K8s Manifest | `HorizontalPodAutoscaler` | Telemetry-driven pod scaling (CPU/Memory triggers). |

---

## 5. Security & Isolation Guarantees

1. **Private Subnet Execution**: All EKS worker nodes run in **Private Subnets**. They carry no public IPv4 addresses and can only communicate outward via NAT Gateways.
2. **Least-Privilege IAM Roles**: Control plane, worker nodes, and AWS Load Balancer Controller use dedicated IAM roles adhering to least-privilege boundaries.
3. **State Encryption**: Remote S3 state files are encrypted using AWS SSE-S3 AES-256 encryption.
