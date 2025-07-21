# 🚀 ECS EC2 Launch Type CI/CD Pipeline with Terraform (Console Pipeline Repo - ECS Infra only)

This repository contains Infrastructure as Code (IaC) using Terraform to provision an end-to-end AWS ECS cluster (EC2 launch type) with an Application Load Balancer (ALB), and a complete CI/CD pipeline using AWS CodePipeline and CodeBuild to deploy a Dockerized application from source to ECS.

---

## 📦 Features

- 🛡 **VPC** with public subnets
- 🌐 Internet Gateway and route tables
- 🔒 Security group for HTTP and SSH access
- 🧩 **ECS cluster** using EC2 launch type
- ⚙️ **Auto Scaling Group** with Launch Template for ECS instances
- 🎯 **Application Load Balancer (ALB)** forwarding traffic to ECS tasks
- 🐳 ECS Service with Task Definition for Nginx demo container
- 🔑 IAM roles and policies for ECS instances
- 🛠 **CI/CD pipeline** using AWS CodePipeline + CodeBuild:
  - 📥 Pulls source from GitHub
  - 🏗 Builds and pushes Docker image to Amazon ECR
  - 🚀 Updates ECS Service with the new Task Definition

---

## 🖼 Architecture Diagram

```
GitHub (Source)
    |
    v
AWS CodePipeline
    | -> AWS CodeBuild -> Amazon ECR (Docker Image)
    v
ECS Service (EC2 Launch Type)
    |
    v
Application Load Balancer
```


![ECS-CodeDeploy](https://github.com/user-attachments/assets/759636b3-731f-4aff-82ea-9d4dd3cbfc6a)

---

## ✅ Prerequisites

- Terraform installed
- AWS CLI configured
- AWS account with permissions to create:
  - VPC, Subnets, Internet Gateway, Route Tables
  - EC2 instances, Security Groups
  - IAM Roles
  - ECS Cluster & Service
  - Application Load Balancer
  - CodePipeline, CodeBuild, and ECR repository

⚠️ **Important:** You must create the AWS CodeStar (or CodeConnections) connection to GitHub manually in the AWS Console before deploying. This is not provisioned by Terraform.

---

## ⚡ Getting Started

```bash
# 1️⃣ Clone this repository
git clone https://github.com/AhmadMudassir/ecs-ec2-codepipeline-infra.git
cd ecs-ec2-codepipeline-infra

# 2️⃣ Initialize Terraform
terraform init

# 3️⃣ Review and set variables in variables.tf

# 4️⃣ Plan the deployment
terraform plan

# 5️⃣ Apply the deployment
terraform apply
```

---

## 📝 Notes

- ⚠️ **Important:** This repository sets up the infrastructure. You can add the actual CodePipeline and CodeBuild resources by configuring them manually in the AWS Console.
- Make sure to replace:
  - IAM ARNs
  - AMI IDs
  - Region-specific values
  with valid ones for your AWS account and region.

---
