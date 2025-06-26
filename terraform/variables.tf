variable "resource_group" {
  default = "devops-rg"
}

variable "location" {
  default = "East US"
}

variable "admin_username" {
  default = "azureuser"
}

variable "ssh_public_key" {
  default = "/var/jenkins_home/.ssh/id_rsa.pub"
}
