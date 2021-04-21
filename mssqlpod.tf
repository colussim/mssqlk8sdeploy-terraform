locals {
  labels = merge(var.labels, {
    app = "mssql"
    deploymentName = var.name
  })

  selectors = merge(var.selectors, {
    app = "mssql"
    deploymentName = var.name
  })
}

resource "kubernetes_namespace" "mssql-namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "sqlsecret" {
  metadata {
    name = "sqlsecret"
    namespace= var.namespace
  }

  data = {
	sapassword= var.adminpassword 
  }
  type="Opaque"


}

resource "kubernetes_persistent_volume_claim" "mssql-pvc-student1" {
  metadata {
    name = var.pvc
    namespace = var.namespace
  }
  spec {
    storage_class_name = var.mssql_storage_class
    access_modes = [
      "ReadWriteOnce"
    ]
    resources {
      requests = {
        storage = var.mssql_pvc_size
      }
    }
  }
}



resource "kubernetes_deployment" "mssql-deployment-student1" {
  metadata {
    name = var.name
    namespace = var.namespace
    labels = local.labels
  }

  spec {
    replicas = 1 
    selector {
      match_labels = local.selectors
    }

    template {
      metadata {
        name = "mssql"
        labels = local.labels
      }

      spec {
        volume {
          name = "mssqldb"
          persistent_volume_claim {
            claim_name = var.pvc 
          }
        }
	termination_grace_period_seconds=10
        security_context {
          run_as_user=1003
          fs_group=1003
	}

        container {
          name = "mssql"
          image = "${var.mssql_image_url}:${var.mssql_image_tag}"

          port {
            container_port = 1433 
          }

          volume_mount {
            mount_path = "/var/opt/mssql"
            name = "mssqldb"
          }

          env {
            name = "MSSQL_PID"
            value = "Developer" 
          }

          env {
            name = "ACCEPT_EULA"
            value = "Y" 
          }

          env {
            name = "SA_PASSWORD"
            value_from {
		secret_key_ref {
		   name= "sqlsecret"
		   key= "sapassword"
		}

	    }
          }

        }
      }
    }
  }
}


resource "kubernetes_service" "mssql-deployment-student1" {
  metadata {
    name = "${var.name}-service"
    namespace = var.namespace
  }

  spec {
    port {
      port = 1433 
      target_port = 1433 
    }

    selector = local.selectors

    type = "NodePort"
  }
}

