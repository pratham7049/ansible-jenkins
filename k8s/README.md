# Progressive Kubernetes Learning Pathway

Welcome to the **Kubernetes Manifests & Learning Stages** directory.

This folder is structured into **7 sequential learning stages**, taking you from basic resource boundaries up to automated horizontal scaling and native AWS Application Load Balancer ingress routing.

---

## 📂 Stage-by-Stage Structure

| Stage Directory | Primary Resource | Concept Learned |
| :--- | :--- | :--- |
| **[`01-namespace/`](./01-namespace)** | `Namespace` | Workload isolation, multi-tenancy, and boundary management. |
| **[`02-configmap/`](./02-configmap)** | `ConfigMap` | Decoupling application configuration from container images. |
| **[`03-secret/`](./03-secret)** | `Secret` | Securely managing base64-encoded credentials and API keys. |
| **[`04-deployment/`](./04-deployment)** | `Deployment` | Managing stateless pod replicas, health probes, and rolling updates. |
| **[`05-service/`](./05-service)** | `Service` | Internal service discovery (`ClusterIP`) and DNS routing. |
| **[`06-ingress/`](./06-ingress)** | `Ingress` | Exposing apps via AWS ALB with the AWS Load Balancer Controller. |
| **[`07-hpa/`](./07-hpa)** | `HorizontalPodAutoscaler` | Dynamic pod scaling based on real-time CPU/Memory telemetry metrics. |

---

## 🚀 Deployment Order

Execute the stages in sequential order from `01` through `07`:

```bash
# 1. Namespace
kubectl apply -f 01-namespace/namespace.yaml

# 2. ConfigMap & Secret
kubectl apply -f 02-configmap/configmap.yaml
kubectl apply -f 03-secret/secret.yaml

# 3. Deployment
kubectl apply -f 04-deployment/deployment.yaml

# 4. Service
kubectl apply -f 05-service/service.yaml

# 5. Ingress (Requires AWS Load Balancer Controller)
kubectl apply -f 06-ingress/ingress.yaml

# 6. Horizontal Pod Autoscaler (Requires Metrics Server)
kubectl apply -f 07-hpa/hpa.yaml
```

Each subdirectory contains its own dedicated **`README.md`** file with architecture diagrams, manifest breakdowns, deployment guides, troubleshooting steps, and DevOps interview questions.
