module "local_setup" {
  source="../modules/local-setup" 
}

provider "aws" {
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
}

resource "aws_vpc" "islandora" {
 cidr_block  = "10.0.0.0/16"
 enable_dns_hostnames =  true
 tags = {
    Name = "IslandoraVPC"
  }
}

resource "aws_subnet" "shared" {
 vpc_id      = aws_vpc.islandora.id
 cidr_block  = "10.0.0.0/24"

 tags = { 
    Name = "IslandoraSharedSubnet"
  }
}

resource "aws_route_table" "sharedrt" {
  vpc_id = aws_vpc.islandora.id
  tags = { 
    Name = "IslandoraRouteTable"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.shared.id}"
  route_table_id = "${aws_route_table.sharedrt.id}"
}

resource "aws_route" "route2igc" {
  route_table_id            = "${aws_route_table.sharedrt.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.islandora_gateway.id}"
}

resource "aws_internet_gateway" "islandora_gateway" {
  vpc_id     = aws_vpc.islandora.id
}

resource "aws_security_group" "shared" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80 
    to_port     = 80 
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

  tags = { 
    Name   = "IslandoraSharedSecurityGroup"
  }
}

resource "aws_instance" "database" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared.id 
  vpc_security_group_ids = ["${aws_security_group.shared.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = {
    Name       = "SharedDatabase"
    role       = "database"
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

resource "aws_instance" "fedora" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared.id 
  vpc_security_group_ids = ["${aws_security_group.shared.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "SharedFedora"
    role       = "fedora"
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

resource "aws_instance" "triplestore" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared.id 
  vpc_security_group_ids = ["${aws_security_group.shared.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "SharedTripleStore"
    role       = "triplestore"
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

resource "aws_instance" "crayfish" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared.id 
  vpc_security_group_ids = ["${aws_security_group.shared.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "SharedCrayfish"
    role       = "crayfish"
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

resource "aws_instance" "karaf" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared.id 
  vpc_security_group_ids = ["${aws_security_group.shared.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "Shared Karaf"
    role       = "karaf"
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

resource "aws_instance" "solr" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared.id 
  vpc_security_group_ids = ["${aws_security_group.shared.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "Shared Solr" 
    role       = "solr"
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

resource "null_resource" "configure_database" {
  depends_on = [module.local_setup, aws_instance.database]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.database.public_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"

  }
}

resource "null_resource" "configure_fedora" {
  depends_on = [module.local_setup, aws_instance.fedora]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.fedora.public_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"

  }
}

resource "null_resource" "configure_triplestore" {
  depends_on = [module.local_setup, aws_instance.triplestore]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.triplestore.public_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"

  }
}

resource "null_resource" "configure_crayfish" {
  depends_on = [module.local_setup, aws_instance.crayfish]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.crayfish.public_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"

  }
}

resource "null_resource" "configure_karaf" {
  depends_on = [module.local_setup, aws_instance.karaf]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.karaf.public_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"
  }
}

resource "null_resource" "configure_solr" {
  depends_on = [module.local_setup, aws_instance.solr]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.solr.public_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"
  }
}

