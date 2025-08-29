output "id" {
  value       = local.enabled ? local.id : ""
  description = "Disambiguated ID string restricted to `id_length_limit` characters in total"
}

output "id_full" {
  value       = local.enabled ? local.id_full : ""
  description = "ID string not restricted in length"
}

output "id_simple" {
  value       = local.enabled ? local.id_simple : ""
  description = "ID string minus region and environment info.  Useful for things such as IAM user/role names"
}

output "enabled" {
  value       = local.enabled
  description = "True if module is enabled, false otherwise"
}

output "org" {
  value       = local.enabled ? local.org : ""
  description = "Normalized org"
}

output "team" {
  value       = local.enabled ? local.team : ""
  description = "Normalized team"
}

output "env" {
  value       = local.enabled ? local.env : ""
  description = "Normalized env"
}

output "name" {
  value       = local.enabled ? local.name : ""
  description = "Normalized name"
}

output "region" {
  value       = local.enabled ? local.region : ""
  description = "Normalized region"
}

output "region_full" {
  value       = local.enabled ? local.region_full : ""
  description = "Full region"
}

output "location" {
  value       = local.enabled ? local.location : ""
  description = "Normalized location"
}

output "location_full" {
  value       = local.enabled ? local.location_full : ""
  description = "Full location"
}

output "delimiter" {
  value       = local.enabled ? local.delimiter : ""
  description = "Delimiter between `org`, `team`, `env`, `region`, `name` and `attributes`"
}

output "attributes" {
  value       = local.enabled ? local.attributes : []
  description = "List of attributes"
}

output "tags" {
  value       = local.enabled ? local.tags : {}
  description = "Normalized Tag map"
}

output "additional_tag_map" {
  value       = local.additional_tag_map
  description = "The merged additional_tag_map"
}

output "label_order" {
  value       = local.label_order
  description = "The naming order actually used to create the ID"
}

output "regex_replace_chars" {
  value       = local.regex_replace_chars
  description = "The regex_replace_chars actually used to create the ID"
}

output "id_length_limit" {
  value       = local.id_length_limit
  description = "The id_length_limit actually used to create the ID, with `0` meaning unlimited"
}

output "tags_as_list_of_maps" {
  value       = local.tags_as_list_of_maps
  description = <<-EOT
    This is a list with one map for each `tag`. Each map contains the tag `key`,
    `value`, and contents of `var.additional_tag_map`. Used in the rare cases
    where resources need additional configuration information for each tag.
    EOT
}

# output "descriptors" {
#   value       = local.descriptors
#   description = "Map of descriptors as configured by `descriptor_formats`"
# }

output "normalized_context" {
  value       = local.output_context
  description = "Normalized context of this module"
}

output "context" {
  value       = local.input
  description = <<-EOT
  Merged but otherwise unmodified input to this module, to be used as context input to other modules.
  Note: this version will have null values as defaults, not the values actually used as defaults.
EOT
}

output "brand" {
  value       = local.brand
  description = "The brand(s) to which these resources is related.  Comma separated list if more than one."
}
