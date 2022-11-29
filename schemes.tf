locals {
  schemas = {
    "RAW" = {
      database    = "DEV"
      comment     = "contains raw data from our source systems"
      usage_roles = ["TRANSFORMER"]
      all_roles   = ["LOADER"]
    }
    "ANALYTICS" = {
      database    = "DEV"
      comment     = "contains tables and views accessible to analysts and reporting"
      usage_roles = []
      all_roles   = ["TRANSFORMER"]
    }
  }

  raw_schemes = yamldecode(file("schemes.yml"))["schemes"]
  schemas_from_yml = {
    for scheme_name, parameters in(merge(local.raw_schemes...)):
      "${scheme_name}" => parameters
  }

}

output "raw_schemas" {
  value = local.raw_schemes
}

output "schemas_from_yml" {
  value = local.schemas_from_yml
}

resource "snowflake_schema" "schema" {
  for_each = local.schemas_from_yml
  name     = each.key
  database = each.value.database[0]
  comment  = each.value.comment[0]
}

resource "snowflake_schema_grant" "schema_grant_usage" {
  for_each      = local.schemas_from_yml
  schema_name   = each.key
  database_name = each.value.database[0]
  privilege     = "USAGE"
  roles         = each.value.usage_roles
  shares        = []
}

resource "snowflake_schema_grant" "schema_grant_all" {
  for_each      = local.schemas_from_yml
  schema_name   = each.key
  database_name = each.value.database[0]
  privilege     = "OWNERSHIP" # SHOULD BE ALL
  roles         = each.value.all_roles
  shares        = []
}