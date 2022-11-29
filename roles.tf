locals {
  roles = {
    "LOADER" = {
      comment = "Owns the tables in raw schema"
      users   = ["HAVI"]
    }
    "TRANSFORMER" = {
      comment = "Has query permissions on tables in raw schema and owns tables in the analytics schema."
      users   = ["INIESTA", "PIQUE"]
    }
  }

  raw_roles = yamldecode(file("roles.yml"))["roles"]
  roles_from_yml = {
    for role_name, parameters in(merge(local.raw_roles...)):
      "${role_name}" => parameters
  }

}

resource "snowflake_role" "role" {
  for_each = local.roles_from_yml
  name     = each.key
  comment  = each.value.comment[0]
}

resource "snowflake_role_grants" "role_grant" {
  for_each  = local.roles_from_yml
  role_name = each.key
  users     = each.value.users
  roles     = []
}