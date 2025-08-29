# Overview

A PracticeTek opinionated module which provides standardized tagging and id generation for use in our other modules

This currently module is based on a fork of
[Cloudposse's terraform-null-label module](https://github.com/cloudposse/terraform-null-label)

## Features

- **Multi-cloud support**: Supports both AWS (`region`) and Azure (`location`) naming conventions
- **Standardized tagging**: Consistent tag generation across all resources
- **Flexible ID generation**: Configurable label order and formatting options

## Variables

### Core Variables

- `region` - AWS region shorthand (e.g., `use1`, `use2`, `usw2`, `cac1`, `global`) - **Backward compatible**
- `region_full` - AWS region full name (e.g., `us-east-1`, `us-east-2`, `us-west-2`, `ca-central-1`, `global`) - **New**
- `location` - Azure location shorthand (e.g., `eus`, `eus2`, `cus`, `wus`, `wus2`, `scus`, `global`) - **Backward compatible**
- `location_full` - Azure location full name (e.g., `eastus`, `eastus2`, `centralus`, `westus`, `westus2`, `southcentralus`, `global`) - **New**
- `env` - Environment (e.g., `prod`, `dev`, `stg`, `preprod`)
- `name` - Resource name
- `team` - Team ownership
- `vertical` - Business vertical
- `brand` - Brand association

### Region and Location Support

The module supports both shorthand (backward compatible) and full names (new feature):

| Full Name | Shorthand | Type |
|-----------|-----------|------|
| `us-east-1` | `use1` | AWS Region |
| `us-east-2` | `use2` | AWS Region |
| `us-west-2` | `usw2` | AWS Region |
| `ca-central-1` | `cac1` | AWS Region |
| `eastus` | `eus` | Azure Location |
| `eastus2` | `eus2` | Azure Location |
| `centralus` | `cus` | Azure Location |
| `westus` | `wus` | Azure Location |
| `westus2` | `wus2` | Azure Location |
| `southcentralus` | `scus` | Azure Location |
| `global` | `global` | Global |

### Usage Examples

**Backward Compatible (Existing Code):**
```hcl
module "existing_resource" {
  source   = "path/to/module"
  name     = "my-resource"
  region   = "use1"      # Still works!
  location = "eus"       # Still works!
  env      = "prod"
  team     = "devops"
}
```

**New Full Name Support:**
```hcl
module "new_resource" {
  source       = "path/to/module"
  name         = "my-resource"
  region_full  = "us-east-1"    # New!
  location_full = "eastus"      # New!
  env          = "prod"
  team         = "devops"
}
```

**Mixed Usage:**
```hcl
module "mixed_resource" {
  source       = "path/to/module"
  name         = "my-resource"
  region       = "use1"         # Shorthand
  location_full = "eastus"      # Full name
  env          = "prod"
  team         = "devops"
}
```

# Usage
See the examples/basic directory in this repo.

# Development

# Releasing a new module

Currently releases are triggered manually while we work out the sematic-release
process with terraform modules.  

* git tag v#.#.# 
* git push origin v#.#.#