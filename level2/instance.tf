locals {
  mypublicip = sensitive(file("~/.ssh/mypubip.txt"))
}

data "aws_ami" "amazonlinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_security_group" "private" {
  name        = "${var.env_code}-privateSG"
  description = "Allow SSH from VPC"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

 
  ingress {
    description     = "HTTP from LB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.env_code}-privateSG"
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix     = "${var.env_code}-LaunchConfig"
  image_id        = data.aws_ami.amazonlinux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.private.id]
  user_data       = file("user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.main.name
}

resource "aws_autoscaling_group" "main" {
  name             = "${var.env_code}-ASG"
  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  target_group_arns    = [aws_lb_target_group.main.arn]
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = data.terraform_remote_state.level1.outputs.private_subnet_id

  tag {
    key                 = "Name"
    value               = "${var.env_code}-ASG"
    propagate_at_launch = true
  }
}
