variable "name" {
  type = string
}

variable "base_ami_owner" {
  type    = string
  default = "099720109477" // id owner canoical 
}

variable "base_ami_name_filter" {
  type    = string
  default = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}
variable "subnet_id" { type = string }
variable "security_group_ids" { type = list(string) }
