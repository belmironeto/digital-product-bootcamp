module "network" {
  source            = "./modules/network"
}
module "compute" {
  source            = "./modules/compute"
  pub_subnet_totalbus-dev_id  = module.network.pub_subnet_totalbus-dev_id
  priv_subnet_totalbus-dev_id = module.network.priv_subnet_totalbus-dev_id
  security_group    = module.network.sg_totalbus-dev_id
}