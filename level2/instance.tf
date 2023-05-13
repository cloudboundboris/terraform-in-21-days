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


resource "aws_instance" "public" {

  ami                         = data.aws_ami.amazonlinux.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "mainkeypair"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet_id[1]
  user_data                   = file("user-data.sh")
  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "private" {

  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t2.micro"
  key_name               = "mainkeypair"
  vpc_security_group_ids = [aws_security_group.private.id]
  subnet_id              = data.terraform_remote_state.level1.outputs.private_subnet_id[1]
  tags = {
    Name = "${var.env_code}-private"
  }
}

resource "aws_security_group" "public" {
  name        = "${var.env_code}-publicSG"
  description = "Allow SSH traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from Public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.mypublicip]
  }
  ingress {
    description = "HTTP from public"
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
    Name = "${var.env_code}-publicSG"
  }
}

resource "aws_security_group" "private" {
  name        = "${var.env_code}-privateSG"
  description = "Allow SSH from VPC"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.level1.outputs.vpc_cidr] #Using datasource "Pulling from level1" 
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
