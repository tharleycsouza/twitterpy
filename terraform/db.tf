variable "engine" {
  description = "The database engine"
  type = string
  default = "mysql"
}
variable "allocated_storage" {
  description = "The amount of allocated storage."
  type = number
  default = 50
}

variable "max_allocated_storage" {
  description = "The max amount of allocated storage."
  type = number
  default = 100
}

variable "storage_type" {
  description = "type of the storage"
  type = string
  default = "gp2"
}
variable "username" {
  description = "Username for the master DB user."
  default = "twitterpy"
  type = string
}
variable "password" {
  description = "password of the database"
  default = "twitterpy"
  type = string
}
variable "instance_class" {
  description = "The RDS instance class"
  default = "db.t2.micro"
  type = string
}
variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate"
  default = "default.mysql5.7"
  type = string
}
variable "engine_version" {
  description = "The engine version"
  default = "5.7"
  type = number
}

variable "name" {
  description = "The database name"
  default = "twitterpy"
  type = string
}
