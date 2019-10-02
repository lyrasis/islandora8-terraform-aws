module "ansible" {
  source="../modules/ansible" 
}

provider "aws" {
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
}

resource "aws_vpc" "islandora" {
 cidr_block  = "10.0.0.0/16"
 tags = {
    Name = "IslandoraVPC"
  }
}

resource "aws_subnet" "shared" {
 vpc_id      = aws_vpc.islandora.id
 cidr_block  = "10.0.0.0/24"
}

resource "aws_route_table" "sharedrt" {
  vpc_id = aws_vpc.islandora.id
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
  ami           = "ami-2757f631"
  instance_type = "t2.nano"
  subnet_id     = aws_subnet.shared.id 
  vpc_security_group_ids = ["${aws_security_group.shared.id}"] 
  key_name  = "duracloud-danny-keypair.pem"
  associate_public_ip_address = "true"
  tags = {
    Islandora8 = "true"
    Shared     = "true"
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

resource "null_resource" "post_create" {
  depends_on = [aws_instance.web, module.ansible]
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False AWS_PROFILE=${var.aws_profile} ansible-playbook --limit 'tag_Islandora8_true:&tag_Shared_true' -i ec2.py --user ${var.ssh_user}  ${var.islandora8_playbooks_dir}/shared-resources-playbook.yml  --private-key ${var.private_key_path}"
  }
} 

