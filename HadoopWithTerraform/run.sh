terraform init

terraform plan -var-file=spot.tfvars -out main.tfplan

terraform apply  main.tfplan

terraform output -raw tls_private_key > id_rsa

terraform output public_ip_address



az keyvault secret download --vault-name kvexample888 -n prikey-test  -f cert1.pem

chmod 0400 cert1.pem

ssh -i cert1.pem myadmin@20.205.6.40



terraform apply -var-file=spot.tfvars -destroy


az vm image list --offer UbuntuServer --all --location eastasia