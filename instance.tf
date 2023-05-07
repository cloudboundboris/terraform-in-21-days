locals {
  mypublicip = sensitive(file("~/.ssh/mypubip.txt"))
}
resource "aws_instance" "public" {

  ami                         = "ami-0889a44b331db0194"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "mainkeypair"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.public[0].id 

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "private" {

  ami                         = "ami-0889a44b331db0194"
  instance_type               = "t2.micro"
  key_name                    = "mainkeypair"
  vpc_security_group_ids      = [aws_security_group.private.id]
  subnet_id                   = aws_subnet.private[0].id 

  tags = {
    Name = "${var.env_code}-private"
  }
}

  resource "aws_security_group" "public" {
    name        = "${var.env_code}-publicSG"
    description = "Allow SSH traffic"
    vpc_id      = aws_vpc.main.id

    ingress {
      description = "SSH from Public"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [local.mypublicip]
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
    vpc_id      = aws_vpc.main.id

    ingress {
      description = "SSH from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
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
