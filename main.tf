###---root/main.tf---

module "network" {
  source        = "./network"
  vpc_cidr      = "10.0.0.0/16"
  access_ip     = "0.0.0.0/0"
  public_cidrs  = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
  private_cidrs = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]
}

module "compute" {
  source         = "./compute"
  public_sg      = module.network.public_sg
  private_sg     = module.network.private_sg
  private_subnet = module.network.private_subnet
  public_subnet  = module.network.public_subnet
  elb            = module.loadbalancing.elb
  cicd_alb_tg    = module.loadbalancing.alb_tg
  key_name       = "ohiokey"

}

module "loadbalancing" {
  source        = "./loadbalancing"
  public_subnet = module.network.public_subnet
  vpc_id        = module.network.vpc_id
  web_sg        = module.network.web_sg
  database_asg  = module.compute.database_asg
}