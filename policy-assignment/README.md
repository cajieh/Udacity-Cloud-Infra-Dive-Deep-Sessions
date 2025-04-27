### Explanation

#### Using "anyOf" for missing tag and value
```
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
}
```
Behavior:
The policy will deny resource creation if any one of the conditions is true.
This means:
If the Project tag does not exist (exists: false), the resource creation is denied.
If the Project tag exists but its value is not MyProject (notEquals: "MyProject"), the resource creation is denied.
Use Case:

Use "anyOf" when you want to enforce either condition independently. For example:
Deny if the tag is missing.
Deny if the tag exists but has an incorrect value.


### Error 1:

```
Error: creating/updating Policy Definition "TestPolicy": policy.DefinitionsClient#CreateOrUpdate: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="AuthorizationFailed" Message
```

To create or update policy definitions, the service principal or user must have one of the following roles at the subscription or management group level:

Owner
Contributor
Resource Policy Contributor (recommended for managing policies)
You can assign the Resource Policy Contributor role using the Azure CLI or Azure Portal.

Using Azure CLI
Run the following command to assign the Resource Policy Contributor role to your service principal or user:
```
az role assignment create \
  --assignee  <client_id> \
  --role "Resource Policy Contributor" \
  --scope "/subscriptions/<subscription_id>"
```

### Verify Permissions
After assigning the role, verify that the service principal or user has the required permissions:

```
az role assignment list --assignee <object_id> --scope "/subscriptions/<subscription_id>" --output table
```


### Error 2: 
A resource with the ID "/subscriptions/xxxxxxx/providers/Microsoft.Authorization/policyDefinitions/deny-resources-without-project-tag" already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for "azurerm_policy_definition" for more information.

####Import the Existing Policy Definition

```
terraform import azurerm_policy_definition.deny_resources_without_project_tag /subscriptions/<subscription_id>/providers/Microsoft.Authorization/policyDefinitions/deny-resources-without-project-tag
```

2. Verify the Import

```
terraform state list
``