# Stage 07: Horizontal Pod Autoscaler (HPA)

## 📌 Purpose & Overview
The **Horizontal Pod Autoscaler (HPA)** automatically updates a workload resource (such as a Deployment) with the aim of scaling the workload to match demand.

HPA works by fetching resource telemetry metrics from the **Kubernetes Metrics Server** and scaling pod replicas up or down between `minReplicas` and `maxReplicas`.

---

## 🏗️ Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                      demo-app Namespace                     │
│                                                             │
│              ┌──────────────────────────────┐               │
│              │   Metrics Server (Telemetry) │               │
│              └──────────────┬───────────────┘               │
│                             │ Polls CPU/Memory              │
│                             ▼                               │
│              ┌──────────────────────────────┐               │
│              │ HorizontalPodAutoscaler (HPA)│               │
│              └──────────────┬───────────────┘               │
│                             │ Adjusts Replicas              │
│                             ▼                               │
│              ┌──────────────────────────────┐               │
│              │    demo-app-deployment       │               │
│              │    (2 Min ──> 10 Max Pods)   │               │
│              └──────────────────────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 Manifest Breakdown (`hpa.yaml`)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo-app-hpa
  namespace: demo-app
spec:
  scaleTargetRef:                 # Target deployment to scale
    apiVersion: apps/v1
    kind: Deployment
    name: demo-app-deployment
  minReplicas: 2                  # Lower replica threshold
  maxReplicas: 10                 # Upper replica ceiling
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50    # Scale up when avg CPU exceeds 50%
```

---

## 🚀 Deployment & Verification

### 1. Install Metrics Server (Prerequisite)
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 2. Apply HPA Manifest
```bash
kubectl apply -f hpa.yaml
```

### 3. Verify HPA Telemetry
```bash
kubectl get hpa -n demo-app
```

---

## 🔍 Debugging & Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| `TARGETS` shows `<unknown>/50%` | Metrics Server is not installed or container missing resource requests. | Deploy Metrics Server and verify `resources.requests` are defined in the deployment. |
| Pods not scaling down | HPA scale-down stabilization window (default 5 minutes) prevents rapid thrashing. | Wait for the 5-minute stabilization window to elapse. |

---

## 💡 Common DevOps Interview Questions

1. **How does HPA calculate the required number of replicas?**
   * *Answer*:
     $$\text{DesiredReplicas} = \left\lceil \text{CurrentReplicas} \times \left( \frac{\text{CurrentMetricValue}}{\text{TargetMetricValue}} \right) \right\rceil$$

2. **Why must container `resources.requests` be defined for HPA to work?**
   * *Answer*: Percentage utilization metrics (e.g., `50%`) are calculated relative to the pod's requested CPU/Memory resources. Without explicit `requests`, the controller cannot compute the percentage ratio.
