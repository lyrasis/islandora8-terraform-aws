resource "null_resource" "setup" {

  # Download and configure ec2 scripts necessary for pulling a dynamic inventory from AWS.

  provisioner "local-exec" {
    command = "curl https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py > ec2.py"
  }

  provisioner "local-exec" {
    command = "chmod u+x ec2.py"
  }

  provisioner "local-exec" {
    command = "curl https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini > ec2.ini"
  }
}
