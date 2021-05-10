variable "profile" {
  default = "default"
}

variable "name" {
  default = "max1"
}

variable "owner" {
  default = "maxim shishkarev"
}

variable "region" {
  default = "us-east-2"
}

variable "region_short" {
  default = "use2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "zones" {
  type    = list
  default = ["a", "b", "c"]
}

variable "igw_default_route" {
  default = "0.0.0.0/0"
}

variable "ssh_user" {
  default = "ec2-user@"
}

variable "ec2_key_name" {
  default = "maxim.shishkarev"
}

variable "ec2_ext_ip" {
  default = true
}

variable "myip" {
  default = "127.0.0.1"
}

variable "anyip" {
  default = "0.0.0.0/0"
}

variable "eks_version" {
  default = "1.18"
}

variable "eks_private_endpoint" {
  default = true
}

variable "eks_public_endpoint" {
  default = true
}

variable "eks_worker_ami_type" {
  default = "AL2_x86_64"
}

variable "eks_worker_capacity_type" {
  default = "ON_DEMAND"
}

variable "eks_workers_instance_types" {
  default = ["t3.micro"]
  type = list
}

variable "eks_workers_disk" {
  default = "20"
}

variable "eks_workers_desired" {
  default = 3
}

variable "eks_workers_max" {
  default = 6
}

variable "eks_workers_min" {
  default = 1
}