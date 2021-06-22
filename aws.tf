resource "aws_instance" "boundary-demo-aws" {
  ami                    = var.ami
  subnet_id              = aws_subnet.boundary-demo-subnet.id
  instance_type          = var.aws_machine_type
  user_data              = data.template_file.init_aws.rendered
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "boundary-demo"
  }
}

data "template_file" "init_aws" {
  template = file("setup.sh")
  vars = {
    ubuntu_password = var.ubuntu_password
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allwo_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.boundary-demo-vpc.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
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

resource "aws_vpc" "boundary-demo-vpc" {
  tags = {
    Name = "boundary-demo-vpc"
  }
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "boundary-demo-subnet" {
  vpc_id     = aws_vpc.boundary-demo-vpc.id
  cidr_block = "10.10.0.0/24"

  tags = {
    Name = "boundary-demo-subnet"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.boundary-demo-vpc.id

}

# RouteTable
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.boundary-demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public"
  }
}

# SubnetRouteTableAssociation
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.boundary-demo-subnet.id
  route_table_id = aws_route_table.public.id
}

# NatGateway
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.boundary-demo-subnet.id
  allocation_id = aws_eip.nat.id
}

resource "aws_eip" "eip" {
  instance = aws_instance.boundary-demo-aws.id
  vpc      = true
}
