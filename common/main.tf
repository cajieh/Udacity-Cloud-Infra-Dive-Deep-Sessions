provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "./modules/resource_group"
  name     = var.name
  location = var.location
  tags     = var.tags
}

# Define the Azure Policy
resource "azurerm_policy_definition" "deny_resources_without_project_tag" {
  name         = "deny-resources-without-project-modern-cloud-infra-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny resources without 'project: modern-cloud-infra' tag"
  description  = "This policy denies the creation of resources that do not have the required 'project' tag with the value 'modern-cloud-infra'."

  policy_rule = <<POLICY
  {
    "if": {
      "anyOf": [
        {
          "field": "[concat('tags[', 'project', ']')]",
          "exists": "false"
        },
        {
          "field": "[concat('tags[', 'project', ']')]",
          "notEquals": "modern-cloud-infra"
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY

  metadata = <<METADATA
  {
    "category": "Tags"
  }
  METADATA
}

/*
# Retrieve the current subscription details
data "azurerm_subscription" "current" {}

# Assign the Policy to the Subscription
resource "azurerm_subscription_policy_assignment" "policy_assignment" {
  name                 = "modern_cloud_infra_policy_assignment"
  policy_definition_id = azurerm_policy_definition.deny_resources_without_project_tag.id
  subscription_id      = data.azurerm_subscription.current.id
}

output "subscription_id" {
  value = data.azurerm_subscription.current.id
}
*/

# Assign the Policy to the Resource Group
resource "azurerm_resource_group_policy_assignment" "policy_assignment" {
  name                        = "modern_cloud_infra_policy_assignment"
  policy_definition_id        = azurerm_policy_definition.deny_resources_without_project_tag.id
   resource_group_id          = module.resource_group.id

}

output "resource_group_id" {
  value = module.resource_group.id
}
