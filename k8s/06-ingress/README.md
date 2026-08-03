# Stage 06: Kubernetes Ingress (AWS ALB)

## 📌 Purpose & Overview
An **Ingress** object manages external HTTP and HTTPS access to services within a cluster. Ingress can provide load balancing, SSL termination, and name-based virtual hosting.

In AWS EKS, creating an Ingress object with annotations `kubernetes.io/ingress.class: alb` signals the **AWS Load Balancer Controller** to provision an AWS Application Load Balancer (ALB) and configure target groups dynamically.

---

## 🏗️ Architecture Diagram

```text
                                [ Client / Internet ]
                                         │
                                         ▼
                     [ AWS Application Load Balancer (ALB) ]
                                         │
                                         ▼
                 [ AWS Load Balancer Controller (Target Group) ]
                                         │
                                         ▼
                     [ Kubernetes Ingress (demo-app-ingress) ]
                                         │
                                         ▼
                     [ Kubernetes Service (demo-app-service) ]
                                         │
                                         ▼
                        ┌────────────────┴────────────────┐
                        ▼                                 ▼
                 [ Pod 1 (IP 1) ]                  [ Pod 2 (IP 2) ]
```

---

## 📄 Manifest Breakdown (`ingress.yaml`)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-app-ingress
  namespace: demo-app
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing    # Provision public ALB
    alb.ingress.kubernetes.io/target-type: ip           # Direct pod IP target routing
spec:
  ingressClassName: alb
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: demo-app-service
            port:
              number: 80
```

* **`target-type: ip`**: Routes traffic directly from the ALB to Pod IP addresses via AWS VPC CNI (bypassing NodePort latency).
* **`scheme: internet-facing`**: Binds the ALB to public subnets created by the VPC Terraform module.

---

## 🚀 Deployment & Verification

### 1. Apply Manifest
```bash
kubectl apply -f ingress.yaml
```

### 2. Verify Ingress & Fetch ALB Public Address
```bash
kubectl get ingress -n demo-app
```
*(Wait 2–3 minutes for AWS to allocate the ALB hostname in the `ADDRESS` column).*

### 3. Test External Endpoint
```bash
curl -I http://<ALB-DNS-NAME>.ap-south-1.elb.amazonaws.com
```

---

## 🔍 Debugging & Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| Ingress `ADDRESS` remains empty | AWS Load Balancer Controller not running or missing subnet tags. | Check controller logs in `kube-system` namespace. Verify public subnets have tag `kubernetes.io/role/elb = 1`. |
| HTTP 502 Bad Gateway | Target group health checks failing. | Verify application readiness probe and port `80` container status. |

---

## 💡 Common DevOps Interview Questions

1. **What is the difference between target-type `ip` and `instance` in AWS ALB Ingress?**
   * *Answer*:
     * **`instance`**: ALB routes traffic to Node IPs on a NodePort, and `kube-proxy` routes to the pod.
     * **`ip`**: ALB routes traffic directly to the pod's AWS VPC IP address, bypassing NodePort and reducing network latency.

2. **What component processes Kubernetes Ingress resources on AWS EKS?**
   * *Answer*: The **AWS Load Balancer Controller**, an out-of-tree controller that reconciles Ingress resources into native AWS ALBs and Target Groups using AWS APIs.
