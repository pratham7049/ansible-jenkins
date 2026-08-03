# Stage 05: Kubernetes Services (ClusterIP)

## 📌 Purpose & Overview
Pods in Kubernetes are ephemeral—their IP addresses change dynamically when pods are rescheduled or scaled. A **Service** is an abstract way to expose an application running on a set of Pods as a network service with a single, stable IP address and CoreDNS name.

In this stage, we define a **`ClusterIP`** service that load balances internal cluster traffic across pods matching the label selector `app=demo-app, tier=frontend`.

---

## 🏗️ Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                      demo-app Namespace                     │
│                                                             │
│                ┌──────────────────────────┐                 │
│                │   CoreDNS / ClusterIP    │                 │
│                │   (demo-app-service:80)  │                 │
│                └────────────┬─────────────┘                 │
│                             │ Load Balances (iptables/IPVS) │
│               ┌─────────────┴─────────────┐                 │
│               ▼                           ▼                 │
│        ┌──────────────┐            ┌──────────────┐         │
│        │ Pod 1 (IP 1) │            │ Pod 2 (IP 2) │         │
│        └──────────────┘            └──────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 Manifest Breakdown (`service.yaml`)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-app-service
  namespace: demo-app
spec:
  type: ClusterIP                 # Default service type (internal cluster IP)
  selector:
    app: demo-app                 # Target pod labels
    tier: frontend
  ports:
  - name: http
    port: 80                      # Port exposed by the Service
    targetPort: 80                # Port on the target pod container
    protocol: TCP
```

---

## 🚀 Deployment & Verification

### 1. Apply Manifest
```bash
kubectl apply -f service.yaml
```

### 2. Verify Service & Endpoints
```bash
kubectl get svc -n demo-app
kubectl get endpoints demo-app-service -n demo-app
```

### 3. Test Internal DNS & Connectivity via Port Forward
```bash
kubectl port-forward svc/demo-app-service 8080:80 -n demo-app
# Test in another terminal: curl http://localhost:8080
```

---

## 🔍 Debugging & Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| Service has no endpoints (`<none>`) | Selector mismatch between Service spec and Pod labels. | Run `kubectl get pods --show-labels -n demo-app` and compare with `service.spec.selector`. |
| Connection Refused | Target port mismatch (`targetPort` does not match container port). | Ensure container port matches `targetPort: 80`. |

---

## 💡 Common DevOps Interview Questions

1. **What are the four main types of Kubernetes Services?**
   * *Answer*:
     1. **`ClusterIP`**: Exposes service on an internal IP within the cluster (default).
     2. **`NodePort`**: Exposes service on each Node's IP at a static port (30000-32767).
     3. **`LoadBalancer`**: Exposes service externally using a cloud provider's load balancer (AWS NLB/CLB).
     4. **`ExternalName`**: Maps service to a CNAME record (external DNS name).

2. **How does Kubernetes route traffic from a Service to Pods?**
   * *Answer*: `kube-proxy` watches the API server for Service and Endpoint objects and updates `iptables` or `IPVS` rules on each node to distribute packets to pod target IPs.
