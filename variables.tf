
# Variables for Resource Group and Location
variable "resource_group_name" {
  type    = string
  default = "rg-py-prod-westus-01"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."

}

variable "location" {
  type    = string
  default = "West US"
  description = "Location of the resource group."
}