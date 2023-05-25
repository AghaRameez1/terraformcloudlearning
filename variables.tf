variable "tags" {
  type        = string
  description = "Enter Tags for resources"
  default     = "agharameez"
}


variable "cidr_block" {
  type        = string
  description = "cidr block for vpc"
  default     = "10.0.0.0/16"
}

#map of maps for create subnets
variable "publicprefix" {
  type = map(any)
  default = {
    sub-1 = {
      az   = "eu-west-1a"
      cidr = "10.0.2.0/24"
    },
    sub-2 = {
      az   = "eu-west-1b"
      cidr = "10.0.3.0/24"
    },
    sub-3 = {
      az   = "eu-west-1c"
      cidr = "10.0.4.0/24"
    }
  }
}

variable "privateprefix" {
  type = map(any)
  default = {
    sub-1 = {
      az   = "eu-west-1a"
      cidr = "10.0.5.0/24"
    },
    sub-2 = {
      az   = "eu-west-1b"
      cidr = "10.0.6.0/24"
    },
    sub-3 = {
      az   = "eu-west-1c"
      cidr = "10.0.7.0/24"
    }
  }
}
