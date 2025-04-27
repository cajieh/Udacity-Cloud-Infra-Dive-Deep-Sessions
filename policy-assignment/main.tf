provider "azurerm" {
  features {}
}

# Define the Azure Policy
resource "azurerm_policy_definition" "deny_resources_without_project_tag" {
  name         = "deny-resources-without-project-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny resources without Project tag"
  description  = "This policy denies the creation of resources that do not have the required Project tag with the value 'MyProject'."

  policy_rule = <<POLICY
  {
    "if": {
      "anyOf": [
        {
          "field": "[concat('tags[', 'Project', ']')]",
          "exists": "false"
        },
        {
          "field": "[concat('tags[', 'Project', ']')]",
          "notEquals": "MyProject"
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

# Retrieve the current subscription details
data "azurerm_subscription" "current" {}

# Assign the Policy to the Subscription
resource "azurerm_subscription_policy_assignment" "mypolicy_assignment" {
  name                 = "mypolicy_assignment"
  policy_definition_id = azurerm_policy_definition.deny_resources_without_project_tag.id
  subscription_id      = data.azurerm_subscription.current.id
}