az group create --name testRG --location eastasia

terraform init

terraform plan  -out test.tfplan

terraform apply  test.tfplan



ansible -i /home/rade/hosts all -m ping

ansible-playbook -i /home/rade/hosts playbook.yml