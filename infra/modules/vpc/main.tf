resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-project-vpc"
  }
}

#Public Subnets
resource "aws_subnet" "public-1" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name                                        = "public-1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name                                        = "public-2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

#Private Subnets
resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name                                        = "private-1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                    = "1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name                                        = "private-2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                    = "1"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks.id

  tags = {
    Name = "igw"
  }
}

#Elastic IP
resource "aws_eip" "eip_eks" {
  domain = "vpc"

  tags = {
    Name = "eip_eks"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_eks.id
  subnet_id     = aws_subnet.public-1.id

    tags = {
    Name = "nat_gw"
  }
}

#Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

#Private Route Table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-rt"
  }
}

#Public Route Table Association 1
resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public-route-table.id
}

#Public Route Table Association 2
resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public-route-table.id
}

#Private Route Table Association 1
resource "aws_route_table_association" "private-1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private-route-table.id
}

#Private Route Table Association 2
resource "aws_route_table_association" "private-2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.private-route-table.id
}