# Stage 04: Kubernetes Deployments & Pods

## 📌 Purpose & Overview
A **Deployment** provides declarative updates for Pods and ReplicaSets. You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate (e.g., rolling updates, self-healing, scaling).

In this stage, we deploy a 2-replica web application referencing the ConfigMap and Secret created in prior stages, complete with resource boundaries (`requests`/`limits`) and health probes (`readinessProbe`/`livenessProbe`).

---

## 🏗️ Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                      demo-app Namespace                     │
│                                                             │
│                ┌──────────────────────────┐                 │
│                │   Deployment Controller  │                 │
│                └────────────┬─────────────┘                 │
│                             │ Manages                       │
│                             ▼                               │
│                ┌──────────────────────────┐                 │
│                │        ReplicaSet        │                 │
│                └────────────┬─────────────┘                 │
│                             │ Maintains Replicas            │
│               ┌─────────────┴─────────────┐                 │
│               ▼                           ▼                 │
│        ┌──────────────┐            ┌──────────────┐         │
│        │  Pod 1 (Web) │            │  Pod 2 (Web) │         │
│        └──────────────┘            └──────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 Manifest Breakdown (`deployment.yaml`)

```yaml
spec:
  replicas: 2                     # Desired number of pod instances
  strategy:
    type: RollingUpdate           # Zero-downtime deployment strategy
  template:
    spec:
      containers:
      - name: web-app
        image: nginx:1.25-alpine
        resources:                # Resource requests and hard limits
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "250m"
            memory: "256Mi"
        readinessProbe:           # Checks if pod is ready to accept HTTP traffic
          httpGet:
            path: /
            port: 80
        livenessProbe:            # Restarts container if health check fails
          httpGet:
            path: /
            port: 80
```

---

## 🚀 Deployment & Verification

### 1. Apply Manifest
```bash
kubectl apply -f deployment.yaml
```

### 2. Verify Deployment & Pod Status
```bash
kubectl get deployments -n demo-app
kubectl get pods -n demo-app -o wide
```

### 3. Monitor Rolling Update Status
```bash
kubectl rollout status deployment/demo-app-deployment -n demo-app
```

---

## 🔍 Debugging & Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| `ImagePullBackOff` | Invalid image tag or repository authentication failure. | Verify image string (`nginx:1.25-alpine`). |
| `CrashLoopBackOff` | Application process crashes immediately on start. | Check pod logs: `kubectl logs <pod-name> -n demo-app`. |
| `OOMKilled` | Container exceeded memory limit (`256Mi`). | Increase memory limit in `resources.limits`. |
| Pod stuck in `Pending` | Insufficient CPU/Memory capacity across cluster nodes. | Check node allocatable capacity or lower `resources.requests`. |

---

## 💡 Common DevOps Interview Questions

1. **What is the difference between a Deployment, ReplicaSet, and Pod?**
   * *Answer*: A Pod is the smallest deployable unit. A ReplicaSet ensures a specified number of Pod replicas are running at any given time. A Deployment manages ReplicaSets to provide declarative updates, rollbacks, and zero-downtime deployments.

2. **What is the difference between a Liveness Probe and a Readiness Probe?**
   * *Answer*: A **Readiness Probe** determines if a pod is ready to receive network traffic (if it fails, the pod IP is removed from Service endpoints). A **Liveness Probe** determines if a container needs to be restarted (if it fails, Kubernetes kills and recreates the container).
