variable "name" {
  type        = string
  description = "Enter name for resources"
  default     = "agharameez"
}

variable "tags" {
  type = map(any)
  default = {
    Created_by   = "agharameez"
    Envviornment = "dev"

  }
}


variable "cidr_block" {
  type        = string
  description = "cidr block for vpc"
  default     = "10.0.0.0/16"
}

#map of maps for create subnets
variable "publicprefix" {
  type    = list(any)
  default = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.9.0/24", "10.0.14.0/24"]
}

variable "privateprefix" {
  type    = list(any)
  default = ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24", "10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
