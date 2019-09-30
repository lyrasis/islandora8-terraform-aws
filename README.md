# islandora8-terraform-aws

## Prerequisites
terraform
ansible 2.7

## Run 
```
terraform init
terraform apply -var 'aws_profile=<your-aws-profile>' -var 'private_key_path=<path/to/your/aws/private-key.pem>'
```
