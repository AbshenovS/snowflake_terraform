locals {
  users = {
    "INIESTA" = {
      login_name = "MAC_DATAENGINEER@CLOUDY.COM"
      role       = "TRANSFORMER"
      namespace  = "DEV.PUBLIC"
      warehouse  = "TRANSFORMER_WH"
    }
    "PIQUE" = {
      login_name = "CHEESE_DATAENGINEER@CLOUDY.COM"
      role       = "TRANSFORMER"
      namespace  = "DEV.PUBLIC"
      warehouse  = "TRANSFORMER_WH"
    }
    "HAVI" = {
      login_name = "STITCH_ANALYST@CLOUDY.COM"
      role       = "LOADER"
      namespace  = "DEV.PUBLIC"
      warehouse  = "LOADER_WH"
    }
  }

  raw_users = yamldecode(file("users.yml"))["users"]
  users_from_yml = {
    for user_name, parameters in(merge(local.raw_users...)):
      "${user_name}" => {for parameter_name, parameter_value in(parameters):
                           parameter_name => "${parameter_value[0]}"}
  }
}

output "users_from_yml" {
  value = local.users_from_yml
}

resource "snowflake_user" "user" {
  for_each             = local.users_from_yml
  name                 = each.key
  login_name           = each.value.login_name
  default_role         = each.value.role
  default_namespace    = each.value.namespace
  default_warehouse    = each.value.warehouse
  must_change_password = false
}

