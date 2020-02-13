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
    Name = "islandora_vpc"
  }
}

resource "aws_subnet" "instances" {
 vpc_id      = aws_vpc.islandora.id
 cidr_block  = "10.0.0.0/24"
 availability_zone = "us-east-1a"

 tags = { 
    Name = "islandora_instance_subnet"
  }
}

resource "aws_subnet" "shared_resources" {
 vpc_id      = aws_vpc.islandora.id
 cidr_block  = "10.0.1.0/24"
 availability_zone = "us-east-1b"

 tags = {
    Name = "islandora_shared_resources_subnet"
  }
}

resource "aws_db_subnet_group" "islandora_db_subnet_group" {
  name       = "islandora_db_subnet_group"
  subnet_ids = ["${aws_subnet.instances.id}", "${aws_subnet.shared_resources.id}"]

  tags = {
    Name = "islandora_db_subnet_group"
  }
}

resource "aws_route_table" "sharedrt" {
  vpc_id = aws_vpc.islandora.id
  tags = { 
    Name = "islandora_shared_route_table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.shared_resources.id}"
  route_table_id = "${aws_route_table.sharedrt.id}"
}

resource "aws_route_table_association" "instance" {
  subnet_id      = "${aws_subnet.instances.id}"
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

resource "aws_security_group" "drupal" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "drupal_sg"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = "${aws_vpc.islandora.id}"

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
    Name = "bastion_sg"
  }
}

resource "aws_security_group" "activemq" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 61613
    to_port     = 61613
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 61616
    to_port     = 61616
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 8161
    to_port     = 8161
    protocol    = "tcp"
  }

  tags = {
    Name = "activemq_sg"
  }
}

resource "aws_security_group" "fedora" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 8080 
    to_port     = 8080
    protocol    = "tcp"
  }

  tags = {
    Name = "fedora_sg"
  }
}

resource "aws_security_group" "cantaloupe" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  tags = {
    Name = "cantaloupe_sg"
  }
}

resource "aws_security_group" "triplestore" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  tags = {
    Name = "triplestore_sg"
  }
}

resource "aws_security_group" "crayfish" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
  }

  tags = {
    Name = "crayfish_sg"
  }
}

resource "aws_security_group" "solr" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 8983
    to_port     = 8983
    protocol    = "tcp"
  }
  tags = {
    Name = "solr_sg"
  }
}

resource "aws_security_group" "karaf" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 8101 
    to_port     = 8101
    protocol    = "tcp"
  }

  tags = {
    Name = "karaf_sg"
  }
}

resource "aws_security_group" "ssh" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
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
    Name = "ssh_sg"
  }
}


resource "aws_security_group" "islandora_database" {
  vpc_id = "${aws_vpc.islandora.id}"

  ingress {
    cidr_blocks = ["10.0.1.0/24", "10.0.0.0/24"]
    from_port   = 3306 
    to_port     = 3306 
    protocol    = "tcp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "islandora_db_security_group"
  }
}

resource "aws_db_instance" "database" {
  identifier           = "islandora8-shared-db"
  depends_on           = [aws_db_subnet_group.islandora_db_subnet_group]
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "islandora"
  username             = "root"
  password             = "islandora"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "islandora_db_subnet_group"
  vpc_security_group_ids =  [ aws_security_group.islandora_database.id ]
  skip_final_snapshot  = "true"
  final_snapshot_identifier = "final-islandora-db"

  tags = {
    Name       = "shared_database"
  } 
}

resource "aws_instance" "bastion" {
  ami           = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.shared_resources.id
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = {
    Name       = "bastion"
  }
}

resource "aws_instance" "fedora" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared_resources.id 
  vpc_security_group_ids = ["${aws_security_group.fedora.id}", "${aws_security_group.ssh.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "shared_fedora"
    role       = "fedora"
  }   
  
  
  provisioner "remote-exec" {
    inline = ["echo Hello World > remote-exec-test.txt"]
    connection {
      host        = "${self.private_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
    }   
  }
}

resource "aws_instance" "triplestore" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared_resources.id 
  vpc_security_group_ids = ["${aws_security_group.triplestore.id}", "${aws_security_group.ssh.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "shared_triple_store"
    role       = "triplestore"
  }   
  
  
  provisioner "remote-exec" {
    inline = ["echo Hello World > remote-exec-test.txt"]
    connection {
      host        = "${self.private_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
    }   
  }
}

