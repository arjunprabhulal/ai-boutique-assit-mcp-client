#!/bin/bash

# AI Boutique Assistant - Docker Build and GKE Deploy Script
# Usage: ./deploy.sh [PROJECT_ID] [REGION] [CLUSTER_NAME]

set -e

# Configuration
PROJECT_ID=${PROJECT_ID:-${1:-"your-gcp-project-id"}}
REGION=${REGION:-${2:-"us-central1-a"}}
CLUSTER_NAME=${CLUSTER_NAME:-${3:-"online-boutique"}}
IMAGE_NAME="ai-boutique-assistant"
IMAGE_TAG=$(date +%s)

echo "🚀 AI Boutique Assistant Deployment"
echo "====================================="
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Cluster: $CLUSTER_NAME"
echo "Image: gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"
echo ""



# Build Docker image
echo "🐳 Building Docker image for AMD64 platform..."
docker build --platform linux/amd64 -t gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG .



# Push to Google Container Registry
echo "📤 Pushing image to Google Container Registry..."
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG




# Update deployment YAML with correct image
echo "📝 Updating deployment YAML with project ID and image tag..."
sed -e "s/YOUR_PROJECT_ID/$PROJECT_ID/g" -e "s/:latest/:$IMAGE_TAG/g" k8s/deployment.yaml > k8s/deployment-updated.yaml

# Apply Kubernetes manifests
echo "🚀 Deploying to GKE..."
kubectl apply -f k8s/deployment-updated.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

# Wait for deployment
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/ai-boutique-mcp

# Get service and ingress information
echo "📋 Getting service and ingress information..."
kubectl get services ai-boutique-mcp-service
kubectl get ingress ai-boutique-mcp-ingress

echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "🔍 To check the status:"
echo "  kubectl get pods -l app=ai-boutique-mcp"
echo "  kubectl logs -l app=ai-boutique-mcp"
echo ""
echo "🌐 To get the external IP:"
echo "  kubectl get ingress ai-boutique-mcp-ingress"
echo ""
echo "🗑️  To delete the deployment:"
echo "  kubectl delete -f k8s/deployment-updated.yaml -f k8s/service.yaml -f k8s/ingress.yaml"
