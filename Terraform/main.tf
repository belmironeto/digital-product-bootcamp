module "network" {
  source                = "./modules/network"
}
module "compute" {
  source                = "./modules/compute"
  depends_on = [
    module.network
  ]
}