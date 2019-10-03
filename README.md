# islandora8-terraform-aws

## Prerequisites
terraform
ansible 2.7

## Run 
```
cd shared-infrastructure
terraform init
terraform apply -var 'aws_profile=<your-aws-profile>' -var 'private_key_path=<path/to/your/aws/private-key.pem>' -var 'aws_ec2_keypair=keypairname'

cd account 
terraform init
terraform apply -var 'aws_profile=<your-aws-profile>' -var 'private_key_path=<path/to/your/aws/private-key.pem>' -var 'aws_ec2_keypair=keypairname'
```
