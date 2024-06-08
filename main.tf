terraform {
  backend "s3" {
    bucket = "tf-state-dbrev74"
    key    = "ami/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
  owners      = ["973714476881"]
}

data "aws_security_group" "sg" {
  name = "allow-all"
}

resource "aws_instance" "ami" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_security_group.sg.id]

  tags = {
    Name = "ami"
  }
}

resource "null_resource" "main" {
  provisioner "remote-exec" {
    connection {
      user     = root
      password = "DevOps321"
      host     = aws_instance.ami.private_ip
    }

    inline = [
      "yum install ansible python3.12-pip.noarch -y", "pip3.12 install botocore boto3"
    ]
  }
}