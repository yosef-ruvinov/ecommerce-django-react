terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.57.0"
    }
  }
}

provider "aws" {
  region = "il-central-1"  
}

resource "aws_security_group" "ec2_sg" {
    name        = "ec2-sg"
    description = "Security group for EC2 instances"

    ingress {
      from_port   = 22 
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  
    }

    ingress {
      from_port   = 8080  
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  
    }
    
    ingress {
      from_port   = 3306  
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1" 
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "Instance Security Group"
    }
  }

# Jenkins Instance
resource "aws_instance" "jenkins" {
  ami                   = "ami-0de6215d9c2342df5" # Ubuntu 22.04 LTS AMI ID
  instance_type         = "t3.micro"
  key_name              = "terraform_keyPair"
  security_groups       = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "Jenkins"
  }

  root_block_device {
    volume_size = 30
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 30
    delete_on_termination = true
    tags = {
      Name = "AdditionalVolume"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y openjdk-17-jdk
              sudo apt install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              sudo apt install -y git
              sudo apt install -y awscli
              sudo apt install -y mysql-client
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
              /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
              https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
              /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              EOF
              
}

# Ubuntu Instance
resource "aws_instance" "my_ubuntu" {
  ami                   = "ami-0de6215d9c2342df5" # Ubuntu 22.04 LTS AMI ID
  instance_type         = "t3.micro"          
  key_name              = "terraform_keyPair"
  security_groups       = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "My-Ubuntu"
  }

  root_block_device {
    volume_size = 30
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 30
    delete_on_termination = true
    tags = {
      Name = "AdditionalVolume"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y awscli
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo apt install -y openjdk-11-jdk
              sudo apt install -y python3 python3-pip
              sudo apt install -y mysql-client
              EOF
}

# Windows Instance
resource "aws_instance" "my_windows" {
  ami                   = "ami-07df29cf3e326c3ad" # Windows 10 AMI ID
  instance_type         = "t3.micro"
  key_name              = "terraform_keyPair"
  security_groups       = [aws_security_group.ec2_sg.name]
  

  tags = {
    Name = "My-Windows"
  }

  root_block_device {
    volume_size = 30
  }

  ebs_block_device {
    device_name           = "xvdf"
    volume_size           = 30
    delete_on_termination = true
    tags = {
      Name = "AdditionalVolume"
    }
  }

  user_data = <<-EOF
              <powershell>
              Install-WindowsFeature -Name Web-Server -IncludeManagementTools
              Invoke-WebRequest -Uri "https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.zip" -OutFile "C:\\jdk-17_windows-x64_bin.zip"
              Expand-Archive -Path "C:\\jdk-17_windows-x64_bin.zip" -DestinationPath "C:\\Program Files\\Java\\"
              Remove-Item -Path "C:\\jdk-17_windows-x64_bin.zip" -Force
              [Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\\Program Files\\Java\\jdk-17", "Machine")
              Invoke-WebRequest -Uri "https://get.jenkins.io/war-stable/2.319.2/jenkins.war" -OutFile "C:\\jenkins.war"
              Start-Service -Name wuauserv
              Set-Service -Name wuauserv -StartupType 'Automatic'
              Start-Service -Name Jenkins
              Set-Service -Name Jenkins -StartupType 'Automatic'
              </powershell>
              EOF
}