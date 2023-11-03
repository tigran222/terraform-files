provider "aws" {
  region = "eu-central-1" # Change this to your desired region
}

resource "aws_vpc" "project" {
  cidr_block           = "10.100.0.0/16" # Adjust the CIDR block as needed
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.project.id
  cidr_block              = "10.100.${count.index}.0/24"
  availability_zone       = "eu-central-1a" # Change availability zones as needed
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.project.id
  cidr_block        = "10.100.${count.index + 2}.0/24"
  availability_zone = "eu-central-1b" # Change availability zones as needed
}

resource "aws_internet_gateway" "project-ig" {
  vpc_id = aws_vpc.project.id
}

resource "aws_route_table" "project-rt" {
  vpc_id = aws_vpc.project.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-ig.id
  }
}

resource "aws_route_table_association" "project-rta0" {
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.project-rt.id
}

resource "aws_route_table_association" "project-rta1" {
  subnet_id      = aws_subnet.public[1].id
  route_table_id = aws_route_table.project-rt.id
}

resource "aws_route_table_association" "project-rta2" {
  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.project-rt.id
}

resource "aws_route_table_association" "project-rta4" {
  subnet_id      = aws_subnet.private[1].id
  route_table_id = aws_route_table.project-rt.id
}
resource "aws_security_group" "jenkins_master" {
  vpc_id = aws_vpc.project.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SecurityGroup"
  }
}

resource "aws_instance" "jenkins_master" {
  ami                    = "ami-06dd92ecc74fdfb36"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_master.id]
  key_name               = "devops"
  user_data              = file("execute.sh")
  tags = {
    Name = "Jenkins-Server"
  }
}

resource "aws_instance" "jenkins-slave" {
  ami                    = "ami-06dd92ecc74fdfb36"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_master.id]
  key_name               = "devops"
  user_data              = "execute_slave.sh"
  tags = {
    "Name" = "Jenkins-Slave"
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}


output "jenkins_slave_public_ip" {
  value = aws_instance.jenkins_slave.public_ip
}

output "jenkins_admin_password" {
  value = "${aws_instance.jenkins_master.public_ip}:/var/lib/jenkins/secrets/initialAdminPassword"
}































