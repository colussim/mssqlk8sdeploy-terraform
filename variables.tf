variable "name" {
  default     = "mssql-deployment-student1"
  description = "The name of the MySQL deployment"
}
variable "namespace" {
  default     = "student1"
  description = "The kubernetes namespace to run the mssql server in."
}

variable "selectors" {
  type = map(string)
  default = {}
}

variable "labels" {
  type = map(string)
  default = {}
}

variable "pvc" {
  default     = "pvc-sql-data01"
  description = "The name of the PVC."
}

variable "mssql_pvc_size" {
  default     = "50Gi"
  description = "The storage size of the PVC"
}

variable "mssql_storage_class" {
  description = "The k8s storage class for the PVC used."
  default = "sql-sc-1"
}

variable "mssql_image_url" {
  default = "mcr.microsoft.com/mssql/rhel/server"
  description = "The image url of the mssql version wanted"
}

variable "mssql_image_tag" {
  default = "2019-latest"
  description = "The image tag of the mssql version wanted"
}

variable "adminpassword" {
  default     = "HPeinvent@"
  description = "SA Password"
}

