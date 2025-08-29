variable "context" {
  type = any
  default = {
    enabled             = true
    org_ctx             = null
    brand               = null
    vertical            = null
    resource            = null
    org                 = null
    team                = null
    env                 = null
    region              = null
    location            = null
    region_full         = null
    location_full       = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = []
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    # Note: we have to use [] instead of null for unset lists due to
    # https://github.com/hashicorp/terraform/issues/28137
    # which was not fixed until Terraform 1.0.0,
    # but we want the default to be all the labels in `label_order`
    # and we want users to be able to prevent all tag generation
    # by setting `labels_as_tags` to `[]`, so we need
    # a different sentinel to indicate "default"
    labels_as_tags = ["unset"]
  }
  description = <<-EOT
    Single object for setting entire context at once.
    See description of individual variables for details.
    Leave string and numeric variables as `null` to use default value.
    Individual variable settings (non-null) override settings in context object,
    except for attributes, tags, and additional_tag_map, which are merged.
  EOT

  validation {
    condition     = lookup(var.context, "label_key_case", null) == null ? true : contains(["lower", "title", "upper"], var.context["label_key_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }

  validation {
    condition     = lookup(var.context, "label_value_case", null) == null ? true : contains(["lower", "title", "upper", "none"], var.context["label_value_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "enabled" {
  type        = bool
  default     = null
  description = "Set to false to prevent the module from creating any resources"
}

variable "name" {
  type        = string
  default     = null
  description = <<-EOT
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.
    This is the only ID element not also included as a `tag`.
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.
    EOT
}

variable "delimiter" {
  type        = string
  default     = null
  description = <<-EOT
    Delimiter to be used between ID elements.
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.
  EOT
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = <<-EOT
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,
    in the order they appear in the list. New attributes are appended to the
    end of the list. The elements of the list are joined by the `delimiter`
    and treated as a single ID element.
    EOT
}

variable "labels_as_tags" {
  type        = set(string)
  default     = ["default"]
  description = <<-EOT
    Set of labels (ID elements) to include as tags in the `tags` output.
    Default is to include all labels.
    Tags with empty values will not be included in the `tags` output.
    Set to `[]` to suppress all generated tags.
    **Notes:**
      The value of the `name` tag, if included, will be the `id`, not the `name`.
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be
      changed in later chained modules. Attempts to change it will be silently ignored.
    EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).
    Neither the tag keys nor the tag values will be modified by this module.
    EOT
}

variable "tag_prefix" {
  type    = string
  default = "pt:"
}

variable "additional_tag_map" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.
    This is for some rare cases where resources want additional configuration of tags
    and therefore take a list of maps with tag key, value, and additional configuration.
    EOT
}

variable "label_order" {
  type        = list(string)
  default     = null
  description = <<-EOT
    The order in which the labels (ID elements) appear in the `id`.
    Defaults to ["org", "env", "region", "name", "attributes"].
    You can omit any of the 7 labels ("team" and "vertical" are the other two), but at least one must be present.
    EOT
}

variable "regex_replace_chars" {
  type        = string
  default     = null
  description = <<-EOT
    Terraform regular expression (regex) string.
    Characters matching the regex will be removed from the ID elements.
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.
  EOT
}

variable "id_length_limit" {
  type        = number
  default     = null
  description = <<-EOT
    Limit `id` to this many characters (minimum 6).
    Set to `0` for unlimited length.
    Set to `null` for keep the existing setting, which defaults to `0`.
    Does not affect `id_full`.
  EOT
  validation {
    condition     = var.id_length_limit == null ? true : var.id_length_limit >= 6 || var.id_length_limit == 0
    error_message = "The id_length_limit must be >= 6 if supplied (not null), or 0 for unlimited length."
  }
}

variable "label_key_case" {
  type        = string
  default     = null
  description = <<-EOT
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.
    Does not affect keys of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper`.
    Default value: `title`.
  EOT

  validation {
    condition     = var.label_key_case == null ? true : contains(["lower", "title", "upper"], var.label_key_case)
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }
}

variable "label_value_case" {
  type        = string
  default     = null
  description = <<-EOT
    Controls the letter case of ID elements (labels) as included in `id`,
    set as tag values, and output by this module individually.
    Does not affect values of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.
    Default value: `lower`.
  EOT

  validation {
    condition     = var.label_value_case == null ? true : contains(["lower", "title", "upper", "none"], var.label_value_case)
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "descriptor_formats" {
  type        = any
  default     = {}
  description = <<-EOT
    Describe additional descriptors to be output in the `descriptors` output map.
    Map of maps. Keys are names of descriptors. Values are maps of the form
    `{
       format = string
       labels = list(string)
    }`
    (Type is `any` so the map values can later be enhanced to provide additional options.)
    `format` is a Terraform format string to be passed to the `format()` function.
    `labels` is a list of labels, in order, to pass to `format()` function.
    Label values will be normalized before being passed to `format()` so they will be
    identical to how they appear in `id`.
    Default is `{}` (`descriptors` output will be empty).
    EOT
}


#
# PracticeTek addtionals
#

variable "team" {
  type        = string
  default     = null
  description = "ID component. The team that own this indicating who this instance of a resource is for.  'dataeng', 'ml', 'frontend', `sre`'"

  # validation {
  #   condition = var.team == null ? true : contains([
  #     "backend",
  #     "csuite",
  #     "dataeng",
  #     "devops",
  #     "finance",
  #     "frontend",
  #     "innovation",
  #     "legal",
  #     "ml",
  #     "revenue",
  #     "sre",
  #     "verticals",
  #   ], var.team)
  #   error_message = "Allowed values: `backend`, `csuite`, `dataeng`, `devops`, `finance`, `frontend`, `innovation`, `legal`, `ml`, `revenue`, `sre`, `verticals`."
  # }
}

variable "org" {
  type        = string
  default     = null
  description = "ID component. The organization. Allowed values: `pt`, `ips`"

  validation {
    condition     = var.org == null ? true : contains(["ips", "pt"], var.org)
    error_message = "Allowed values: `pt`, `ips'."
  }
}

variable "region" {
  type        = string
  default     = null
  description = "ID component. The region in which the resources reside. Allowed values: `use1`, `use2`, `usw2`, `cac1`, `global`"
  validation {
    condition     = var.region == null ? true : contains(["global", "use1", "use2", "usw2", "cac1"], var.region)
    error_message = "Allowed values: `use1`, `use2`, `usw2`, `cac1`, `global`."
  }
}

variable "region_full" {
  type        = string
  default     = null
  description = "ID component. The region in which the resources reside (full name). Allowed values: `us-east-1`, `us-east-2`, `us-west-2`, `ca-central-1`, `global`"
  validation {
    condition     = var.region_full == null ? true : contains(["global", "us-east-1", "us-east-2", "us-west-2", "ca-central-1"], var.region_full)
    error_message = "Allowed values: `us-east-1`, `us-east-2`, `us-west-2`, `ca-central-1`, `global`."
  }
}

variable "location" {
  type        = string
  default     = null
  description = "ID component. The location in which the resources reside (Azure). Allowed values: `global`, `eus`, `eus2`, `cus`, `wus`, `wus2`, `scus`"
  validation {
    condition     = var.location == null ? true : contains(["global", "eus", "eus2", "cus", "wus", "wus2", "scus"], var.location)
    error_message = "Allowed values: `global`, `eus`, `eus2`, `cus`, `wus`, `wus2`, `scus`."
  }
}

variable "location_full" {
  type        = string
  default     = null
  description = "ID component. The location in which the resources reside (full name). Allowed values: `eastus`, `eastus2`, `centralus`, `westus`, `westus2`, `southcentralus`"
  validation {
    condition     = var.location_full == null ? true : contains(["eastus", "eastus2", "centralus", "westus", "westus2", "southcentralus"], var.location_full)
    error_message = "Allowed values: `eastus`, `eastus2`, `centralus`, `westus`, `westus2`, `southcentralus`."
  }
}

variable "env" {
  type        = string
  default     = null
  description = "ID element. Usually used to indicate role, e.g. 'prod', 'preprod', 'stg', 'dev', 'sbx', 'sdlc'"
  validation {
    condition     = var.env == null ? true : contains(["prod", "preprod", "stg", "dev", "sdlc", "sbx", "global", "sales"], var.env)
    error_message = "Allowed values: `prod`, `preprod`, `stg`, `dev`, `sdlc`, `sbx`, `global`, `sales`."
  }
}

variable "vertical" {
  type        = string
  default     = null
  description = "The vertical associated with these resources.  Used in cost reporting."
  validation {
    condition     = var.vertical == null ? true : contains(["chiro", "ortho", "vis", "well", "mkt", "shared", "corp", "sandbox"], var.vertical)
    error_message = "Allowed values: `chiro`, `ortho`, `vis`, `well`, `mkt`, `shared`, `corp`, `sandbox`."
  }
}

variable "brand" {
  type        = string
  default     = null
  description = "The brand(s) to which these resources is related.  Comma separated list if more than one."
  validation {
    condition = var.brand == null ? true : contains([
      "ct",
      "ctc",
      "acom",
      "csd",
      "cs360",
      "rev",
      "ora",
      "om",
      "erx",
      "mt",
      "vdlp",
      "tops",
      "cs",
      "pq",
      "iq",
      "doc",
      "gdge",
      "gp",
      "incp",
      "zing",
      "ptrk"
    ], var.brand)
    error_message = "Allowed values: `ct`, `ctc`, `acom`, `csd`, `cs360`, `rev`, `ora`, `om`, `erx`, `mt`, `vdlp`, `tops`, `cs`, `pq`, `iq`, `doc`, `gdge`, `gp`, `incp`, `zing`, `ptrk`."
  }
}

variable "resource" {
  type    = string
  default = null

  description = "The resource(s) to which label is related.  Comma separated list if more than one."
}
# variable "data_classification" {
#   type    = string
#   default = null

#   description = "The classication of the data interacting with this resource"
#   validation {
#     condition     = var.data_classification == null ? true : contains(["0", "1", "2", "3", "4", "5"], var.data_classification)
#     error_message = "Allowed values: `0`,`1`,`2`,`3`,`4`,`5`."
#   }
# }

# variable "role" {
#   type        = string
#   default     = null
#   description = "The role these resources fullfill. Examples: webserver, customerdb"
# }

# variable "service" {
#   type        = string
#   default     = null
#   description = "The service being provided to the brand.  Ex: auth, logging, tracking"
# }