resource "aws_instance" "crayfish" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared_resources.id 
  vpc_security_group_ids = ["${aws_security_group.crayfish.id}", "${aws_security_group.ssh.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "shared_crayfish"
    role       = "crayfish"
  }   
  
  provisioner "remote-exec" {
    inline = ["echo Hello World > remote-exec-test.txt"]
    connection {
      host        = "${self.private_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
    }   
  }
}

resource "aws_instance" "karaf" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared_resources.id 
  vpc_security_group_ids = ["${aws_security_group.karaf.id}", "${aws_security_group.ssh.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "shared_karaf"
    role       = "karaf"
  }   
  
  
  provisioner "remote-exec" {
    inline = ["echo Hello World > remote-exec-test.txt"]
    connection {
      host        = "${self.private_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
    }   
  }
}

resource "aws_instance" "solr" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared_resources.id 
  vpc_security_group_ids = ["${aws_security_group.solr.id}", "${aws_security_group.ssh.id}"] 
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = { 
    Name       = "shared_solr" 
    role       = "solr"
  }   
  
  
  provisioner "remote-exec" {
    inline = ["echo Hello World > remote-exec-test.txt"]
    connection {
      host        = "${self.private_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
    }   
  }
}

resource "aws_instance" "cantaloupe" {
  ami           = "${var.ami_id}"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.shared_resources.id
  vpc_security_group_ids = ["${aws_security_group.cantaloupe.id}", "${aws_security_group.ssh.id}"]
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = {
    Name       = "shared_cantaloupe"
    role       = "cantaloupe"
  }


  provisioner "remote-exec" {
    inline = ["echo Hello World > remote-exec-test.txt"]
    connection {
      host        = "${self.private_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
    }
  }
}

resource "aws_instance" "activemq" {
  ami           = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.shared_resources.id
  vpc_security_group_ids = ["${aws_security_group.activemq.id}", "${aws_security_group.ssh.id}"]
  key_name  = "${var.aws_ec2_keypair}"
  associate_public_ip_address = "true"
  tags = {
    Name       = "shared_activemq"
    role       = "activemq"
  }


  provisioner "remote-exec" {
    inline = ["echo Hello World > remote-exec-test.txt"]
    connection {
      host        = "${self.private_ip}"
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
      bastion_host = "${aws_instance.bastion.public_ip}"
    }
  }
}

resource "null_resource" "configure_fedora" {
  depends_on = [module.local_setup, aws_instance.fedora, aws_db_instance.database]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.fedora.private_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod -e db_host=${aws_db_instance.database.address} -e bastion_host=${aws_instance.bastion.public_ip} --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"
  }
}

resource "null_resource" "configure_triplestore" {
  depends_on = [module.local_setup, aws_instance.triplestore]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.triplestore.private_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod -e bastion_host=${aws_instance.bastion.public_ip} --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"

  }
}

resource "null_resource" "configure_crayfish" {
  depends_on = [module.local_setup, aws_instance.crayfish, aws_db_instance.database]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.crayfish.private_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod -e db_host=${aws_db_instance.database.address} -e bastion_host=${aws_instance.bastion.public_ip} --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"

  }
}

resource "null_resource" "configure_karaf" {
  depends_on = [module.local_setup, aws_instance.karaf, aws_db_instance.database]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.karaf.private_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod -e db_host=${aws_db_instance.database.address} -e bastion_host=${aws_instance.bastion.public_ip} --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"
  }
}

resource "null_resource" "configure_solr" {
  depends_on = [module.local_setup, aws_instance.solr]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.solr.private_ip} -e bastion_host=${aws_instance.bastion.public_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"
  }
}

resource "null_resource" "configure_cantaloupe" {
  depends_on = [module.local_setup, aws_instance.cantaloupe]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.cantaloupe.private_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod -e bastion_host=${aws_instance.bastion.public_ip} --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"
  }
}

resource "null_resource" "configure_activemq" {
  depends_on = [module.local_setup, aws_instance.activemq]
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=../config/ansible.cfg EC2_INI_PATH=../config/ec2.ini AWS_PROFILE=${var.aws_profile} ansible-playbook --limit=${aws_instance.activemq.private_ip} -i ../bin/ec2.py -i ${var.claw_playbook_dir}/inventory/prod -e bastion_host=${aws_instance.bastion.public_ip} --user ${var.ssh_user} ${var.claw_playbook_dir}/playbook.yml --private-key ${var.private_key_path}"
  }
}
