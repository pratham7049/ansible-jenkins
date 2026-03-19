variable "project_name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "cluster_sg_id" { type = string }
variable "node_sg_id" { type = string }
variable "cluster_role_arn" { type = string }
variable "node_role_arn" { type = string }
variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}
variable "desired_capacity" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
