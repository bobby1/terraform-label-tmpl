module "basic_label" {
  source         = "../.."
  name           = "primary-01"
  resource       = "eks"
  vertical       = "chiro"
  brand          = "ctc"
  team           = "devops"
  region         = "use1"
  region_full    = "us-east-1"
  env            = "dev"
  label_key_case = "title"
}

module "basic_label_with_context" {
  source  = "../.."
  name    = "primary-02"
  context = module.basic_label.context
}

output "basic_label_with_context_id" {
  value = module.basic_label_with_context.id
}

output "all" {
  value = module.basic_label
}

output "basic_label_id" {
  value = module.basic_label.id
}

output "basic_tags" {
  value = module.basic_label.tags
}

module "team_label" {
  source      = "../.."
  name        = "bucket"
  vertical    = "chiro"
  brand       = "ctc"
  team        = "devops"
  region      = "use1"
  region_full = "us-east-1"
  env         = "prod"
}

output "team_label_id" {
  value = module.team_label.id
}

module "change_label_order" {
  source      = "../.."
  name        = "rds-primary"
  vertical    = "ortho"
  team        = "devops"
  region      = "use1"
  region_full = "us-east-1"
  env         = "prod"
  label_order = ["team", "name", "vertical", "attributes"]
  attributes  = ["01"]
}

output "change_label_order_id" {
  value       = module.change_label_order.id
  description = "Pretend this is a actual resource"
}

module "label_context" {
  source     = "../.."
  context    = module.change_label_order.context
  attributes = ["02"]
}

output "change_label_order_id_2" {
  value       = module.label_context.id
  description = "Pretend this is a actual resource"
}

# Azure example with location as primary
module "azure_location_example" {
  source        = "../.."
  name          = "app-service"
  vertical      = "chiro"
  brand         = "ctc"
  team          = "devops"
  location      = "eus"
  location_full = "eastus"
  env           = "prod"
  resource      = "appservice"
  label_order   = ["org_ctx", "env", "location", "resource", "name", "attributes"]
}

output "azure_location_example_id" {
  value       = module.azure_location_example.id
  description = "Azure resource with location as primary, full name available in output"
}

# AWS example with region as primary
module "aws_region_example" {
  source      = "../.."
  name        = "lambda-function"
  vertical    = "chiro"
  brand       = "ctc"
  team        = "devops"
  region      = "use1"
  region_full = "us-east-1"
  env         = "prod"
  resource    = "lambda"
}

output "aws_region_example_id" {
  value       = module.aws_region_example.id
  description = "AWS resource with region as primary, full name available in output"
}

output "short_names" {
  value = {
    region   = module.aws_region_example.region
    location = module.azure_location_example.location
  }
  description = "Short names used in IDs and tags"
}

output "full_names" {
  value = {
    region_full   = module.aws_region_example.region_full
    location_full = module.azure_location_example.location_full
  }
  description = "Full names available for external use"
}