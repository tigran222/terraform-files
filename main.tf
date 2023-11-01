provider "aws" {
  region = "eu-central-1" # Change this to your desired region
}

resource "aws_instance" "jenkins_master" {
  ami           = "ami-06dd92ecc74fdfb36" # Replace with your desired AMI
  instance_type = "t2.micro"              # Adjust the instance type as needed
  # subnet_id              = aws_subnet.public[0].id                # Choose one of the public subnets
  # vpc_security_group_ids = [aws_security_group.jenkins_master.id] # Associate with the security group
  key_name = "devops"
  tags = {
    Name = "Jenkins-Server"
  }
}
