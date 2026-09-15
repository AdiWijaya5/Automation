#SOURCES: AMI UBUNTU 24.04  

data "aws_ami" "ubuntu_24" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#DEBIAN 11

data "aws_ami" "debian_11" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#SETUP VPC & SUBNE

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { 
    Name = "VPC-Terraform" 
    }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { 
    Name = "IGW-Terraform" 
    }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = { 
    Name = "Subnet-Public" 
    }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { 
    Name = "RouteTable-Public" 
    }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Firewall (SECURITY GROUP) - Allow All (0.0.0.0/0) - SSH/HTTP/HTTPS

resource "aws_security_group" "allow_all_sg" {
  name        = "allow_all_sg"
  description = "Izinkan semua akses masuk dan keluar (0.0.0.0/0)"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow All Inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

# SERVER 1: UBUNTU 24.04 + BLOCK STORAGE 15GB

resource "aws_instance" "ubuntu_server" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all_sg.id]
  key_name               = "adi-key"

# MENERAPKAN IMDSv2 REQUIRED

  metadata_options {
    http_tokens   = "required" 
    http_endpoint = "enabled"
  }

  tags = { Name = "Server-Ubuntu-24" }
}

resource "aws_ebs_volume" "storage_ubuntu" {
  availability_zone = aws_instance.ubuntu_server.availability_zone
  size              = 15
  tags              = { 
    Name = "Volume-Ubuntu-Disk" 
    }
}

resource "aws_volume_attachment" "attach_ubuntu" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.storage_ubuntu.id
  instance_id = aws_instance.ubuntu_server.id
}

#SERVER 2: DEBIAN 11 + BLOCK STORAGE 15GB

resource "aws_instance" "debian_server" {
  ami                    = data.aws_ami.debian_11.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all_sg.id]
  key_name               = "adi-key"

# MENERAPKAN IMDSv2 REQUIRED

  metadata_options {
    http_tokens   = "required" 
    http_endpoint = "enabled"
  }

  tags = { Name = "Server-Debian-11" }
}

resource "aws_ebs_volume" "storage_debian" {
  availability_zone = aws_instance.debian_server.availability_zone
  size              = 15 
  tags              = { 
    Name = "Volume-Debian-Disk" 
    }
}

resource "aws_volume_attachment" "attach_debian" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.storage_debian.id
  instance_id = aws_instance.debian_server.id
}

# STATIC IP (ELASTIC IP)

resource "aws_eip" "eip_ubuntu" {
  instance   = aws_instance.ubuntu_server.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { 
    Name = "EIP-Ubuntu" 
    }
}

resource "aws_eip" "eip_debian" {
  instance   = aws_instance.debian_server.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { 
    Name = "EIP-Debian" 
    }
}

#OUTPUTS IP

output "ubuntu_static_ip" {
  value       = aws_eip.eip_ubuntu.public_ip
  description = "IP Publik Static untuk Ubuntu Server (Singapura)"
}

output "debian_static_ip" {
  value       = aws_eip.eip_debian.public_ip
  description = "IP Publik Static untuk Debian Server (Singapura)"
}