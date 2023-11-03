provider "aws" {
  region = "eu-central-1" # Channge to your region
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web instances"
  vpc_id      = "vpc-0084498af17c05d93" #Change to your VPC
  dynamic "ingress" {
    for_each = ["80", "443", "22", "3000"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "Web Security Group"
  }
}

resource "aws_launch_configuration" "web_lc" {
  name_prefix                 = "web-lc-"
  image_id                    = "ami-06dd92ecc74fdfb36"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.web_sg.id]
  key_name                    = "devops" #Change to your SSH keys
  user_data                   = file("web.sh")
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb_http" {
  name        = "elb_http"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id      = "vpc-0084498af17c05d93" # Change to your VPC
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
  tags = {
    Name = "Allow HTTP"
  }
}

resource "aws_elb" "web_elb" {
  name                      = "web-elb"
  security_groups           = [aws_security_group.elb_http.id]
  subnets                   = ["subnet-01a7cb83d7600f1a6", "subnet-0332119d04ab8f98c"] #Change to your Subnets(Must be in two diferent Availabiliity Zones)
  cross_zone_load_balancing = true
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }
}

resource "aws_autoscaling_group" "web" {
  name             = "${aws_launch_configuration.web_lc.name}-asg"
  min_size         = 1
  desired_capacity = 2
  max_size         = 4

  health_check_type    = "ELB"
  load_balancers       = [aws_elb.web_elb.id]
  launch_configuration = aws_launch_configuration.web_lc.name
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"
  vpc_zone_identifier = ["subnet-01a7cb83d7600f1a6", "subnet-082dac0812322802f"] #Change to your Subnets
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}

output "web_loadbalancer_url" {
  value = aws_elb.web_elb.dns_name
}


# resource "aws_lb" "web_elb" {
#   name                       = "web-elb"
#   internal                   = false
#   load_balancer_type         = "application"
#   subnets                    = ["subnet-01a7cb83d7600f1a6", "subnet-0332119d04ab8f98c"]
#   enable_deletion_protection = false
#   enable_http2               = true
#   idle_timeout               = 60
# }


# resource "aws_autoscaling_group" "web_asg" {
#   name_prefix          = "web-asg-"
#   launch_configuration = aws_launch_configuration.web_lc.name
#   vpc_zone_identifier  = ["subnet-01a7cb83d7600f1a6", "subnet-082dac0812322802f"]
#   min_size             = 1
#   max_size             = 3
#   health_check_type    = "ELB"
#   target_group_arns    = [aws_lb_target_group.MyWPInstancesTG.arn]
# }



# resource "aws_lb_target_group" "web_target_group" {
#   name_prefix = "tg-"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = "vpc-0084498af17c05d93"
#   target_type = "instance"
#   health_check {
#     interval            = 30
#     path                = "/"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     timeout             = 10
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_listener" "web_listener" {
#   load_balancer_arn = aws_lb.web_elb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web_target_group.arn
#   }
# }

# resource "aws_autoscaling_attachment" "web_attach" {
#   autoscaling_group_name = aws_autoscaling_group.web_asg.name
#   alb_target_group_arn   = aws_lb_target_group.web_target_group.arn
# }




