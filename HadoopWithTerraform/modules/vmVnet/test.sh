az group create --name testRG --location eastasia

terraform init

terraform plan -var-file=test.tfvars -out test.tfplan 

terraform apply  test.tfplan

