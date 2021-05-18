provider "alicloud" {
  #   access_key = "${var.access_key}"
  #   secret_key = "${var.secret_key}"
  region = "ap-southeast-1"
}

variable "name" {
  default = "auto_provisioning_group"
}

######## Security group
resource "alicloud_security_group" "group" {
  name        = "sg_solution_mysql_redis_cache_simple"
  description = "Security group for mysql redis cache sample solution"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_ssh_22" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
}

######## VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.name
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/24"
  zone_id      = data.alicloud_zones.default.zones[0].id
  vswitch_name = var.name
}

######## ECS
resource "alicloud_instance" "instance" {
  security_groups = alicloud_security_group.group.*.id

  # series III
  instance_type              = "ecs.t5-lc1m1.small"
  system_disk_category       = "cloud_efficiency"
  system_disk_name           = "test_foo_system_disk_name"
  system_disk_description    = "test_foo_system_disk_description"
  image_id                   = "aliyun_2_1903_x64_20G_alibase_20200904.vhd"
  instance_name              = "test_foo"
  password                   = "N1cetest" ## Please change accordingly
  vswitch_id                 = alicloud_vswitch.vswitch.id
  internet_max_bandwidth_out = 10
  data_disks {
    name        = "disk2"
    size        = 20
    category    = "cloud_efficiency"
    description = "disk2"
    # encrypted   = true
    # kms_key_id  = alicloud_kms_key.key.id
  }
}

######## Redis
variable "redis_name" {
  default = "redis"
}

variable "creation" {
  default = "KVStore"
}

data "alicloud_zones" "default" {
  available_resource_creation = var.creation
}

resource "alicloud_kvstore_instance" "example" {
  db_instance_name  = "tf-test-basic"
  vswitch_id        = alicloud_vswitch.vswitch.id
  security_group_id = alicloud_security_group.group.id
  instance_type     = "Redis"
  engine_version    = "4.0"
  config = {
    appendonly             = "yes",
    lazyfree-lazy-eviction = "yes",
  }
  tags = {
    Created = "TF",
    For     = "Test",
  }
  resource_group_id = "rg-123456"
  zone_id           = data.alicloud_zones.default.zones[0].id
  instance_class    = "redis.master.micro.default"
}

resource "alicloud_kvstore_account" "example" {
  account_name     = "test_redis"
  account_password = "N1cetest"
  instance_id      = alicloud_kvstore_instance.example.id
}

######## RDS MySQL
variable "rds_mysql_name" {
  default = "rds_mysql"
}

resource "alicloud_db_instance" "instance" {
  engine             = "MySQL"
  engine_version     = "5.7"
  instance_type      = "rds.mysql.s1.small"
  instance_storage   = "10"
  vswitch_id         = alicloud_vswitch.vswitch.id
  security_group_ids = [alicloud_security_group.group.id]
  instance_name      = var.rds_mysql_name
}

resource "alicloud_db_account" "account" {
  db_instance_id   = alicloud_db_instance.instance.id
  account_name     = "test_mysql"
  account_password = "N1cetest"
}

resource "alicloud_db_database" "default" {
  instance_id = alicloud_db_instance.instance.id
  name        = "test_mysql"
}

resource "alicloud_db_account_privilege" "privilege" {
  instance_id  = alicloud_db_instance.instance.id
  account_name = alicloud_db_account.account.name
  privilege    = "ReadWrite"
  db_names     = alicloud_db_database.default.*.name
}
