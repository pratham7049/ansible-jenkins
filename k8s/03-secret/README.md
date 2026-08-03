# Stage 03: Kubernetes Secrets

## 📌 Purpose & Overview
A **Secret** is an object designed to hold sensitive data such as passwords, OAuth tokens, and SSH keys. Storing sensitive configuration in a Secret avoids placing credentials directly into container images or repository manifests.

In this manifest, we leverage `stringData` (which automatically converts plaintext strings to base64 encoding upon submission to the API server).

---

## 🏗️ Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                      demo-app Namespace                     │
│                                                             │
│  ┌─────────────────────────┐     Secure Env/Volume Mount    │
│  │     Secret              │ ─────────────────────────────┐ │
│  │   (demo-app-secret)     │                              │ │
│  └─────────────────────────┘                              ▼ │
│                                                  ┌──────────────┐
│                                                  │  Target Pod  │
│                                                  └──────────────┘
└─────────────────────────────────────────────────────────────┘
```

---

## 📄 Manifest Breakdown (`secret.yaml`)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: demo-app-secret
  namespace: demo-app
type: Opaque                      # Default arbitrary key-value secret type
stringData:                      # Allows writing plaintext values (auto-encoded to base64)
  DB_USERNAME: "db_admin_user"
  DB_PASSWORD: "SuperSecretPassword123!"
```

* **`type: Opaque`**: Indicates generic secret key-value data.
* **`stringData`**: Simplifies manifest creation by accepting raw strings and performing base64 encoding transparently.

---

## 🚀 Deployment & Verification

### 1. Apply Manifest
```bash
kubectl apply -f secret.yaml
```

### 2. Verify Secret Metadata (Values Hidden)
```bash
kubectl get secrets -n demo-app
```

### 3. Decode Secret Data
```bash
kubectl get secret demo-app-secret -n demo-app -o jsonpath="{.data.DB_PASSWORD}" | base64 --decode
```

---

## 🔍 Debugging & Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| `base64` decode output invalid | Manual base64 encoding included trailing newlines (`\n`). | Use `echo -n "string" \| base64` or `stringData` block. |
| Pod fails with `Secret "X" not found` | Namespace mismatch or secret name typo. | Verify Secret resides in `demo-app` namespace. |

---

## 💡 Common DevOps Interview Questions

1. **Are Kubernetes Secrets encrypted at rest by default in AWS EKS?**
   * *Answer*: By default, Kubernetes secrets are base64-encoded in `etcd`. However, AWS EKS supports AWS KMS envelope encryption for `etcd` to encrypt secret payloads at rest.

2. **What is the difference between `data` and `stringData` in a Secret manifest?**
   * *Answer*: `data` requires pre-encoded base64 strings, while `stringData` accepts raw unencoded strings and automatically converts them to base64 upon write operations.
