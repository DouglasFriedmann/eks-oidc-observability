# EKS OIDC Observability

🧠 Overview

This project provisions a fully reproducible Kubernetes platform on AWS and deploys a FastAPI application using GitOps principles.

It demonstrates:

Infrastructure as Code (Terraform)

EKS cluster provisioning

OIDC-based GitHub Actions IAM integration

GitOps with FluxCD

Observability via Prometheus + Grafana

Horizontal Pod Autoscaling with metrics-server

Container hardening best practices

🏗 Architecture

Infrastructure (Terraform)

VPC (public subnets)

EKS cluster

ECR repository

IAM roles (including GitHub OIDC role)

Remote state

Application

FastAPI app

Dockerized (non-root container)

Exposes /health and /metrics

Deployed via Kubernetes manifests

GitOps

FluxCD bootstrapped to the cluster

clusters/dev/ is the source of truth

All workloads reconciled from Git

Observability

Prometheus (via kube-prometheus-stack Helm chart)

Grafana

ServiceMonitor for app metrics

metrics-server for HPA

📂 Repository Structure
app/                 → FastAPI application + Dockerfile
iac/                 → Terraform infrastructure (EKS, VPC, ECR, IAM)
k8s/                 → Base Kubernetes manifests
clusters/dev/        → Flux GitOps environment (source of truth)
GitOps Layout
clusters/dev/
├── app/
├── observability/
├── metrics-server/
├── flux-system/
└── kustomization.yaml

Flux reconciles clusters/dev/ continuously.

🔁 Deployment Flow
1️⃣ Provision Infrastructure
cd iac
terraform init
terraform apply

This provisions:

EKS cluster

ECR repo

IAM roles

Networking

2️⃣ Build and Push Application Image
docker build -t app:dev ./app
docker tag app:dev <ECR_REPO_URL>:dev
docker push <ECR_REPO_URL>:dev
3️⃣ GitOps Deployment

Flux automatically reconciles:

flux reconcile source git flux-system -n flux-system
flux reconcile kustomization flux-system -n flux-system --with-source

Application and observability stack are applied via HelmRelease and Kustomize.

📊 Observability

Installed via Flux HelmRelease:

Prometheus

Grafana

kube-state-metrics

Node exporter

Verify
kubectl get pods -n observability
kubectl top pods -n app
kubectl get hpa -n app

Grafana:

kubectl port-forward svc/kube-prometheus-stack-grafana -n observability 3000:80
⚙️ Horizontal Pod Autoscaling

metrics-server installed via Flux HelmRelease

HPA scales FastAPI deployment based on CPU

Verify:

kubectl top pods -n app
kubectl get hpa -n app
🔐 Security Considerations

GitHub OIDC IAM role (no long-lived AWS keys in CI)

Non-root container runtime

IAM least privilege (cluster + GitHub role separation)

GitOps source authentication via SSH deploy key

No secrets committed to Git

💸 Teardown

To avoid AWS costs:

Suspend Flux (optional)
flux suspend kustomization flux-system -n flux-system
Destroy infrastructure
cd iac
terraform destroy
