provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.10.0.0/16"
}

========================================

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    "my-igw" = "my-igw"
  }
}

=======================================

resource "aws_subnet" "pub-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.10.1.0/24"
  tags = {
    "pub-subnet" = "pub-subnet"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    "pub-rt" = "pub-rt"
  }
}

resource "aws_route_table_association" "pub-association" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_subnet" "pvt-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.10.2.0/24"
  tags = {
    "pvt-subnet" = "pvt-subnet"
  }
}

resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    "pvt-rt" = "pvt-rt"
  }
}

resource "aws_route_table_association" "pvt-association" {
  subnet_id      = aws_subnet.pvt-subnet.id
  route_table_id = aws_route_table.pvt-rt.id
}

resource "aws_eip" "eip" {
  vpc = "true"
  depends_on = [
    aws_internet_gateway.my-igw
  ]
}

resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pvt-subnet.id
  tags = {
    "my-nat" = "my-nat"
  }
}
