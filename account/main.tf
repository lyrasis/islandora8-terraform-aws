module "local_setup" {
  source="../modules/local-setup" 
}

provider "aws" {
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
}

data "aws_vpc" "islandora" {

  tags = {
    Name   = "IslandoraVPC"
  }
}

resource "aws_subnet" "account" {
 vpc_id      = data.aws_vpc.islandora.id
 cidr_block  = "10.0.1.0/24"
}

data "aws_route_table" "sharedrt" {
  vpc_id = data.aws_vpc.islandora.id
  tags = {  
    Name = "IslandoraRouteTable"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.account.id}"
  route_table_id = "${data.aws_route_table.sharedrt.id}"
}

resource "aws_security_group" "islandora8_instance_sg" {
  vpc_id = "${data.aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8000 
    to_port     = 8000 
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080 
    to_port     = 8080 
    protocol    = "tcp"
  }
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306 
    to_port     = 3306 
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 5432 
    to_port     = 5432 
    protocol    = "tcp"
  }


  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8983 
    to_port     = 8983 
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8161 
    to_port     = 8161 
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8081 
    to_port     = 8081 
    protocol    = "tcp"
  }


  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22  
    to_port     = 22 
    protocol    = "tcp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip" {
    vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.web.id}"
  allocation_id = "${aws_eip.ip.id}"
}

resource "aws_instance" "web" {
  ami           = "ami-04b9e92b5572fa0d1"
  instance_type = "t2.large"
  subnet_id     = aws_subnet.account.id 
  vpc_security_group_ids = ["${aws_security_group.islandora8_instance_sg.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = {
    Islandora8 = "true"
    Instance   = "true"
    database   = "true"
    role       = "webserver,database,crayfish,karaf,tomcat,solr"
  } 
  
  provisioner "remote-exec" {
    inline = ["echo Hello World > remote-exec-test.txt"]
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }
  
}

resource "null_resource" "setup_instance" {
  depends_on = [module.local_setup, aws_eip_association.eip_assoc, aws_instance.web]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_eip.ip.public_ip} -i ../bin/ec2.py  -i ${var.claw_playbook_dir}/inventory/prod --user ${var.ssh_user}  ${var.claw_playbook_dir}/playbook.yml  --private-key ${var.private_key_path}"
  }
} 

