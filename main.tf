module "dynamic-vpc" {
  source        = "./modules/vpc"
  cidr_block    = var.cidr_block
  tags          = var.tags
  publicprefix  = var.publicprefix
  privateprefix = var.privateprefix
  name          = var.name
  nat_gateway   = var.nat_gateway
}


# module "lambdafunction" {
#   source            = "./modules/lambda"
#   agharameezSG      = module.dynamic-vpc.security-group
#   private_subnet_id = module.dynamic-vpc.private_subnet_id
#   tags              = var.tags


# }
