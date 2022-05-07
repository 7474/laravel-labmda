variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
  sensitive   = true
}

variable "name" {
  description = "Resource Name"
  default     = "laravel-lambda"
}

variable "laravel_app_key" {
  sensitive = true
}