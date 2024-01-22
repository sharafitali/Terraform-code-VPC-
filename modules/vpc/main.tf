# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {

  count             = length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "sharafit-VPC-Internetgateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# ...

resource "aws_route_table" "private_rt" {
  count  = length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : 0
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = aws_nat_gateway.nat_gateway
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = route.value.id # Use route.value.id instead of route.value.allocation_id
    }
  }

  tags = {
    Name = "Private-Route-Table"
  }
}



resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : 0
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.internet-gw]
}

resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.private_subnet_cidrs) > 0 ? 1 : 0

  allocation_id = aws_eip.nat_eip.id

  subnet_id = var.private_subnet_cidrs != [] ? aws_subnet.private_subnets[count.index].id : null


  depends_on = [aws_internet_gateway.internet-gw]

  tags = {
    Name = "My-nat-nategateway"
  }
}