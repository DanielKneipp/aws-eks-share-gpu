resource "kubernetes_deployment" "resnet_deployment" {
  metadata {
    name = "resnet-deployment"
  }

  wait_for_rollout = false

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "resnet-server"
      }
    }

    strategy {
      type = "Recreate"
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
              cpu                      = "1024m"
              memory                   = "4Gi"
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
