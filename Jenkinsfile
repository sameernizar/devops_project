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
