module "local_setup" {
  source="../modules/local-setup" 
}

provider "aws" {
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
}

data "aws_vpc" "islandora" {

  tags = {
    Name   = "islandora_vpc"
  }
}

data "aws_subnet" "account" {
  tags = {
   Name   = "islandora_instance_subnet"
  }
}

data "aws_db_instance" "database" {
  db_instance_identifier = "islandora8-shared-db"
}

data "aws_security_group" "islandora_instance_sg" {
  tags = {
    Name = "islandora_instance_sg"

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
  instance_type = "t2.small"
  subnet_id     = data.aws_subnet.account.id 
  vpc_security_group_ids = ["${data.aws_security_group.islandora_instance_sg.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = {
    Name       = "islandora_instance"
    role       = "webserver"
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
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_eip.ip.public_ip} -i ../bin/ec2.py  -i ${var.claw_playbook_dir}/inventory/prod -e db_host=${data.aws_db_instance.database.address} --user ${var.ssh_user}  ${var.claw_playbook_dir}/playbook.yml  --private-key ${var.private_key_path}"
  }
} 

