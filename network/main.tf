###---network/main.tf---

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "cicd_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cicd-vpc-${random_integer.random.id}"
  }
}

resource "aws_subnet" "cicd_public_subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.cicd_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = ["us-east-2a", "us-east-2b", "us-east-2c"][count.index]

  tags = {
    Name = "cicd-public_${count.index + 1}"
  }
}

resource "aws_route_table_association" "cicd_public_assoc" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.cicd_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.cicd_public_rt.id
}

resource "aws_subnet" "cicd_private_subnet" {
  count             = length(var.private_cidrs)
  vpc_id            = aws_vpc.cicd_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = ["us-east-2a", "us-east-2b", "us-east-2c"][count.index]

  tags = {
    Name = "cicd-private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "cicd_private_assoc" {
  count          = length(var.private_cidrs)
  subnet_id      = aws_subnet.cicd_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.cicd_private_rt.id
}

resource "aws_internet_gateway" "cicd_internet_gateway" {
  vpc_id = aws_vpc.cicd_vpc.id

  tags = {
    Name = "cicd-igw"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "project_eip" {

}

resource "aws_nat_gateway" "cicd_natgateway" {
  allocation_id = aws_eip.project_eip.id
  subnet_id     = aws_subnet.cicd_public_subnet[1].id
}

resource "aws_route_table" "cicd_public_rt" {
  vpc_id = aws_vpc.cicd_vpc.id

  tags = {
    Name = "cicd-public-rt"
  }
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.cicd_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cicd_internet_gateway.id
}

resource "aws_route_table" "cicd_private_rt" {
  vpc_id = aws_vpc.cicd_vpc.id

  tags = {
    Name = "cicd-private-rt"
  }
}

resource "aws_route" "default_private_route" {
  route_table_id         = aws_route_table.cicd_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.cicd_natgateway.id
}

resource "aws_default_route_table" "project_private_rt" {
  default_route_table_id = aws_vpc.cicd_vpc.default_route_table_id

  tags = {
    Name = "cicd-private-rt"
  }
}

resource "aws_security_group" "cicd_public_sg" {
  name        = "cicd_bastion_sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.cicd_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cicd_private_sg" {
  name        = "cicd_webserver_sg"
  description = "Allow SSH inbound traffic from Bastion Host"
  vpc_id      = aws_vpc.cicd_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.cicd_public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.cicd_web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "cicd_web_sg" {
  name        = "cicd_web_sg"
  description = "Allow all inbound HTTP traffic"
  vpc_id      = aws_vpc.cicd_vpc.id

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
}