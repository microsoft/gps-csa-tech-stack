provider "azurerm" {
  features {
    
  }
}

data "azurerm_client_config" "current" {
}
  

resource "azurerm_resource_group" "example" {
  name     = "examplerg"
  location = "eastasia"
}

resource "azurerm_key_vault" "kvexample" {
    name                = "kvexample888"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    tenant_id           = data.azurerm_client_config.current.tenant_id
    sku_name            = "standard"
    purge_protection_enabled = false
    enabled_for_disk_encryption = true
    enabled_for_deployment = true
    enabled_for_template_deployment = true
    network_acls {
        default_action             = "Deny"
        bypass                     = "AzureServices"
        ip_rules                   = ["167.220.255.12"]
    }
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.kvexample.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  key_permissions = [
                "Get",
                "Create",
                "Delete",
                "List",
                "Update",
                "Import"
            ]
            secret_permissions = [
                "Get",
                "List",
                "Set",
                "Delete",
                "Backup",
                "Restore",
                "Recover",
                "Purge"
            ]
            certificate_permissions = [
              "Get",
              "List",
              "Delete",
              "Create",
              "Import",
              "Update"
            ]
           

}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "prikey-test"
  value        = tls_private_key.example_ssh.private_key_pem
  key_vault_id = azurerm_key_vault.kvexample.id

  tags = {
    env = "dev"
    app = "app1"
    owner = "rade"
  }
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
    name = "pubkey-test"
    value = tls_private_key.example_ssh.public_key_openssh
    key_vault_id = azurerm_key_vault.kvexample.id

    tags = {
        env = "dev"
        app = "app1"
        owner = "rade"
    }
}