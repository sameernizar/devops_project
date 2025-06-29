# Docker 

![alt text](image.png)








# 🚀 DevOps Automation Pipeline (Jenkins + Terraform + Ansible + Azure)

This project implements a complete DevOps CI/CD pipeline using **Jenkins**, **Terraform**, **Ansible**, **Docker**, and **Azure**. It provisions a virtual machine on Azure, installs Apache, and deploys a static website — all fully automated.

---

## ✅ Tools & Technologies Used

- **Terraform** – for provisioning Azure infrastructure
- **Ansible** – for configuring the VM and deploying a website
- **Jenkins** – for continuous integration and pipeline orchestration
- **Docker** – for containerizing Jenkins
- **Azure** – cloud provider
- **GitHub** – source code management

---

## 📁 Folder Structure

```
devops_project/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars        
├── ansible/
│   └── install_web.yml          # Installs Apache and copies index.html
├── app/
│   └── index.html               # Static site to deploy
├── Jenkinsfile                  # Pipeline definition
├── .gitignore
└── README.md
```

---

## 🔥 STEP 1: Setup Azure Service Principal

Login and generate credentials for Terraform:

```bash
az login

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/05580e5b-033d-48aa-aa79-e0084956bfb7"
```

It will output:

```json
{
  "appId": "abec7be5-f7d3-41b2-ab92-923671d3bcfa",
  "password": "dGH8Q~g_6B2kukF6GKrO9THyCVw9B03CQL7GPa~W",
  "tenant": "ca870cf6-d588-4e34-8aae-36315b4548af"
}
```

Get your subscription ID:

```bash
az account show --query id -o tsv
```

---

## 🐳 STEP 2: Run Jenkins in Docker

```bash
docker run -itd ^
  --name devops ^
  -p 8080:8080 -p 50000:50000 ^
  -v jenkins_home:/var/jenkins_home ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  jenkins/jenkins:lts
```

Open Jenkins at: [http://localhost:8080](http://localhost:8080)

---

## ⚙️ STEP 3: Install Tools Inside Jenkins Container

```bash
docker exec -u root -it devops bash

# Install Terraform
apt-get update
apt-get install -y curl unzip
TERRAFORM_VERSION="1.11.3"
curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Ansible
apt-get install -y python3-pip
pip3 install ansible --break-system-packages

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

exit
```

---

## 📂 STEP 4: Create `terraform.tfvars` (Inside Jenkins Container)

Go back into the container:

```bash
docker exec -it devops bash
cd /var/jenkins_home/workspace/devops-automation/terraform
```

Create the file:

```bash
cat > terraform.tfvars
```

Paste this:

```hcl
subscription_id = "your-subscription-id"
client_id       = "your-client-id"
client_secret   = "your-client-secret"
tenant_id       = "your-tenant-id"

resource_group  = "devops-rg"
location        = "East US"
admin_username  = "azureuser"
ssh_public_key  = "ssh-rsa AAAA... your public key here"
```

---

## 🧱 STEP 5: Ensure All Variables Are Declared in `variables.tf`

Your `terraform/variables.tf` should include:

```hcl
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "resource_group" {}
variable "location" {}
variable "admin_username" {}
variable "ssh_public_key" {}
```

---

## ⚒️ STEP 6: Jenkins Job Setup

1. Open Jenkins → New Item → Name: `devops-automation`
2. Type: **Pipeline**
3. Under **Pipeline**:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repo URL: `https://github.com/<your-username>/devops_project.git`
   - Credentials: your GitHub token
   - Script Path: `Jenkinsfile`

---

## 📜 STEP 7: Jenkinsfile

```groovy
pipeline {
  agent any

  stages {
    stage('Terraform Init & Apply') {
      steps {
        dir('terraform') {
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Configure with Ansible') {
      steps {
        script {
          def ip = sh(script: "terraform -chdir=terraform output -raw public_ip", returnStdout: true).trim()
          writeFile file: 'ansible/inventory', text: "[web]\n${ip} ansible_user=azureuser ansible_ssh_private_key_file=/var/jenkins_home/.ssh/id_rsa"
        }
        dir('ansible') {
          sh 'ansible-playbook -i inventory install_web.yml'
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        script {
          def ip = sh(script: "terraform -chdir=terraform output -raw public_ip", returnStdout: true).trim()
          sh "curl http://${ip}"
        }
      }
    }
  }
}
```

---

## 🧪 STEP 8: Trigger the Pipeline

In Jenkins:

- Click your job: `devops-automation`
- Click **Build Now**
- View the logs to see:
  - Terraform creating the VM
  - Ansible configuring Apache and copying `index.html`
  - Curl verifying the web server

---

## 🌐 STEP 9: Verify on Azure

1. Go to Azure Portal
2. Open your resource group
3. Get the **public IP** of the VM
4. Open in browser


You should see your static website deployed!

---
