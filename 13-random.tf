# Create Random Password
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_integer" "rand_int" {
  min = 1000
  max = 9999
}

resource "random_uuid" "avd_uuid" {
}