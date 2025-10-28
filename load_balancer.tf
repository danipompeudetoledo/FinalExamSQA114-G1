#############################################
# Load Balancer for Production Environments
#############################################

resource "aws_elb" "prod_elb" {
  name               = "prod-load-balancer"
  security_groups    = [aws_security_group.jenkins_sg.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  cross_zone_load_balancing = true

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  # Instâncias ligadas ao mesmo VPC das subnets públicas
  instances = [
    aws_instance.production_env1.id,
    aws_instance.production_env2.id
  ]

  tags = {
    Name = "prod-load-balancer"
  }
}

#############################################
# Output do Load Balancer
#############################################

output "load_balancer_dns" {
  value = aws_elb.prod_elb.dns_name
}

