terraform {
  /*cloud {
    organization = "blufod"

    workspaces {
      name = "provsioners"
    }
  }*/
  

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.59.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "main" {
  id = "vpc-06ceef3a899b243ee"
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "MyServer Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["5.68.193.146/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = ""
}

data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

resource "aws_instance" "my_server" {
  ami                    = "ami-0ac67a26390dc374d"
  instance_type = "t2.micro"
	key_name = "${aws_key_pair.deployer.key_name}"
	vpc_security_group_ids = [aws_security_group.sg_my_server.id]
	user_data = data.template_file.user_data.rendered
  provisioner "remote-exec" {
		inline = [
			"echo \"mars\" >> /home/ec2-user/barsoon/txt"
		]
		connection {
			type     = "ssh"
			user     = "ec2-user"
			host     = "${self.public_ip}"
			private_key = "${file("/Users/ama/.ssh/terraform")}"
		}
  }


  tags = {
    Name = "MyServer"
  }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}