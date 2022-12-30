variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "cloud_id" {
  type    = string
  default = ""
}

variable "folder_id" {
  type    = string
  default = ""
}

variable "image_id" {
  type = string

  default = "fd816jiq3n13qtli6fh3" #centos 8 stream
}

variable "yc_token" {
  type    = string
  default = ""
}
