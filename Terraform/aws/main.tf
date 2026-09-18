#-----------------------------------
# VPC 
#-----------------------------------

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "VPC-Terraform" }
}

#-----------------------------------
# GATEWAY 
#-----------------------------------

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "IGW-Terraform" }
}

#-----------------------------------
# SUBNET 
#-----------------------------------

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = { Name = "Subnet-Public" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "RouteTable-Public" }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

#-----------------------------------
# SERVER 1: UBUNTU 24.04 
#-----------------------------------

resource "aws_security_group" "allow_all_sg" {
  name        = "allow_all_sg"
  description = "Izinkan semua akses masuk dan keluar (0.0.0.0/0)"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow TCP Inbound from port 1 to 10000"
    from_port   = 1
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow All Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG-Allow-All" }

}

#-----------------------------------
# SERVER 1: UBUNTU 24.04 
#-----------------------------------

resource "aws_instance" "ubuntu_server" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all_sg.id]
  key_name               = var.key_name

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = { Name = "Server-Ubuntu-24" }
}

#-----------------------------------
# EBS - TERRAFORM UBUNTU
#-----------------------------------

resource "aws_ebs_volume" "storage_ubuntu" {
  availability_zone = aws_instance.ubuntu_server.availability_zone
  size              = 15
  tags              = { Name = "Volume-Ubuntu-Disk" }
}

resource "aws_volume_attachment" "attach_ubuntu" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.storage_ubuntu.id
  instance_id = aws_instance.ubuntu_server.id
}

resource "aws_eip" "eip_ubuntu" {
  instance   = aws_instance.ubuntu_server.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { Name = "EIP-Ubuntu" }
}

#-----------------------------------
# --- SERVER 2: DEBIAN 11 ----------
#-----------------------------------

resource "aws_instance" "debian_server" {
  ami                    = data.aws_ami.debian_11.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all_sg.id]
  key_name               = var.key_name

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = { Name = "Server-Debian-11" }
}

#-----------------------------------
# EBS - TERRAFORM DEBIAN
#-----------------------------------

resource "aws_ebs_volume" "storage_debian" {
  availability_zone = aws_instance.debian_server.availability_zone
  size              = 15
  tags              = { Name = "Volume-Debian-Disk" }
}

resource "aws_volume_attachment" "attach_debian" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.storage_debian.id
  instance_id = aws_instance.debian_server.id
}

#-----------------------------------
# ELASTIC IP - DEBIAN
#-----------------------------------

resource "aws_eip" "eip_debian" {
  instance   = aws_instance.debian_server.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { Name = "EIP-Debian" }
}

#-----------------------------------
# --- SERVER 3: ANSIBLE UBUNTU 1 ---
#-----------------------------------

resource "aws_instance" "ubuntu_ansible_1" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all_sg.id]
  key_name               = var.key_name

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tags = { 
    Name = "Server-Ansible-Ubuntu-1" 
    OS   = "Ubuntu 24.04"
    }
}

#-----------------------------------
# EBS - ANSIBLE UBUNTU 2
#-----------------------------------

resource "aws_ebs_volume" "storage_ubuntu_1" {
  availability_zone = aws_instance.ubuntu_ansible_1.availability_zone
  size              = 10
  tags              = { Name = "Volume-Ubuntu-Disk-1" }
}

resource "aws_volume_attachment" "attach_ubuntu_1" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.storage_ubuntu_1.id
  instance_id = aws_instance.ubuntu_ansible_1.id
}

#-----------------------------------
# ELASTIC IP - ANSIBLE UBUNTU 1
#-----------------------------------

resource "aws_eip" "eip_ubuntu_ansible_1" {
  instance   = aws_instance.ubuntu_ansible_1.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { Name = "EIP-Ansible-1" }
}

#-----------------------------------
# --- SERVER 4: ANSIBLE UBUNTU 2 ---
#-----------------------------------

resource "aws_instance" "ubuntu_ansible_2" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = var.instance_type

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all_sg.id]
  key_name               = var.key_name

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tags = { 
    Name = "Server-Ansible-Ubuntu-2"
    OS   = "Ubuntu 24.04"
    }
}

#-----------------------------------
# EBS - ANSIBLE UBUNTU 2
#-----------------------------------

resource "aws_ebs_volume" "storage_ubuntu_2" {
  availability_zone = aws_instance.ubuntu_ansible_2.availability_zone
  size              = 10

  tags              = { 
    Name = "Volume-Ubuntu-Disk_2" 
    }
}

resource "aws_volume_attachment" "attach_ubuntu_2" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.storage_ubuntu_2.id
  instance_id = aws_instance.ubuntu_ansible_2.id
}

#-----------------------------------
# ELASTIC IP - ANSIBLE UBUNTU 2
#-----------------------------------

resource "aws_eip" "eip_ubuntu_ansible_2" {
  instance   = aws_instance.ubuntu_ansible_2.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { Name = "EIP-Ansible-2" }
}