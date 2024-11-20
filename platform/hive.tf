resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = var.namespace
  version    = "12.1.5"

  set {
    name  = "auth.username"
    value = "root"
  }

  set {
    name  = "auth.password"
    value = "pwd1234"
  }

  set {
    name  = "auth.database"
    value = "hive"
  }

  set {
    name  = "primary.extendedConfiguration"
    value = "password_encryption=md5"
  }
}

resource "kubernetes_config_map" "hive_metastore_config" {
  metadata {
    name      = "hive-metastore-config"
    namespace = var.namespace
    labels = {
      app = "hive-metastore"
    }
  }

  data = {
    "metastore-site.xml" = <<-EOT
      <configuration>
          <!-- Hive Metastore configuration -->
          <property>
              <name>metastore.task.threads.always</name>
              <value>org.apache.hadoop.hive.metastore.events.EventCleanerTask</value>
          </property>
          <property>
              <name>metastore.expression.proxy</name>
              <value>org.apache.hadoop.hive.metastore.DefaultPartitionExpressionProxy</value>
          </property>
          <property>
              <name>metastore.storage.schema.reader.impl</name>
              <value>org.apache.hadoop.hive.metastore.SerDeStorageSchemaReader</value>
          </property>
          <property>
              <name>metastore.metastore.event.db.notification.api.auth</name>
              <value>false</value>
          </property>    
          
          <!-- Hive configuration -->
          <property>
              <name>hive.metastore.uris</name>
              <value>thrift://hive-metastore:9083</value>
          </property>
          <property>
              <name>datanucleus.autoCreateSchema</name>
              <value>true</value>
          </property>
          <property>
              <name>hive.metastore.schema.verification</name>
              <value>true</value>
          </property>
          <property>
              <name>hive.metastore.warehouse.dir</name>
              <value>/user/hive/warehouse</value>
              <description>Location of default database for the warehouse</description>
          </property>
          
          <!-- PostgresSQL configuration -->
          <property>
              <name>javax.jdo.option.ConnectionURL</name>
              <value>jdbc:postgresql://postgresql:5432/hive</value>
          </property>
          <property>
              <name>javax.jdo.option.ConnectionDriverName</name>
              <value>org.postgresql.Driver</value>
          </property>
          <property>
              <name>javax.jdo.option.ConnectionUserName</name>
              <value>root</value>
          </property>
          <property>
              <name>javax.jdo.option.ConnectionPassword</name>
              <value>pwd1234</value>
          </property>
          
          <!-- Hadoop Configuration -->
          <property>
              <name>fs.defaultFS</name>
              <value>hdfs://namenode:9000</value>
          </property>
          <property>
              <name>hadoop.http.staticuser.user</name>
              <value>root</value>
          </property>
          <property>
              <name>hadoop.proxyuser.hive.hosts</name>
              <value>*</value>
          </property>
          <property>
              <name>hadoop.proxyuser.hive.groups</name>
              <value>*</value>
          </property>
          <property>
              <name>hadoop.proxyuser.hive.users</name>
              <value>*</value>
          </property>    
          <property>
              <name>dfs.client.use.datanode.hostname</name>
              <value>true</value>
          </property>
          <property>
              <name>dfs.replication</name>
              <value>3</value>
          </property>
          
          <!-- S3A Configuration
          <property>
              <name>fs.defaultFS</name>
              <value>s3a://minio:9000</value>
          </property>
          <property>
              <name>fs.s3a.connection.ssl.enabled</name>
              <value>false</value>
          </property>
          <property>
              <name>fs.s3a.impl</name>
              <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
          </property>
          <property>
              <name>fs.s3a.endpoint</name>
              <value>http://minio:9000</value>
          </property>
          <property>
              <name>fs.s3a.access.key</name>
              <value>admin</value>
          </property>
          <property>
              <name>fs.s3a.secret.key</name>
              <value>password</value>
          </property>
          <property>
              <name>fs.s3a.path.style.access</name>
              <value>true</value>
          </property>
          -->
      </configuration>
    EOT

    "metastore-log4j2.properties" = <<-EOT
      # Define the root logger with a console appender
       log4j.rootLogger = INFO, console
      
       # Console appender configuration
       log4j.appender.console = org.apache.log4j.ConsoleAppender
       log4j.appender.console.target = System.out
       log4j.appender.console.layout = org.apache.log4j.PatternLayout
       log4j.appender.console.layout.ConversionPattern = %d{ISO8601} [%t] %-5p %c{2} - %m%n
      
       # Set the logging level for specific categories
       log4j.logger.org.apache.hadoop = WARN
    EOT
  }

  depends_on = [
    helm_release.postgresql
  ]
}

