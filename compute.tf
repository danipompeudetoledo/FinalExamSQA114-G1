#############################################
# Compute Instances - Jenkins & Production
#############################################

# Usa o par de chaves existente (não cria outro)
data "aws_key_pair" "existing_key" {
  key_name = "devops-key"
}

# Security Group para Jenkins e EC2s
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH, HTTP, and Jenkins"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
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
    Name = "jenkins-sg"
  }
}

#############################################
# Jenkins Controller
#############################################
resource "aws_instance" "jenkins_controller" {
  ami                    = "ami-08c40ec9ead489470" # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.existing_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.subnet_a.id

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y openjdk-17-jdk
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              apt update -y
              apt install -y jenkins
              systemctl enable jenkins
              systemctl start jenkins
              EOF

  tags = {
    Name = "Jenkins-Controller"
  }
}

#############################################
# Jenkins Agent
#############################################
resource "aws_instance" "jenkins_agent" {
  ami                    = "ami-08c40ec9ead489470"
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.existing_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.subnet_b.id

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y openjdk-17-jdk
              EOF

  tags = {
    Name = "Jenkins-Agent"
  }
}

#############################################
# Production Environment 1
#############################################
resource "aws_instance" "production_env1" {
  ami                    = "ami-08c40ec9ead489470"
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.existing_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.subnet_a.id

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              echo "<h1>Production Env 1 - OK ✅</h1>" > /var/www/html/index.html
              systemctl enable apache2
              systemctl start apache2
              EOF

  tags = {
    Name = "Production_Env1"
  }
}

#############################################
# Production Environment 2
#############################################
resource "aws_instance" "production_env2" {
  ami                    = "ami-08c40ec9ead489470"
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.existing_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.subnet_b.id

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              echo "<h1>Production Env 2 - OK ✅</h1>" > /var/www/html/index.html
              systemctl enable apache2
              systemctl start apache2
              EOF

  tags = {
    Name = "Production_Env2"
  }
}

#############################################
# Outputs
#############################################
output "jenkins_controller_public_ip" {
  value = aws_instance.jenkins_controller.public_ip
}

output "jenkins_agent_public_ip" {
  value = aws_instance.jenkins_agent.public_ip
}

output "production_env1_public_ip" {
  value = aws_instance.production_env1.public_ip
}

output "production_env2_public_ip" {
  value = aws_instance.production_env2.public_ip
}

