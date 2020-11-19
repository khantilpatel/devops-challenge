resource "aws_key_pair" "app_key" {
  key_name   = "app-key-pair"
  public_key = file(var.public_key)
}

data "aws_availability_zones" "all" {}

### Launch Security Group for EC2
resource "aws_security_group" "web" {
  name = "web"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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

data "aws_iam_instance_profile" "profile" {
  name = "php-app_profile"
}

## Launch Configuration
resource "aws_launch_configuration" "web" {
  image_id               = var.ami_id
  instance_type          = "t2.micro"
  iam_instance_profile   = data.aws_iam_instance_profile.profile.name
  security_groups        = [aws_security_group.web.id]
  key_name               = aws_key_pair.app_key.key_name
  user_data              = file("launch-app-script.sh")
  lifecycle {
    create_before_destroy = true
  }
}

## Launch AutoScaling Group with ability to do rolling updates
resource "aws_autoscaling_group" "web" {
  name = "${var.app_name} - ${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  availability_zones = data.aws_availability_zones.all.names
  min_size = 1
  max_size = 3
  desired_capacity = 2
  min_elb_capacity = 1
  load_balancers = [aws_elb.web.name]
  health_check_type = "ELB"
  health_check_grace_period = 300
  tag {
    key = "Name"
    value = "web-app"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

## Security Group for ELB
resource "aws_security_group" "web-elb" {
  name = "web-elb"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Launch ELB
resource "aws_elb" "web" {
  name = "web-elb"
  security_groups = [aws_security_group.web-elb.id]
  availability_zones = data.aws_availability_zones.all.names
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/version.txt"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}