resource "kubernetes_config_map" "hive_metastore_entrypoint" {
  metadata {
    name      = "hive-metastore-entrypoint"
    namespace = var.namespace
    labels = {
      app = "hive-metastore"
    }
  }

  data = {
    "entrypoint.sh" = <<-EOT
      #!/bin/bash
    
      export HADOOP_VERSION=3.3.1
      export METASTORE_VERSION=3.1.2
      export AWS_SDK_VERSION=1.11.901
      export LOG4J_VERSION=2.8.2
      
      export JAVA_HOME=/usr/local/openjdk-8
      export HADOOP_HOME=/opt/hadoop-$${HADOOP_VERSION}
      export HADOOP_CLASSPATH=$${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-$${AWS_SDK_VERSION}.jar:$${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-$${HADOOP_VERSION}.jar:$${HIVE_HOME}/lib/log4j-core-$${LOG4J_VERSION}.jar:$${HIVE_HOME}/lib/log4j-api-$${LOG4J_VERSION}.jar:$${HIVE_HOME}/lib/log4j-1.2-api-$${LOG4J_VERSION}.jar:$${HIVE_HOME}/lib/log4j-slf4j-impl-$${LOG4J_VERSION}.jar
      export HIVE_HOME=/opt/apache-hive-metastore-$${METASTORE_VERSION}-bin
      
      # Check if schema exists
      $${HIVE_HOME}/bin/schematool -dbType postgres -info
    
      if [ $? -eq 1 ]; then
        echo "Getting schema info failed. Probably not initialized. Initializing..."
        $${HIVE_HOME}/bin/schematool -dbType postgres -initSchema
      fi
    
      $${HIVE_HOME}/bin/start-metastore
    EOT
  }

  depends_on = [
    helm_release.postgresql
  ]
}

resource "kubernetes_deployment" "hive_metastore" {
  metadata {
    name      = "hive-metastore"
    namespace = var.namespace
    labels = {
      app = "hive-metastore"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "hive-metastore"
      }
    }

    template {
      metadata {
        labels = {
          app = "hive-metastore"
        }
      }

      spec {
        init_container {
          name    = "init-wait-db"
          image   = "busybox:latest"
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
              until nc -z -v -w90 postgresql 5432; do
                echo "Waiting for Hive Metastore DB to be ready..."
                sleep 5
              done
            EOT
          ]
        }

        container {
          name    = "metastore"
          image   = "rtdl/hive-metastore:3.1.2"
          command = ["bash", "entrypoint/entrypoint.sh"]

          port {
            container_port = 9083
            name           = "thrift"
          }

          volume_mount {
            name       = "hive-config"
            mount_path = "/opt/apache-hive-metastore-3.1.2-bin/conf"
          }

          volume_mount {
            name       = "entrypoint"
            mount_path = "/opt/entrypoint"
          }
        }

        volume {
          name = "hive-config"

          config_map {
            name = kubernetes_config_map.hive_metastore_config.metadata[0].name
          }
        }

        volume {
          name = "entrypoint"

          config_map {
            name = kubernetes_config_map.hive_metastore_entrypoint.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.hive_metastore_config,
    kubernetes_config_map.hive_metastore_entrypoint
  ]
}

resource "kubernetes_service" "hive_metastore" {
  metadata {
    name      = "hive-metastore"
    namespace = var.namespace
    labels = {
      app = "hive-metastore"
    }
  }

  spec {
    port {
      name        = "thrift"
      port        = 9083
      target_port = 9083
      protocol    = "TCP"
    }

    selector = {
      app = "hive-metastore"
    }
  }

  depends_on = [
    kubernetes_deployment.hive_metastore
  ]
}

resource "kubernetes_persistent_volume_claim" "hive_warehouse_pvc" {
  metadata {
    name      = "hive-warehouse-pvc"
    namespace = var.namespace
    labels = {
      app = "hiveserver2"
    }
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

resource "kubernetes_deployment" "hiveserver2" {
  metadata {
    name      = "hiveserver2"
    namespace = var.namespace
    labels = {
      app = "hiveserver2"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "hiveserver2"
      }
    }

    template {
      metadata {
        labels = {
          app = "hiveserver2"
        }
      }

      spec {
        container {
          name  = "hiveserver2"
          image = "apache/hive:3.1.3"

          env {
            name  = "SERVICE_NAME"
            value = "hiveserver2"
          }

          env {
            name  = "SERVICE_OPTS"
            value = "-Dhive.metastore.uris=thrift://hive-metastore:9083"
          }

          env {
            name  = "IS_RESUME"
            value = "true"
          }

          port {
            container_port = 10000
            name           = "thrift"
          }

          port {
            container_port = 10002
            name           = "http"
          }

          volume_mount {
            name       = "hive-warehouse"
            mount_path = "/opt/hive/data/warehouse"
          }
        }

        volume {
          name = "hive-warehouse"

          persistent_volume_claim {
            claim_name = "hive-warehouse-pvc"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.hive_metastore
  ]
}

resource "kubernetes_service" "hiveserver2" {
  metadata {
    name      = "hiveserver2"
    namespace = var.namespace
    labels = {
      app = "hiveserver2"
    }
  }

  spec {
    port {
      name        = "thrift"
      port        = 10000
      target_port = 10000
      protocol    = "TCP"
    }

    port {
      name        = "http"
      port        = 10002
      target_port = 10002
      protocol    = "TCP"
    }

    selector = {
      app = "hiveserver2"
    }
  }

  depends_on = [
    kubernetes_deployment.hiveserver2
  ]
}
