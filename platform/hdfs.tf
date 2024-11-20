resource "kubernetes_config_map" "hadoop_config" {
  metadata {
    name      = "hadoop-config"
    namespace = var.namespace
  }

  data = {
    CORE_CONF_fs_defaultFS                                                                                = "hdfs://namenode:9000"
    CORE_CONF_hadoop_http_staticuser_user                                                                 = "root"
    CORE_CONF_hadoop_proxyuser_hue_hosts                                                                  = "*"
    CORE_CONF_hadoop_proxyuser_hue_groups                                                                 = "*"
    CORE_CONF_io_compression_codecs                                                                       = "org.apache.hadoop.io.compress.SnappyCodec"
    HDFS_CONF_dfs_webhdfs_enabled                                                                         = "true"
    HDFS_CONF_dfs_permissions_enabled                                                                     = "false"
    HDFS_CONF_dfs_permissions                                                                             = "false"
    HDFS_CONF_dfs_namenode_datanode_registration_ip___hostname___check                                    = "false"
    YARN_CONF_yarn_log___aggregation___enable                                                             = "true"
    YARN_CONF_yarn_log_server_url                                                                         = "http://historyserver:8188/applicationhistory/logs/"
    YARN_CONF_yarn_resourcemanager_recovery_enabled                                                       = "true"
    YARN_CONF_yarn_resourcemanager_store_class                                                            = "org.apache.hadoop.yarn.server.resourcemanager.recovery.FileSystemRMStateStore"
    YARN_CONF_yarn_resourcemanager_scheduler_class                                                        = "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"
    YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___mb                              = "8192"
    YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___vcores                          = "4"
    YARN_CONF_yarn_resourcemanager_fs_state___store_uri                                                   = "/rmstate"
    YARN_CONF_yarn_resourcemanager_system___metrics___publisher_enabled                                   = "true"
    YARN_CONF_yarn_resourcemanager_hostname                                                               = "resourcemanager"
    YARN_CONF_yarn_resourcemanager_address                                                                = "resourcemanager:8032"
    YARN_CONF_yarn_resourcemanager_scheduler_address                                                      = "resourcemanager:8030"
    YARN_CONF_yarn_resourcemanager_resource__tracker_address                                              = "resourcemanager:8031"
    YARN_CONF_yarn_timeline___service_enabled                                                             = "true"
    YARN_CONF_yarn_timeline___service_generic___application___history_enabled                             = "true"
    YARN_CONF_yarn_timeline___service_hostname                                                            = "historyserver"
    YARN_CONF_mapreduce_map_output_compress                                                               = "true"
    YARN_CONF_mapred_map_output_compress_codec                                                            = "org.apache.hadoop.io.compress.SnappyCodec"
    YARN_CONF_yarn_nodemanager_resource_memory___mb                                                       = "16384"
    YARN_CONF_yarn_nodemanager_resource_cpu___vcores                                                      = "8"
    YARN_CONF_yarn_nodemanager_disk___health___checker_max___disk___utilization___per___disk___percentage = "98.5"
    YARN_CONF_yarn_nodemanager_remote___app___log___dir                                                   = "/app-logs"
    YARN_CONF_yarn_nodemanager_aux___services                                                             = "mapreduce_shuffle"
    MAPRED_CONF_mapreduce_framework_name                                                                  = "yarn"
    MAPRED_CONF_mapred_child_java_opts                                                                    = "-Xmx4096m"
    MAPRED_CONF_mapreduce_map_memory_mb                                                                   = "4096"
    MAPRED_CONF_mapreduce_reduce_memory_mb                                                                = "8192"
    MAPRED_CONF_mapreduce_map_java_opts                                                                   = "-Xmx3072m"
    MAPRED_CONF_mapreduce_reduce_java_opts                                                                = "-Xmx6144m"
    MAPRED_CONF_yarn_app_mapreduce_am_env                                                                 = "HADOOP_MAPRED_HOME=/opt/hadoop-3.1.2/"
    MAPRED_CONF_mapreduce_map_env                                                                         = "HADOOP_MAPRED_HOME=/opt/hadoop-3.1.2/"
    MAPRED_CONF_mapreduce_reduce_env                                                                      = "HADOOP_MAPRED_HOME=/opt/hadoop-3.1.2/"
  }
}

resource "kubernetes_stateful_set" "datanode" {
  metadata {
    name      = "datanode"
    namespace = var.namespace
  }

  spec {
    service_name = "datanode"
    replicas     = 3

    selector {
      match_labels = {
        app = "datanode"
      }
    }

    template {
      metadata {
        labels = {
          app = "datanode"
        }
      }

      spec {
        container {
          name  = "datanode"
          image = "bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8"

          port {
            container_port = 9864
          }

          env {
            name  = "SERVICE_PRECONDITION"
            value = "namenode:9870"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.hadoop_config.metadata.0.name
            }
          }

          volume_mount {
            name       = "hadoop-datanode-storage"
            mount_path = "/hadoop/dfs/data"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "hadoop-datanode-storage"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }

    persistent_volume_claim_retention_policy {
      when_deleted = "Delete"
    }
  }

  depends_on = [
    kubernetes_config_map.hadoop_config
  ]
}

resource "kubernetes_service" "datanode" {
  metadata {
    name      = "datanode"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "datanode"
    }

    port {
      name        = "datanode"
      protocol    = "TCP"
      port        = 9864
      target_port = 9864
    }
  }

  depends_on = [
    kubernetes_stateful_set.datanode
  ]
}

resource "kubernetes_stateful_set" "namenode" {
  metadata {
    name      = "namenode"
    namespace = var.namespace
  }

  spec {
    service_name = "namenode"
    replicas     = 1

    selector {
      match_labels = {
        app = "namenode"
      }
    }

    template {
      metadata {
        labels = {
          app = "namenode"
        }
      }

      spec {
        container {
          name  = "namenode"
          image = "bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8"

          port {
            container_port = 9870
          }

          port {
            container_port = 9000
          }

          env {
            name  = "CLUSTER_NAME"
            value = "test"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.hadoop_config.metadata.0.name
            }
          }

          volume_mount {
            name       = "hadoop-namenode-storage"
            mount_path = "/hadoop/dfs/name"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "hadoop-namenode-storage"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }

    persistent_volume_claim_retention_policy {
      when_deleted = "Delete"
    }
  }

  depends_on = [
    kubernetes_config_map.hadoop_config
  ]
}

resource "kubernetes_service" "namenode" {
  metadata {
    name      = "namenode"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "namenode"
    }

    port {
      name        = "web"
      protocol    = "TCP"
      port        = 9870
      target_port = 9870
    }

    port {
      name        = "rpc"
      protocol    = "TCP"
      port        = 9000
      target_port = 9000
    }
  }

  depends_on = [
    kubernetes_stateful_set.namenode
  ]
}
