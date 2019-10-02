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

variable "ssh_user" {
  description = "default instance user: ubuntu"
  default     = "ubuntu"
}

variable "islandora8_playbooks_dir" {
  description = "path to the Islandora8 playbooks project directory"
  default     = "../../islandora8-playbooks"
}
