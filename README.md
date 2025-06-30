# ECS EC2 Launch Type CI/CD Pipeline with Terraform

This repository contains Infrastructure as Code (IaC) using Terraform to provision an end-to-end AWS ECS cluster (EC2 launch type) with an Application Load Balancer (ALB), and a CI/CD pipeline using AWS CodePipeline and CodeBuild to deploy a Dockerized application from source to ECS.

---

## Features

- VPC with public subnets
- Internet Gateway and route tables
- Security group for HTTP and SSH access
- ECS cluster using EC2 launch type
- Autoscaling Group with Launch Template for ECS instances
- Application Load Balancer (ALB) forwarding traffic to ECS tasks
- ECS Service with Task Definition for Nginx demo container
- IAM roles and policies for ECS instances
- CI/CD pipeline using AWS CodePipeline + CodeBuild:
  - Pulls source from GitHub
  - Builds and pushes Docker image to Amazon ECR
  - Updates ECS Service with new Task Definition

---

## Architecture Diagram

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

---

## Prerequisites

- Terraform installed
- AWS CLI configured
- AWS account with permissions to create:
  - VPC, Subnets, Internet Gateway, Route Tables
  - EC2 instances, Security Groups
  - IAM Roles
  - ECS Cluster & Service
  - Application Load Balancer
  - CodePipeline, CodeBuild, and ECR repository

---

## Usage

```
# 1. Clone this repository
git clone https://github.com/AhmadMudassir/ecs-ec2-codepipeline-infra.git
cd ecs-ec2-codepipeline-infra

# 2. Initialize Terraform
terraform init

# 3. Review and set variables in variables.tf 
# 4. Plan the deployment
terraform plan

# 5. Apply the deployment
terraform apply
```

---

## Notes

- This repo sets up the infrastructure. The actual CodePipeline and CodeBuild resources can be added using Terraform or the AWS Console.
- Replace IAM ARNs, AMI IDs, and region-specific values with ones valid for your AWS account and region.

---
