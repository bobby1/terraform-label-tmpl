resource "time_static" "creation" {}

locals {

  # organization_hierarchy = compact([var.org, var.vertical, var.brand, var.team])
  organization_hierarchy = compact([
    var.org != null ? var.org : var.context.org,
    var.vertical != null ? var.vertical : var.context.vertical,
    var.brand != null ? var.brand : var.context.brand,
    var.team != null ? var.team : var.context.team
  ])
  lowest_organizational_context = [for item in local.organization_hierarchy : item if item != ""][length(local.organization_hierarchy) - 1]

  practicetek_auto_tags = {
    "created"    = time_static.creation.id
    "managed-by" = "terraform"
  }

  defaults = {
    org = "pt"
    # The `team` label was introduced in v0.25.0. To preserve backward compatibility, or, really, to ensure
    # that people using the `team` label are alerted that it was not previously supported if they try to
    # use it in an older version, it is not included by default.
    label_order         = ["org_ctx", "env", "region", "location", "resource", "name", "attributes"]
    regex_replace_chars = "/[^-a-zA-Z0-9]/"
    delimiter           = "-"
    replacement         = ""
    id_length_limit     = 0
    id_hash_length      = 5
    label_key_case      = "lower"
    label_value_case    = "lower"

    # The default value of labels_as_tags cannot be included in this
    # defaults` map because it creates a circular dependency
  }

  default_labels_as_tags = keys(local.tags_context)
  # Unlike other inputs, the first setting of `labels_as_tags` cannot be later overridden. However,
  # we still have to pass the `input` map as the context to the next module. So we need to distinguish
  # between the first setting of var.labels_as_tags == null as meaning set the default and do not change
  # it later, versus later settings of var.labels_as_tags that should be ignored. So, we make the
  # default value in context be "unset", meaning it can be changed, but when it is unset and
  # var.labels_as_tags is null, we change it to "default". Once it is set to "default" we will
  # not allow it to be changed again, but of course we have to detect "default" and replace it
  # with local.default_labels_as_tags when we go to use it.
  #
  # We do not want to use null as default or unset, because Terraform has issues with
  # the value of an object field being null in some places and [] in others.
  # We do not want to use [] as default or unset because that is actually a valid setting
  # that we want to have override the default.
  #
  # To determine whether that context.labels_as_tags is not set,
  # we have to cover 2 cases: 1) context does not have a labels_as_tags key, 2) it is present and set to ["unset"]
  context_labels_as_tags_is_unset = try(contains(var.context.labels_as_tags, "unset"), true)

  # So far, we have decided not to allow overriding replacement or id_hash_length
  replacement    = local.defaults.replacement
  id_hash_length = local.defaults.id_hash_length

  # The values provided by variables supersede the values inherited from the context object,
  # except for tags and attributes which are merged.
  input = {
    # It would be nice to use coalesce here, but we cannot, because it
    # is an error for all the arguments to coalesce to be empty.
    enabled = var.enabled == null ? var.context.enabled : var.enabled
    org     = var.org == null ? coalesce(var.context.org, local.defaults.org) : var.org
    # team was introduced in v0.25.0, prior context versions do not have it
    team          = var.team == null ? lookup(var.context, "team", null) : var.team
    env           = var.env == null ? var.context.env : var.env
    region        = var.region == null ? var.context.region : var.region
    location      = var.location == null ? lookup(var.context, "location", null) : var.location
    region_full   = var.region_full == null ? var.context.region_full : var.region_full
    location_full = var.location_full == null ? var.context.location_full : var.location_full
    name          = var.name == null ? var.context.name : var.name
    delimiter     = var.delimiter == null ? var.context.delimiter : var.delimiter
    # modules tack on attributes (passed by var) to the end of the list (passed by context)
    attributes = compact(distinct(concat(coalesce(var.context.attributes, []), coalesce(var.attributes, []))))
    tags       = merge(var.context.tags, var.tags)

    additional_tag_map  = merge(var.context.additional_tag_map, var.additional_tag_map)
    label_order         = var.label_order == null ? var.context.label_order : var.label_order
    regex_replace_chars = var.regex_replace_chars == null ? var.context.regex_replace_chars : var.regex_replace_chars
    id_length_limit     = var.id_length_limit == null ? var.context.id_length_limit : var.id_length_limit
    label_key_case      = var.label_key_case == null ? lookup(var.context, "label_key_case", null) : var.label_key_case
    label_value_case    = var.label_value_case == null ? lookup(var.context, "label_value_case", null) : var.label_value_case

    descriptor_formats = merge(lookup(var.context, "descriptor_formats", {}), var.descriptor_formats)
    labels_as_tags     = local.context_labels_as_tags_is_unset ? var.labels_as_tags : var.context.labels_as_tags

    # data_classification = var.data_classification == null ? var.context.data_classification : var.data_classification
    resource = var.resource == null ? var.context.resource : var.resource
    brand    = var.brand == null ? var.context.brand : var.brand
    vertical = var.vertical == null ? var.context.vertical : var.vertical
  }


  enabled             = local.input.enabled
  regex_replace_chars = coalesce(local.input.regex_replace_chars, local.defaults.regex_replace_chars)

  # string_label_names are names of inputs that are strings (not list of strings) used as labels
  string_label_names = ["org", "brand", "vertical", "team", "env", "region", "region_full", "location", "location_full", "name", "resource"]
  #   string_label_names = ["org", "team", "env", "region", "name", "brand", "data_classification", "vertical"]
  normalized_labels = { for k in local.string_label_names : k =>
    local.input[k] == null ? "" : replace(local.input[k], local.regex_replace_chars, local.replacement)
  }
  normalized_attributes = compact(distinct([for v in local.input.attributes : replace(v, local.regex_replace_chars, local.replacement)]))

  formatted_labels = { for k in local.string_label_names : k => local.label_value_case == "none" ? local.normalized_labels[k] :
    local.label_value_case == "title" ? title(lower(local.normalized_labels[k])) :
    local.label_value_case == "upper" ? upper(local.normalized_labels[k]) : lower(local.normalized_labels[k])
  }

  attributes = compact(distinct([
    for v in local.normalized_attributes : (local.label_value_case == "none" ? v :
      local.label_value_case == "title" ? title(lower(v)) :
    local.label_value_case == "upper" ? upper(v) : lower(v))
  ]))

  org           = local.formatted_labels["org"]
  team          = local.formatted_labels["team"]
  env           = local.formatted_labels["env"]
  region        = local.formatted_labels["region"]
  location      = local.formatted_labels["location"]
  region_full   = local.formatted_labels["region_full"]
  location_full = local.formatted_labels["location_full"]
  name          = local.formatted_labels["name"]
  brand         = local.formatted_labels["brand"]
  resource      = local.formatted_labels["resource"]
  #   data_classification = local.formatted_labels["data_classification"]
  vertical = local.formatted_labels["vertical"]

  delimiter   = local.input.delimiter == null ? local.defaults.delimiter : local.input.delimiter
  label_order = local.input.label_order == null ? local.defaults.label_order : coalescelist(local.input.label_order, local.defaults.label_order)
  # Ensure label_order only contains valid keys
  valid_label_order = [for l in local.label_order : l if contains(["org_ctx", "org", "team", "env", "region", "location", "name", "brand", "resource", "vertical", "attributes"], l)]
  id_length_limit   = local.input.id_length_limit == null ? local.defaults.id_length_limit : local.input.id_length_limit
  label_key_case    = local.input.label_key_case == null ? local.defaults.label_key_case : local.input.label_key_case
  label_value_case  = local.input.label_value_case == null ? local.defaults.label_value_case : local.input.label_value_case

  # labels_as_tags is an exception to the rule that input vars override context values (see above)
  labels_as_tags = contains(local.input.labels_as_tags, "default") ? local.default_labels_as_tags : local.input.labels_as_tags

  # Just for standardization and completeness
  descriptor_formats = local.input.descriptor_formats

  additional_tag_map = merge(var.context.additional_tag_map, var.additional_tag_map)

  # tags = merge(local.generated_tags, local.input.tags)
  tags = {
    for key, value in merge(local.generated_tags, local.input.tags, local.practicetek_auto_tags) : "${key}" => value if value != null
  }

  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key   = key
        value = local.tags[key]
    }, local.additional_tag_map)
  ])

  tags_context = {
    # org = var.org != local.org ? local.org : ""
    org      = local.org
    team     = local.team
    env      = local.env
    region   = local.region
    location = local.location
    # For AWS we need `Name` to be disambiguated since it has a special meaning
    # name       = local.id
    attributes = local.id_context.attributes
    brand      = local.brand
    # data_classification = local.data_classification
    vertical = local.vertical
  }
  ## Can we use this to change auto_generated tag case too? 
  # generated_auto_tags = {
  #   for l in setintersection(keys(local.practicetek_auto_tags), local.labels_as_tags) :
  #   local.label_key_case == "upper" ? upper(l) : (
  #     local.label_key_case == "lower" ? lower(l) : title(lower(l))
  #   ) => local.practicetek_auto_tags[l] if length(local.practicetek_auto_tags[l]) > 0
  # }

  generated_tags = {
    for l in setintersection(keys(local.tags_context), local.labels_as_tags) :
    local.label_key_case == "upper" ? upper(l) : (
      local.label_key_case == "lower" ? lower(l) : title(lower(l))
    ) => local.tags_context[l] if length(local.tags_context[l]) > 0
  }

  id_context = {
    org_ctx = local.lowest_organizational_context
    org     = local.org
    # org         = local.lowest_organizational_context != local.org ? local.lowest_organizational_context : local.org
    team       = local.team
    env        = local.env
    region     = local.region
    location   = local.location
    name       = local.name
    brand      = local.brand
    resource   = local.resource
    vertical   = local.vertical
    attributes = join(local.delimiter, local.attributes)
  }

  labels = [for l in local.valid_label_order : try(local.id_context[l], "") if try(local.id_context[l], "") != ""]

  id_full = join(local.delimiter, local.labels)
  # Create a truncated ID if needed
  delimiter_length = length(local.delimiter)
  # Calculate length of normal part of ID, leaving room for delimiter and hash
  id_truncated_length_limit = local.id_length_limit - (local.id_hash_length + local.delimiter_length)
  # Truncate the ID and ensure a single (not double) trailing delimiter
  id_truncated = local.id_truncated_length_limit <= 0 ? "" : "${trimsuffix(substr(local.id_full, 0, local.id_truncated_length_limit), local.delimiter)}${local.delimiter}"
  # Support usages that disallow numeric characters. Would prefer tr 0-9 q-z but Terraform does not support it.
  # Probably would have been better to take the hash of only the characters being removed,
  # so identical removed strings would produce identical hashes, but it is not worth breaking existing IDs for.
  id_hash_plus = "${md5(local.id_full)}qrstuvwxyz"
  id_hash_case = local.label_value_case == "title" ? title(local.id_hash_plus) : local.label_value_case == "upper" ? upper(local.id_hash_plus) : local.label_value_case == "lower" ? lower(local.id_hash_plus) : local.id_hash_plus
  id_hash      = replace(local.id_hash_case, local.regex_replace_chars, local.replacement)
  # Create the short ID by adding a hash to the end of the truncated ID
  id_short = substr("${local.id_truncated}${local.id_hash}", 0, local.id_length_limit)
  id       = local.id_length_limit != 0 && length(local.id_full) > local.id_length_limit ? local.id_short : local.id_full
  # Create a simple id
  simple_label_order = ["org_ctx", "name", "attributes"]
  simple_labels      = [for l in local.simple_label_order : local.id_context[l] if length(local.id_context[l]) > 0]
  id_simple          = join(local.delimiter, local.simple_labels)

  # Context of this label to pass to other label modules
  output_context = {
    enabled             = local.enabled
    org_ctx             = local.lowest_organizational_context
    org                 = local.org
    team                = local.team
    env                 = local.env
    region              = local.region
    region_full         = local.region_full
    location            = local.location
    location_full       = local.location_full
    name                = local.name
    delimiter           = local.delimiter
    attributes          = local.attributes
    tags                = local.tags
    additional_tag_map  = local.additional_tag_map
    label_order         = local.label_order
    regex_replace_chars = local.regex_replace_chars
    id_length_limit     = local.id_length_limit
    label_key_case      = local.label_key_case
    label_value_case    = local.label_value_case
    labels_as_tags      = local.labels_as_tags
    descriptor_formats  = local.descriptor_formats
    brand               = local.brand
    resource            = local.resource
    # data_classification = local.data_classification
    vertical = local.vertical
  }

}
