# islandora8-terraform-aws

## Prerequisites
* python3
* awscli (`pip3 install awscli --upgrade`)
* boto (`pip install boto`)
* ansible 2.7 (`pip install  git+https://github.com/ansible/ansible.git@v2.7.12`) 
* terraform v0.12+

## Run 
```
cd shared-infrastructure
terraform init
terraform apply -var 'aws_profile=<your-aws-profile>' -var 'private_key_path=<path/to/your/aws/private-key.pem>' -var 'aws_ec2_keypair=keypairname'

cd account 
terraform init
terraform apply -var 'aws_profile=<your-aws-profile>' -var 'private_key_path=<path/to/your/aws/private-key.pem>' -var 'aws_ec2_keypair=keypairname'
```
