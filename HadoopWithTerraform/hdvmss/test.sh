az group create --name hdrg --location eastasia

terraform init

terraform plan  -out test.tfplan

terraform apply  test.tfplan

