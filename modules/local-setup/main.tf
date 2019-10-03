resource "null_resource" "local_setup" {

  # local setup commands (possibly download claw-playbook_ 

  provisioner "local-exec" {
    command = "echo local setup commands here"
  }
}
