EKS OIDC Observability

Production-style AWS EKS platform built with Terraform, FluxCD GitOps, and secure CI/CD.

This project demonstrates how to build and operate a Kubernetes platform using modern DevOps practices including:

Infrastructure as Code

GitOps-based cluster management

secure CI/CD with OIDC federation

Kubernetes observability

centralized logging

least-privilege IAM design

The goal is to showcase how a real platform might be engineered, not just how individual tools work.

Architecture

This repository provisions and operates a Kubernetes platform end-to-end.

GitHub Actions (OIDC)
        │
        ▼
   AWS IAM Role
        │
        ▼
Build → Scan → Push
        │
        ▼
        ECR
        │
        ▼
FluxCD Image Automation
        │
        ▼
GitOps Reconciliation
        │
        ▼
        EKS
   ├── FastAPI application
   ├── Prometheus + Grafana
   ├── Metrics Server
   └── Fluent Bit → CloudWatch Logs

Core design patterns:

Infrastructure provisioned via Terraform

Cluster state managed through FluxCD GitOps

CI authenticated to AWS using GitHub OIDC

Pods access AWS services through IRSA

Logs centralized in CloudWatch

Metrics visualized in Grafana

Key DevOps Practices Demonstrated
Infrastructure as Code

Terraform provisions:

VPC and networking

EKS cluster

managed node groups

ECR repository

IAM roles and policies

GitHub OIDC provider

IRSA roles for Kubernetes workloads

Infrastructure is reproducible and environment-agnostic.

GitOps with FluxCD

Cluster configuration is defined declaratively in:

clusters/dev/

Flux continuously reconciles cluster state with the repository.

Benefits:

Git becomes the source of truth

safe, auditable deployments

automatic drift correction

Secure CI/CD with GitHub OIDC

GitHub Actions authenticates to AWS using OpenID Connect federation.

This eliminates static credentials in CI.

Security controls include:

role assumption restricted to this repository

branch-level restrictions

short-lived AWS credentials

Least-Privilege IAM

The GitHub Actions IAM role allows only:

ECR login

pushing images to the application repository

describing the EKS cluster

Administrator privileges were intentionally removed.

Kubernetes Observability

Monitoring stack deployed through Helm:

kube-prometheus-stack

Includes:

Prometheus

Grafana

Alertmanager

kube-state-metrics

node exporter

Metrics provide visibility into cluster and workload health.

Centralized Logging

Cluster logs are collected by Fluent Bit.

Architecture:

Kubernetes Pods
      │
      ▼
Fluent Bit DaemonSet
      │
      ▼
CloudWatch Logs

Fluent Bit runs with IAM Roles for Service Accounts (IRSA) so pods can write logs to AWS without inheriting node IAM permissions.

Flux Image Automation

Flux automatically updates Kubernetes manifests when new images are pushed to ECR.

Workflow:

CI builds image
        │
        ▼
Image pushed to ECR
        │
        ▼
Flux Image Reflector detects new tag
        │
        ▼
Flux updates manifests
        │
        ▼
Cluster reconciles automatically

This enables fully automated application deployments via GitOps.

Repository Structure
app/
  FastAPI sample application

clusters/dev/
  GitOps environment configuration

  app/
    Application manifests

  observability/
    Prometheus + Grafana stack

  metrics-server/
    Kubernetes metrics API

  fluent-bit/
    Fluent Bit HelmRelease + IRSA

  flux-system/
    Flux bootstrap configuration

iac/
  Terraform infrastructure

  vpc.tf
  eks.tf
  ecr.tf
  iam_github_oidc.tf
  iam_fluent_bit_irsa.tf
  iam_flux_image_reflector_irsa.tf

k8s-legacy/
  Early Kubernetes manifests retained for reference
Platform Components

Infrastructure:

AWS EKS

AWS VPC

AWS ECR

AWS CloudWatch Logs

IAM OIDC Federation

Platform tooling:

Terraform

FluxCD

Helm

Kubernetes

Observability:

Prometheus

Grafana

Fluent Bit

CI/CD:

GitHub Actions

Trivy security scanning

Application:

FastAPI

Security Design

Several production security patterns are demonstrated:

GitHub OIDC federation (no static AWS credentials)

least-privilege CI IAM role

IRSA for Kubernetes workloads

container image vulnerability scanning

scoped IAM policies
