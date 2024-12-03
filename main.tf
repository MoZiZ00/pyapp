
# Create Resource Group
resource "azurerm_resource_group"  {
  name     = var.resource_group_name
  location = var.location
}

# Create Virtual Network (VNet)
resource "azurerm_virtual_network"   {
  name                = "vnet-py-prod-westus-01"
  location            = var.location
  resource_group_name =  var.resource_group_name
  address_space       = ["10.0.0.0/16"]

}

# Create Subnet for the App Service and other services
resource "azurerm_subnet"   {
  name                 = "snet-py-prod-westus-01"
  resource_group_name  =  var.resource_group_name
  virtual_network_name = "vnet-py-prod-westus-01"
  address_prefixes     = ["10.0.1.0/24"]
}

# Create App Service Plan (for Container)
resource "azurerm_app_service_plan"   {
  name                = "asp-py-prod-westus-01"
  location            = var.location
  resource_group_name =  var.resource_group_name
  kind                = "Linux"
  reserved            = true  # For Linux-based Web Apps
 
zone_redundant      = true    ## this is from hash corp site

  sku {
    tier = "Premium"
    size = "V3 P0V3"
  }

  virtual_network_subnet_id = azurerm_subnet.id
}

# Create Web App for Containers (App Service)
resource "azurerm_web_app"   {
  name                = "app-py-prod-westus-01"
  location            = var.location
  resource_group_name =  var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.id

  site_config {
    
 ## linux_fx_version = "DOCKER|msaadany/pyapp:v1.0"
 ## App Service is configured to pull the Docker image from the Azure Container Registry 
    linux_fx_version = "DOCKER|testpy.azurecr.io/pyapp:v1.0"   
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  
}


# Create application insights

resource "azurerm_resource_group"  {
  resource_group_name =  var.resource_group_name
  location = var.location
}

resource "azurerm_application_insights"  {
  name                = "appi-py-prod-westus-01"
  location = var.location
  resource_group_name =  var.resource_group_name
  application_type    = "web"
}

output "instrumentation_key" {
  value = azurerm_application_insights.instrumentation_key
}

output "app_id" {
  app_service_id = azurerm_app_service.id
}


# Create a azure container registry

resource "azurerm_container_registry" {
  name                = "cr-py-prod-westus-01"
  location            = var.location
  resource_group_name =  var.resource_group_name
  sku                 = "Premium"
  admin_enabled       = false

   georeplications {
    location                = "East US"
    zone_redundancy_enabled = true
     }
}



# Create a Public Load Balancer

resource "azurerm_public_ip" {
  name                = "pip-lbe-py-prod-westus-01"
  location = var.location
  resource_group_name =  var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" {
  name                = "lbe-py-prod-westus-01"
  location            = var.location
  resource_group_name =  var.resource_group_name

  frontend_ip_configuration {
    name                 = "frontendlbe-py-prod-westus-01"
    public_ip_address_id = azurerm_public_ip.id
  }

  frontend_port {
    name = "port-5000"
    port = 5000
  }

  backend_address_pool {
    name = "bclbe-py-prod-westus-01"
  }

  load_balancing_rule {
    name                          = "rule-py-prod-westus-01"
    frontend_ip_configuration_name = "frontendlbe-py-prod-westus-01"
    frontend_port_name            = "port-5000"
    backend_address_pool_name     = "bclbe-py-prod-westus-01"
    backend_port                  = 5000
    protocol                      = "Tcp"
  }
}

# Connect the App Service to the VNet

resource "azurerm_app_service_virtual_network_swift_connection" {
  app_service_id    = azurerm_app_service.id
  subnet_id         = azurerm_virtual_network.subnet[0].id
}


#Steps to Deploy:

#Initialize Terraform:
#terraform init

#Apply the Configuration:
#terraform apply