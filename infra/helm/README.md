
Helm install examples

# Add repos (example if using Bitnami Redis)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install Redis (optional)
helm upgrade --install payment-redis bitnami/redis --namespace payments --create-namespace

# Install Payment Gateway with EKS values
helm upgrade --install payment-gateway ./payment-gateway -n payments -f payment-gateway/values-eks.yaml   --set image.repository=your-registry/payment-gateway --set image.tag=1.0.0

# GKE / AKS
helm upgrade --install payment-gateway ./payment-gateway -n payments -f payment-gateway/values-gke.yaml
helm upgrade --install payment-gateway ./payment-gateway -n payments -f payment-gateway/values-aks.yaml
