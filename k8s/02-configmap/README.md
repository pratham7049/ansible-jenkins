# Stage 02: Kubernetes ConfigMaps

## 📌 Purpose & Overview
A **ConfigMap** allows you to decouple environment-specific configuration artifacts from container image specifications. This design pattern ensures container images remain completely portable across environments (e.g., development, staging, production).

In this stage, we store non-sensitive key-value pairs and application JSON configuration blocks inside `demo-app-config`.

---

## 🏗️ Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                      demo-app Namespace                     │
│                                                             │
│  ┌─────────────────────────┐     Inject Env / Volume Mount   │
│  │    ConfigMap            │ ─────────────────────────────┐ │
│  │   (demo-app-config)     │                              │ │
│  └─────────────────────────┘                              ▼ │
│                                                  ┌──────────────┐
│                                                  │  Target Pod  │
│                                                  └──────────────┘
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 Manifest Breakdown (`configmap.yaml`)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-app-config
  namespace: demo-app
data:
  APP_ENV: "production"             # Key-value string pair
  APP_LOG_LEVEL: "info"
  app-config.json: |                # Multi-line string block
    {
      "site_title": "EKS Learning Platform",
      "max_connections": 500
    }
```

---

## 🚀 Deployment & Verification

### 1. Apply Manifest
```bash
kubectl apply -f configmap.yaml
```

### 2. Verify ConfigMap Creation
```bash
kubectl get configmaps -n demo-app
```

### 3. Display Detailed Values
```bash
kubectl describe configmap demo-app-config -n demo-app
```

---

## 🔍 Debugging & Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| Pod fails to start (`CreateContainerConfigError`) | Pod references a ConfigMap key or name that does not exist. | Verify ConfigMap name and key names match pod env specs. |
| Mounted file changes not updating in app | App binary does not watch file changes or ConfigMap mounted via `subPath`. | Reload app or restart pod. Note: `subPath` mounts do not automatically update. |

---

## 💡 Common DevOps Interview Questions

1. **How can a Pod consume data from a ConfigMap?**
   * *Answer*: Through environment variables (`envFrom` or `valueFrom`), container command-line arguments, or mounted files in a `volume`.

2. **Is it safe to store sensitive database passwords in a ConfigMap?**
   * *Answer*: No. ConfigMaps store plaintext data. Sensitive data should be stored in **Kubernetes Secrets** or external key management vaults.
