provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "garmin-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "garmin-igw"
    }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "garmin-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "garmin-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ----------------------
# Security Group
# ----------------------
resource "aws_security_group" "allow_ssh" {
  name        = "garmin-dev-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "garmin-ssh-sg"
  }
}

resource "aws_security_group" "allow_ui" {
  name        = "garmin-ui-sg"
  description = "Allow access to Garmin Web UI"
  vpc_id      = aws_vpc.main.id

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
    Name = "garmin-ui-sg"
  }
}

resource "aws_security_group" "allow_data_api" {
  name        = "garmin-data-api-sg"
  description = "Allow access to Garmin Data API"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "garmin-data-sg"
  }
}

resource "aws_security_group" "allow_auth_api" {
  name        = "garmin-auth-api-sg"
  description = "Allow access to Garmin Auth API"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    Name = "garmin-auth-sg"
  }
}

resource "aws_instance" "garmin_ui" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_ui.id
  ]

  tags = {
    Name = "garmin-ui"
  }
}


resource "aws_instance" "garmin_data_api" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_data_api.id
  ]

  tags = {
    Name = "garmin-data-api"
  }
}

resource "aws_instance" "garmin_auth_api" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_auth_api.id
  ]

  tags = {
    Name = "garmin-auth-api"
  }
}

data "aws_availability_zones" "available" {}


output "garmin_ui_puclic_ip" {
  description = "Public IP of the Garmin Web UI instance"
  value = aws_instance.garmin_ui.public_ip
}

output "garmin_data_api_public_ip" {
  description = "Public IP of the Garmin Data API instance"
  value = aws_instance.garmin_data_api.public_ip
}

output "garmin_auth_api_public_ip" {
  description = "Public IP of the Garmin Auth API instance"
  value = aws_instance.garmin_auth_api.public_ip
}