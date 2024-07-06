terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }
}

# The cloud provider
provider "aws" {
  region  = "il-central-1"
  profile = "terraform-user"
}

# Security group for SSH access
resource "aws_security_group" "tf_sg" {
  name        = "security group using Terraform"
  description = "security group using Terraform"
  vpc_id      = "vpc-084e88412d2a7d37e"

  ingress {
    description      = "SSH"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }  

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tf_sg"
  }
}

# Jenkins instance - Master with installed: Ubuntu 22.04, Jenkins, Java, GIT
resource "aws_instance" "jenkins" {
  ami             = "ami-0de6215d9c2342df5" # Ubuntu 22.04 LTS AMI ID
  instance_type   = "t3.micro"
  key_name        = "terraform-keypair"
  security_groups = ["aws_security_group.tf_sg"]

  tags = {
    Name = "Jenkins"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y openjdk-11-jdk
              sudo apt install -y git
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt update
              sudo apt install -y jenkins
              sudo systemctl start jenkins
              EOF
}

# My Ubuntu instance - SLave with installed: Ubuntu 22.04, Java, Docker
resource "aws_instance" "my_ubuntu" {
  ami             = "ami-0de6215d9c2342df5" # Ubuntu 22.04 LTS AMI ID
  instance_type   = "t3.micro"
  key_name        = "terraform-keypair"
  security_groups = ["aws_security_group.tf_sg"]

  tags = {
    Name = "My Ubuntu"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y openjdk-11-jdk
              sudo apt install -y docker.io
              sudo usermod -aG docker ubuntu
              EOF
}

# My Windows instance - Slave with installed: Win10, Docker, Java
resource "aws_instance" "my_windows" {
  ami             = "ami-07df29cf3e326c3ad" # Windows 10 AMI ID
  instance_type   = "t3.micro"
  key_name        = "terraform-keypair"
  security_groups = ["aws_security_group.tf_sg"]

  tags = {
    Name = "My Windows"
  }

  user_data = <<-EOF
              <powershell>
              Install-WindowsFeature -Name Containers
              Invoke-WebRequest -Uri https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe -OutFile DockerDesktopInstaller.exe
              Start-Process -FilePath DockerDesktopInstaller.exe -ArgumentList "/quiet" -Wait
              Invoke-WebRequest -Uri https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.2_windows-x64_bin.zip -OutFile openjdk-11.0.2_windows-x64_bin.zip
              Expand-Archive openjdk-11.0.2_windows-x64_bin.zip -DestinationPath C:\\Java
              setx /M JAVA_HOME C:\\Java\\jdk-11.0.2
              setx /M PATH "%PATH%;C:\\Java\\jdk-11.0.2\\bin"
              </powershell>
              EOF
}