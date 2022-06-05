#module "iam" {
#  source                = "./modules/iam"
#}

module "network" {
  source                = "./modules/network"
#  depends_on = [
#    module.iam
#  ]
}
module "compute" {
  source                = "./modules/compute"
  depends_on = [
    module.network
  ]
}