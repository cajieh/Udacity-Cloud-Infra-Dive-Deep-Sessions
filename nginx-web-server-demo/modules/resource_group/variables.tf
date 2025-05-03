/* In the submodule (modules/resource_group), declare the 
variables to accept the values passed from the root module. */

variable "name" {}
variable "location" {}
variable "tags" {
  type = map(string)
}