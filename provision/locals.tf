# list of passwords to generate for the Ansible vault
locals {
  passwords = flatten([
    "one",
    "two",
    "three",
  ])
}

