#create a VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "kubernetes_vpc"
  cidr = "10.0.0.0/16"

  azs             = var.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


resource "aws_launch_configuration" "kubernetes" {
  name_prefix                 = "kubernetes-terraform-aws-asg-"
  image_id                    = "ami-096c86b99bfee4865"
  instance_type               = "t2.large"
  security_groups             = [aws_security_group.kubernetes_instance.id]
  key_name                    = "ec2-key"
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kubernetes" {
  name                 = "k8s_asg"
  min_size             = 2
  max_size             = 7
  desired_capacity     = 3
  launch_configuration = aws_launch_configuration.kubernetes.name
  vpc_zone_identifier  = module.vpc.public_subnets

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "K8s_nodes"
    propagate_at_launch = true
  }
}

resource "aws_lb" "kubernetes" {
  name               = "learn-asg-kubernetes-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.kubernetes_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "kubernetes" {
  load_balancer_arn = aws_lb.kubernetes.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubernetes.arn
  }
}

resource "aws_lb_target_group" "kubernetes" {
  name     = "learn-asg-kubernetes"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}


resource "aws_autoscaling_attachment" "kubernetes" {
  autoscaling_group_name = aws_autoscaling_group.kubernetes.id
  lb_target_group_arn    = aws_lb_target_group.kubernetes.arn
}

resource "aws_security_group" "kubernetes_instance" {
  name = "learn-asg-kubernetes-instance"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.kubernetes_lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "kubernetes_lb" {
  name = "learn-asg-kubernetes-lb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id
}
