terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }
}

provider "aws" {
  region  = "il-central-1"
  profile = "terraform-user"
}

resource "aws_security_group" "ec2_sg" {
  name        = "security group using Terraform"
  description = "security group using Terraform"

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 3306
    to_port          = 3306
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
    Name = "ec2_sg"
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0de6215d9c2342df5" # Ubuntu 22.04 LTS AMI ID
  instance_type = "t3.micro"
  key_name      = "terraform_keyPair"
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "Jenkins"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y openjdk-17-jdk git
                curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
                echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
                sudo apt-get update
                sudo apt-get install -y jenkins
                sudo systemctl start jenkins
                sudo systemctl enable jenkins
                sleep 30
                sudo chmod +r /var/lib/jenkins/secrets/initialAdminPassword
                EOF
  }

resource "aws_instance" "my_ubuntu" {
  ami           = "ami-0de6215d9c2342df5" # Ubuntu 22.04 LTS AMI ID
  instance_type = "t3.micro"
  key_name      = "terraform_keyPair"
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "My Ubuntu"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y openjdk-17-jdk
              sudo apt install -y git
              sudo apt-get install -y docker.io
              sudo usermod -aG docker ubuntu
              EOF
}

resource "aws_instance" "my_windows" {
  ami           = "ami-07df29cf3e326c3ad" # Windows 10 AMI ID
  instance_type = "t3.micro"
  key_name      = "terraform_keyPair"
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "My Windows"
  }

  user_data = <<-EOF
              <powershell>
              Install-WindowsFeature -Name Containers
              Invoke-WebRequest -Uri https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe -OutFile DockerDesktopInstaller.exe
              Start-Process -FilePath DockerDesktopInstaller.exe -ArgumentList "/quiet" -Wait
              Invoke-WebRequest -Uri https://download.java.net/java/GA/jdk17/GPL/openjdk-17_windows-x64_bin.zip -OutFile openjdk-17_windows-x64_bin.zip
              Expand-Archive openjdk-17_windows-x64_bin.zip -DestinationPath C:\\Java
              setx /M JAVA_HOME C:\\Java\\jdk-17
              setx /M PATH "%PATH%;C:\\Java\\jdk-17\\bin"
              </powershell>
              EOF
}
