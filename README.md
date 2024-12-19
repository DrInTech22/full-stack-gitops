# Full Stack Automation Project Documentation

## Table of content

- [Overview](#overview)
- [Objectives](#objectives)
- [Technologies](#technologies)
- [Project Architecture](#project-architecture)
- [Project Structure](#project-structure)
- [Pipeline Configuration Files](#pipeline-configuration-files)
- [Infrastructure Pipelines](#infrastructure-pipelines)
- [Application Pipelines](#application-pipelines)



## Overview

This project uses GitOps principles to streamline infrastructure and application deployment. It leverages Github Actions CI/CD with tools like Terraform, Ansible, and Docker, to ensure efficient and automated provisioning and monitoring.

## Objectives

- **Cloud cost optimization** with cost estimation tools like InfraCost.  
- **GitOps workflows** for seamless automation.  
- **Terraform + Ansible integration** for infrastructure management and monitoring stack setup.  
- **Git branching strategies** for streamlined CI/CD pipelines.  

## Technologies
- **Terraform**: Infrastructure as Code tool to provision cloud resources.
- **Ansible**: Configuration management tool used for provisioning and configuring servers.
- **Docker**: Containerization platform used to package the application and monitoring stacks.
- **Traefik**: Reverse proxy for routing traffic between containers.
- **Grafana**: Used to monitor and visualize container-level metrics and logs.  
- **Prometheus**: collection of metrics
- **cAdvisor**: exposes container-level metrics
- **Loki**: log aggregation
- **Promtail**: log collection


## Project Architecture
<img src=".assets/gitops.png" alt="Architecture Image" />


## Project Structure
Infrastructure Branches: `infra_main` and `infra_features`
```
📦 Project Root
│
├── .github/
│   └── workflows/              # GitHub Actions CI/CD workflows
│       ├── ansible-monitoring.yml      # Workflow to trigger Ansible for monitoring stack
│       ├── terraform-apply.yml         # Workflow to apply Terraform configurations
│       ├── terraform-plan.yml          # Workflow to run 'terraform plan' and output cost estimations
│       └── terraform-validate.yml      # Workflow to validate Terraform configurations
│
├── ansible/
│   ├── roles/                  # Directory for Ansible roles (future role definitions)
│   ├── compose.monitoring.yml  # Docker Compose configuration for monitoring services
│   └── playbook.yml            # Main playbook for configuring the monitoring stack
│
├── monitoring/
│   ├── dashboards/             # Directory for custom Grafana dashboards
│   ├── dashboard-providers.yml # Grafana dashboard provider configuration
│   ├── loki-config.yml         # Loki log aggregation configuration
│   ├── loki-datasource.yml     # Grafana datasource configuration for Loki
│   ├── prometheus-datasource.yml # Prometheus datasource configuration for Grafana
│   ├── prometheus.yml          # Prometheus main configuration file
│   └── promtail-config.yml     # Promtail configuration for log scraping
│
├── terraform/
│   ├── ansible.tf              # Terraform resource for triggering Ansible
│   ├── backend.tf              # Backend configuration for Terraform state management
│   ├── dns.tf                  # DNS configurations
│   ├── ec2.tf                  # EC2 resource definitions
│   ├── main.tf                 # Main Terraform entry point
│   ├── output.tf               # Outputs from Terraform resources
│   ├── variables.tf            # Input variables for Terraform configurations
│   └── vpc.tf                  # VPC configuration for network setup
│
└── README.md                   # Documentation and project overview
```
Application Branches: `integration` and `deployment`
```
📦 Project Root
│
├── .github/
│   └── workflows/             # GitHub Actions CI/CD workflows
│       ├── cd-backend.yml      # Continuous Deployment workflow for backend
│       ├── cd-frontend.yml     # Continuous Deployment workflow for frontend
│       ├── ci-backend.yml      # Continuous Integration workflow for backend
│       └── ci-frontend.yml     # Continuous Integration workflow for frontend
│
├── backend/                   # Backend code and resources
│   └── ...                    # (Add backend-related files and folders here)
│
├── frontend/                  # Frontend code and resources
│   └── ...                    # (Add frontend-related files and folders here)
│
├── compose.yml                # Docker Compose configuration file for full-stack services
│
└── README.md                  # Project documentation and usage instructions
```
## Pipeline Configuration Files
The CI/CD pipelines are divided into modular `.yml`files for better organization and maintainability:

- Infrastructure Pipelines:
  - `terraform-validate.yml`: Validates Terraform configurations.
  - `terraform-plan.yml`: Runs terraform plan and includes cost estimation in PR comments.
  - `terraform-apply.yml`: Applies the Terraform configuration with auto-approval.
  - `ansible-monitoring.yml`: Deploys the monitoring stack using Ansible.
  
  These workflows are independently managed on the `infra_features` and `infra_main` branches.
- Application Pipelines:
  - `ci-frontend.yml`: Builds, test, packages and pushes the frontend Docker images, then updates compose.yml.
  - `cd-frontend.yml`: Deploys the frontend container in the cloud.
  - `ci-backend.yml`: Builds, test, packages and pushes the backend Docker images, then updates compose.yml.
  - `cd-backend.yml`: Deploys the backend, posgresql, and adminer containers in the cloud.

  These workflows are independently managed on the `integration` and `deployment` branches.


## Infrastructure Pipelines
These pipelines automates infrastructure provisioning and monitoring stack setup using Terraform and Ansible. Additionally, it utilizes an incredible tool such as InfraCost for cost breakdown, estimation and optimization.

### Branching Strategy
---
- `infra_features`: For writing and testing Terraform configurations.
- `infra_main`: The main branch for infrastructure management and provisioning.

### Pipeline Workflow
---
- Workflow Steps:
  - Push to `infra_features`: Triggers `terraform-validate.yml` to ensure configuration correctness.
  - Pull Request to `infra_main`: Triggers `terraform-plan.yml` which returns infrastructure plan and cost analysis as a PR comment.
  - Merge to `infra_main`: Triggers `terraform-apply.yml`terraform apply to provision infrastructure resources. `terraform-apply.yml` on successful completion, then trigger `ansible-monitoring.yml` to configure the server and deploy the monitoring stack (Prometheus, Grafana, Loki, Promtail & Cadvisor).
  
## Application Pipelines
The application pipeline build, test, packages and deploy the three-tier application stack.
### Branching Strategy
---
The two branches will start where continuous 
- `integration`: For managing the continuous integration of the applications
- `deployment`: For managing the continuous deployment of the containerized applications.

### Pipeline Workflow
---
- Workflow Steps:
  - Push to `integration`: Build Docker images for the application.
    - `ci-frontend.yml`: This pipeline is triggered when changes are made to the `frontend/` folder. Build, test and push the frontend image to dockerhub. Then it updates compose.yml with the recent frontend image tag.
    - `ci-backend.yml`: This pipeline is triggered when changes are made to the `backend/` folder. Build, test and push the backend image to dockerhub. Then it updates compose.yml with the recent backend image tag.

  - Merge from `integration` to `deployment`: Deploys the application stack to the provisioned cloud infrastructure.
    - `cd-frontend.yml`: This pipeline is triggered when changes are made to the `frontend/` folder. It pulls the updated docker image and deploys it.
    - `cd-backend.yml`: This pipeline is triggered when changes are made to the `backend/` folder. It pulls the updated docker image and deploys it.