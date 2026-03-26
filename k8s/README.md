# Kubernetes Reverse Proxy Architecture

This standard Kubernetes setup uses **Nginx** as a central reverse proxy (functioning essentially as a lightweight API Gateway or Ingress controller). Nginx accepts all incoming traffic on a single external IP address and port, and securely routes it to the appropriate backend microservices running inside the cluster.

## 🌊 Traffic Flow
1. **External Traffic** hits the **`nginx-service`** on port `80` (This is the LoadBalancer that exposes your system to the outside world).
2. The `nginx-service` routes the request directly to the **Nginx Pod** (`nginx-deployment`).
3. Inside the Nginx Pod, the rules defined in **`nginx-configmap.yaml`** are applied:
    * If the request path is `/api/`, Nginx acts as a middleman and completely forwards the request to the `futureai-backend` container on port `8000`.
    * If the request path is just `/` (or anything else), Nginx forwards it to the `futureai-frontend` container on port `80`.

---
## 📁 File Descriptions & Learnings

### 1. `nginx-service.yaml`
* **Role**: The main public entry point for your application.
* **Type**: `LoadBalancer`
* **Learning**: By keeping this as the ONLY LoadBalancer in our setup, we save money (cloud providers charge per LoadBalancer) and consolidate security. You never need to change this file even if you add 100 new microservices; it strictly exposes Nginx to the world.

### 2. `nginx-configmap.yaml`
* **Role**: The routing brain of the proxy.
* **Learning**: It holds the `nginx.conf` file as plain text data. Kubernetes allows us to mount this data as a real configuration file directly inside the Nginx container without baking it into a specialized Docker image.

### 3. `nginx-deployment.yaml`
* **Role**: Runs the standard, out-of-the-box `nginx:latest` image.
* **Learning**: It uses `volumeMounts` to grab the data from `nginx-configmap.yaml` and place it perfectly into `/etc/nginx/conf.d/default.conf`. If we edit the config map, we can restart this deployment to apply new routing rules dynamically.

### 4. `futureai-frontend.yaml` & `5. futureai-backend.yaml`
* **Role**: The actual business logic of your application.
* **Type**: `ClusterIP`
* **Learning**: `ClusterIP` is the default service type in Kubernetes. It means the service is **internal only**. It cannot be reached directly from the internet, which makes it highly secure. It can only be reached by other pods inside the cluster (like our Nginx pod!).

---

## 🛠️ Configuration & Deployment Steps

To configure and deploy this architecture to your Kubernetes cluster, run the following commands from this directory:

1. **Create the Namespace**
   ```bash
   kubectl apply -f nginx-namespace.yaml
   ```

2. **Deploy the ConfigMap (Nginx Routing Rules)**
   ```bash
   kubectl apply -f nginx-configmap.yaml
   ```

3. **Deploy the Microservices (Backend and Frontend)**
   ```bash
   kubectl apply -f futureai-backend.yaml
   kubectl apply -f futureai-frontend.yaml
   ```

4. **Deploy the Nginx Proxy and Service**
   ```bash
   kubectl apply -f nginx-deployment.yaml
   kubectl apply -f nginx-service.yaml
   ```

5. **Verify the Deployment**
   ```bash
   kubectl get pods -n nginx
   kubectl get svc -n nginx
   ```
   *Wait for the pods to be in the `Running` state. Use the `EXTERNAL-IP` of the `nginx-service` to access your application via browser.*

---

## 🚀 How to Add New Microservices in the Future
If you want to add a third microservice (e.g., `futureai-payments`), the process is incredibly straightforward:
1. Create a `futureai-payments.yaml` file outlining its `Deployment` and a `ClusterIP` Service (just like the backend).
2. Apply it (`kubectl apply -f futureai-payments.yaml`).
3. Open `nginx-configmap.yaml` and add a new routing block under the `server` section:
   ```nginx
   location /payments/ {
       proxy_pass http://futureai-payments-service:8080/;
   }
   ```
4. Restart Nginx to load the changes: `kubectl rollout restart deployment nginx-deployment -n nginx`

That's it! Your `nginx-service.yaml` handles the rest automatically.
