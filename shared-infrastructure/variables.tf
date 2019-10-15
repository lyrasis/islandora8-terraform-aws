variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
}

variable "aws_profile" {
  description = "name of the aws profile"
}

variable "aws_region" {
  description = "The aws region"
  default     = "us-east-1"
}

variable "aws_ec2_keypair" {
  description = "The name of the keypair used for launching instances."
}

variable "ssh_user" {
  description = "default instance user: ubuntu"
  default     = "ubuntu"
}

variable "claw_playbook_dir" {
  description = "path to the claw-playbook project directory"
  default     = "../../claw-playbook"
}

variable "ami_id" { 
  description = "the amazon machin image"
  default     = "ami-04b9e92b5572fa0d1"
}
