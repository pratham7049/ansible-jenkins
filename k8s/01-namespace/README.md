# Stage 01: Kubernetes Namespaces

## 📌 Purpose & Overview
A **Namespace** provides a mechanism for isolating groups of resources within a single Kubernetes cluster. Namespaces divide cluster resources between multiple users, applications, or environments (e.g., `dev`, `staging`, `prod`).

In this stage, we create a dedicated namespace named **`demo-app`** to house all subsequent learning workloads.

---

## 🏗️ Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                      │
│                                                             │
│  ┌─────────────────────────┐   ┌─────────────────────────┐  │
│  │    kube-system          │   │        demo-app         │  │
│  │  (System Controllers)   │   │  (Learning Workloads)   │  │
│  └─────────────────────────┘   └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 Manifest Breakdown (`namespace.yaml`)

```yaml
apiVersion: v1            # Core Kubernetes API group
kind: Namespace           # Type of resource being created
metadata:
  name: demo-app          # Unique identifier for the namespace
  labels:                 # Key-value pairs for organization and filtering
    environment: learning
    team: devops
```

* **`apiVersion`**: Specifies the API version used to create the object.
* **`kind`**: Indicates that this manifest manages a `Namespace`.
* **`metadata.name`**: Specifies the name of the namespace (`demo-app`).
* **`metadata.labels`**: Used for metadata queries, RBAC policies, and resource tracking.

---

## 🚀 Deployment & Verification

### 1. Apply Manifest
```bash
kubectl apply -f namespace.yaml
```

### 2. Verify Namespace Status
```bash
kubectl get namespaces
```

### 3. Describe Namespace Details
```bash
kubectl describe namespace demo-app
```

---

## 🔍 Debugging & Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| `AlreadyExists` Error | Namespace with name `demo-app` already exists. | Run `kubectl get ns` to check existing namespaces. |
| Namespace stuck in `Terminating` | Resources or custom finalizers remaining inside namespace. | Inspect active resources: `kubectl get all -n demo-app` and delete lingering finalizers if necessary. |

---

## 💡 Common DevOps Interview Questions

1. **What is a Kubernetes Namespace, and why is it used?**
   * *Answer*: A Namespace provides logical isolation and multi-tenancy within a single physical cluster, allowing teams to partition resources, apply RBAC, and enforce resource quotas.

2. **Do Namespaces provide network isolation by default?**
   * *Answer*: No. By default, pods in one namespace can communicate with pods in another namespace unless restricted using **NetworkPolicies**.

3. **Which resources are non-namespaced (cluster-scoped)?**
   * *Answer*: `Nodes`, `PersistentVolumes`, `StorageClasses`, `ClusterRoles`, and `ClusterRoleBindings` are cluster-wide resources and do not belong to namespaces.
