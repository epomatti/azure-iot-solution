variable "app" {
  type    = string
  default = "dymrobot"
}

variable "location" {
  type    = string
  default = "westus2"
}

variable "iothub_sku_name" {
  type    = string
  default = "F1"
}

variable "iothub_sku_capacity" {
  type    = number
  default = 1
}
