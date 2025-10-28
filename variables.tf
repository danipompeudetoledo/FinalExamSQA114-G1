variable "region"         { default = "us-east-1" }
variable "vpc_cidr"       { default = "10.0.0.0/16" }
variable "public_subnet1" { default = "10.0.1.0/24" }
variable "public_subnet2" { default = "10.0.2.0/24" }
variable "key_name"       { default = "devops-key" }
variable "sg_name"        { default = "jenkins-sg" }
variable "tic_repo_raw"   { default = "https://raw.githubusercontent.com/eduval/FinalExamSQA114-G1/main" }

