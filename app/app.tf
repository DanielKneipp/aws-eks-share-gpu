resource "kubernetes_deployment" "resnet_deployment" {
  metadata {
    name = "resnet-deployment"
  }

  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      # Trying to ignore diff detect after creating the resource
      # (https://github.com/hashicorp/terraform-provider-kubernetes/issues/1087)
      # but this ignore also doesn't work at current versions
      # TODO: report this
      metadata[0].resource_version, # This keeps changing within the cluster
    ]
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "resnet-server"
      }
    }

    strategy {
      type = "Recreate" # For testing
    }

    template {
      metadata {
        labels = {
          app = "resnet-server"
        }
      }

      spec {
        volume {
          name = "nvidia-mps"

          host_path {
            path = "/tmp/nvidia-mps"
          }
        }

        container {
          name  = "resnet-container"
          image = "seedjeffwan/tensorflow-serving-gpu:resnet"
          args  = ["--per_process_gpu_memory_fraction=0.2"]

          port {
            container_port = 8501
          }

          env {
            name  = "MODEL_NAME"
            value = "resnet"
          }

          resources {
            limits = {
              cpu                      = "700m"
              memory                   = "3Gi"
              "k8s.amazonaws.com/vgpu" = "8" # 48 * 0.2
            }
          }

          volume_mount {
            name       = "nvidia-mps"
            mount_path = "/tmp/nvidia-mps"
          }
        }

        # hostIPC is required for MPS communication
        host_ipc = true
      }
    }
  }
}
