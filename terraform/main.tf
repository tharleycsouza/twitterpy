provider "aws" {
  region = "sa-east-1"
  shared_credentials_file = "/home/tharley/.aws/credentials"
  profile = "awsterraform"
  version = "~> 2.31.0"
}

#allows access to the list of AWS Availability

data "aws_availability_zones" "all" {
  state = "available"
}
data "aws_vpc" "default"{
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

#VARIABLES
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
variable "lb_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}
variable "asg_min" {
  description = "Min number of instances"
  type        = number
  default     = 2
}
variable "asg_max" {
  description = "Max number of instances"
  type        = number
  default     = 10
}

#LOAD BALANCER
resource "aws_lb" "twitterpy" {
  name               = "twitterpy-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnet_ids.default.ids

  enable_deletion_protection = true

    tags = {
    Environment = "production"
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.twitterpy.arn
  port = var.lb_port
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response{
      content_type =  "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}
resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-twitterpy"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    field = "path-pattern"
    values = ["*"]
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

#EC2
resource "aws_launch_configuration" "twitterpy" {
  name_prefix   = "twitterpy"
  image_id      = "ami-05494b93950efa2fd"
  instance_type = "t2.micro"
  key_name = "deployer-key"
  security_groups = [aws_security_group.instance.id, aws_security_group.ssh.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "twitterpy"
  }

}
resource "aws_autoscaling_group" "twitterpy" {
  launch_configuration = aws_launch_configuration.twitterpy.id
  availability_zones   = data.aws_availability_zones.all.names
  min_size = var.asg_min
  max_size = var.asg_max
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-twitterpy"
    propagate_at_launch = true
  }
}
#SECURITY


resource "aws_security_group" "instance" {
  name = "http_node"  
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ssh" {
  name = "ssh"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpCbkRakcTGVeREcZSH/fHROMlemUJyZ+oHRAhfjBMDFErmq/jyhROvWtD7yOX7TFL3qqPK66K+D0/08T2xNw7ZFNGY76Ceh1RX22bhpv9Lp3M75nsh0XYK0FxfFfhARLiZtGNIFiziPqt1lOuy9yIV/KSduf5LmpiGs+B2X3DEGhGg4C7bvAZjLiW9rIp0tAaoXA2NzAPZbaK8DMA+oKRPgmwC6ZX/b/sgJy4HJcMoC2k9egf3nkM5ROjHf4n1OEE4xIuVDOVkBbKTSGJHojAUocldGji3XQBAz6KjzBqXSYDCnQPn+h5fDcTvYj2doLr8z1voV92jFqSLAVCZk9B89FZ2JNzHLguM5W+hcD7bUAO0OOxS+DIgnzJkeyMY0wh9Pot0GMAoZZVmH9Knwyof016dAMMSEFuvPj3I11/Gk3JVUdR57E5eHfskwheRupZtEA71FKml9R4zIrEXCe1Lm13KqN/+gjoKECEbdscrXHGL2e/9cnBo0OD8QkxiYc= eduardo@Eduardos-MBP"
}

resource "aws_security_group" "alb" {
  name = "http_lb"  
  ingress {
    from_port   = var.lb_port
    to_port     = var.lb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#OUTPUTS
output "alb_dns_name" {
  value = aws_lb.twitterpy.dns_name
  description = "Domain name"
}

resource "aws_iam_role" "EC2InstanceRole1" {
  name = "EC2InstanceRole1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "prod"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "twitterpy-cluster-rds-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.r4.large"
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
}

resource "aws_rds_cluster" "default" {
  cluster_identifier = "twitterpy-cluster-rds"
  #availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  database_name      = var.name
  master_username    = var.username
  master_password    = var.password
  #snapshot_identifier = "twitterpy"
  skip_final_snapshot = false
}

resource "aws_codedeploy_deployment_config" "twitterpy" {
  deployment_config_name = "twitterpy-deployment-config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 2
  }
}

resource "aws_codedeploy_deployment_group" "twitterpy" {
  app_name               = aws_codedeploy_app.twitterpy.name
  deployment_group_name  = "twitterpy"
  service_role_arn       = aws_iam_role.foo_role.arn
  deployment_config_name = aws_codedeploy_deployment_config.foo.id

  ec2_tag_filter {
    key   = "Name"
    value = "twitterpy"
  }

}