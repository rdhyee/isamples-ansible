data "aws_vpc" "default_vpc" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "isamples"
}

resource "aws_subnet" "oc_subnet" {
  cidr_block        = "172.31.96.0/20"
  vpc_id            = data.aws_vpc.default_vpc.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "oc-subnet"
  }
}

resource "aws_network_interface" "oc_interface" {
  subnet_id = aws_subnet.oc_subnet.id

  tags = {
    Name = "oc-interface"
  }
}

resource "aws_security_group" "oc_security_group" {
  name_prefix = "oc-security-group"
  vpc_id      = data.aws_vpc.default_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "oc-security-group"
  }
}

resource "aws_eip" "oc_eip" {
  vpc      = true
  instance = aws_instance.oc_instance.id
  # associate_with_private_ip = aws_network_interface.oc_interface.private_ip
  tags = {
    Name = "opencontext-eip-1"
  }
}

resource "aws_instance" "oc_instance" {
  ami                    = "ami-0557a15b87f6559cf"
  instance_type          = "c5d.xlarge"
  key_name               = "opencontext-2023.02.16"
  vpc_security_group_ids = [aws_security_group.oc_security_group.id]
  subnet_id              = aws_subnet.oc_subnet.id

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 100
  }

  tags = {
    Name = "opencontext-isbox"
  }
}
