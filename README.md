# DevOps Project: One-Click Jenkins Pipeline

## Overview
This project automates the provisioning and deployment of a static web app on Azure using Jenkins, Terraform, and Ansible.

## Technologies Used
- Jenkins (in Docker)
- Terraform (Azure VM provisioning)
- Ansible (Configuration & Deployment)
- Azure

## Setup Instructions
1. Run Jenkins in Docker (with Terraform and Ansible accessible).
2. Set up SSH key and add it to Jenkins credentials.
3. Define Azure credentials as environment variables or use a `terraform.tfvars`.
4. Start Jenkins pipeline.

## Project Structure
- `terraform/`: Terraform configs
- `ansible/`: Ansible playbook
- `app/`: Static web app
- `Jenkinsfile`: CI/CD pipeline

## Author
Sameer Nizar
