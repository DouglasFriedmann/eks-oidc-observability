# EKS OIDC Observability

![CI](https://github.com/DouglasFriedmann/eks-oidc-observability/actions/workflows/ci.yaml/badge.svg)
![CodeQL](https://github.com/DouglasFriedmann/eks-oidc-observability/actions/workflows/codeql.yaml/badge.svg)

Production-style AWS EKS platform built with Terraform, FluxCD GitOps, and secure CI/CD using GitHub OIDC federation.

This project demonstrates how to build and operate a Kubernetes platform using modern DevOps practices.

Key areas demonstrated:

- Infrastructure as Code
- GitOps-based cluster management
- secure CI/CD without static credentials
- Kubernetes observability
- centralized logging
- least-privilege IAM design

Architecture

This repository provisions and operates the entire platform lifecycle.

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

Core design patterns used in this project:

Infrastructure provisioned with Terraform

Cluster state managed through FluxCD GitOps

CI authenticated to AWS using GitHub OIDC

Pods access AWS services using IRSA

Logs centralized in CloudWatch

Metrics visualized with Grafana

Infrastructure as Code

Terraform provisions the platform infrastructure, including:

VPC and networking

EKS cluster

managed node groups

ECR container registry

IAM roles and policies

GitHub OIDC provider

IRSA roles for Kubernetes workloads

This ensures the entire environment is reproducible and environment-agnostic.

GitOps with FluxCD

Cluster configuration is defined declaratively under:

clusters/dev/

Flux continuously reconciles the cluster state with the repository.

Benefits include:

Git as the single source of truth

safe and auditable deployments

automatic drift correction

Secure CI/CD with GitHub OIDC

GitHub Actions authenticates to AWS using OpenID Connect federation.

This eliminates static credentials in CI pipelines.

Security controls include:

role assumption restricted to this repository

branch-level restrictions

short-lived AWS credentials

Least-Privilege IAM

The GitHub Actions IAM role allows only the permissions required for CI:

login to ECR

push application images

describe the EKS cluster

Administrator privileges were intentionally removed to demonstrate least-privilege design.

Kubernetes Observability

Monitoring is deployed via Helm using the kube-prometheus-stack.

Components include:

Prometheus

Grafana

Alertmanager

kube-state-metrics

node exporter

These provide visibility into both cluster health and application performance.

Centralized Logging

Cluster logs are collected by Fluent Bit and forwarded to CloudWatch Logs.

Kubernetes Pods
      │
      ▼
Fluent Bit DaemonSet
      │
      ▼
CloudWatch Logs

Fluent Bit runs using IAM Roles for Service Accounts (IRSA) so workloads can access AWS services without inheriting node-level permissions.

Flux Image Automation

Flux automatically updates Kubernetes manifests when new images are pushed to ECR.

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

This enables fully automated application deployments through GitOps.

Quality and Security

The repository includes automated safeguards that run on pull requests:

pytest unit testing

ruff linting and formatting

GitHub Actions CI

CodeQL security scanning

Trivy container vulnerability scanning

Dependabot dependency updates

These checks ensure code quality and security before changes are merged.

Repository Structure
app/                 FastAPI sample application

clusters/dev/        GitOps environment configuration
  app/               Application manifests
  observability/     Prometheus + Grafana stack
  metrics-server/    Kubernetes metrics API
  fluent-bit/        Fluent Bit HelmRelease + IRSA
  flux-system/       Flux bootstrap configuration

iac/                 Terraform infrastructure
  vpc.tf
  eks.tf
  ecr.tf
  iam_github_oidc.tf
  iam_fluent_bit_irsa.tf
  iam_flux_image_reflector_irsa.tf

k8s-legacy/          Early Kubernetes manifests retained for reference
Platform Components

Infrastructure

AWS EKS

AWS VPC

AWS ECR

AWS CloudWatch Logs

IAM OIDC federation

Platform tooling

Terraform

FluxCD

Helm

Kubernetes

Observability

Prometheus

Grafana

Fluent Bit

CI/CD

GitHub Actions

Trivy container scanning

Application

FastAPI

Security Design

This platform demonstrates several production security patterns:

GitHub OIDC federation (no static AWS credentials)

least-privilege CI IAM role

IRSA for Kubernetes workloads

container image vulnerability scanning

scoped IAM policies
