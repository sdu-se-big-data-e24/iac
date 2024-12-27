locals {
  spark_runners = 10
}

resource "kubernetes_config_map" "spark_job_config" {
  metadata {
    name      = "spark-job-config"
    namespace = var.namespace
  }

  data = {
    "script.py"     = file("../../data-processing/summarize-power-right-now/terraform-script.py")
    "utils.py"      = file("../../data-processing/summarize-power-right-now/src/utils.py")
    "core-site.xml" = <<EOF
    <configuration>
        <property>
            <name>fs.defaultFS</name>
            <value>hdfs://namenode:9000</value>
        </property>
        <property>
            <name>hadoop.security.authentication</name>
            <value>simple</value>
        </property>
        <property>
            <name>hadoop.security.authorization</name>
            <value>false</value>
        </property>
        <property>
            <name>dfs.client.use.datanode.hostname</name>
            <value>true</value>
        </property>
        <property>
            <name>dfs.permissions</name>
            <value>false</value>
        </property>
        <property>
            <name>hadoop.http.staticuser.user</name>
            <value>root</value>
        </property>
        <property>
            <name>hadoop.proxyuser.root.groups</name>
            <value>*</value>
        </property>
        <property>
            <name>hadoop.proxyuser.root.hosts</name>
            <value>*</value>
        </property>
        <property>
            <name>hadoop.user.name</name>
            <value>root</value>
        </property>
        <property>
            <name>hadoop.user.group</name>
            <value>supergroup</value>
        </property>
        <property>
            <name>log4j.logger.org.apache.hadoop.security</name>
            <value>DEBUG</value>
        </property>
    </configuration>
    EOF
  }
}

resource "kubernetes_job" "spark_run_demo" {
  metadata {
    name      = "spark-demo"
    namespace = var.namespace
    labels = {
      app = "spark-demo"
    }
  }

  spec {
    template {
      metadata {
        name = "spark-demo"
        labels = {
          app = "spark-demo"
        }
      }

      spec {
        security_context {
          run_as_user  = 0
          run_as_group = 0
          fs_group     = 0
        }

        container {
          name    = "spark-demo"
          image   = "bitnami/spark:3.5.2-debian-12-r1"
          command = ["sh", "-c"]
          args = [
            <<EOF
            /opt/bitnami/spark/bin/spark-submit \
             --master spark://spark-master-svc:7077 \
             --packages org.apache.spark:spark-avro_2.12:3.5.2 \
             --conf spark.driver.extraJavaOptions=-Duser.home=/root \
             --conf spark.hadoop.conf.dir=/opt/hadoop/etc/hadoop \
             --conf spark.hadoop.security.authentication=simple \
             --conf spark.hadoop.security.authorization=false \
             --conf spark.hadoop.user.name=root \
             /opt/bitnami/spark/examples/script.py ${local.spark_runners};
            EOF
          ]

          env {
            name  = "SPARK_USER"
            value = "spark"
          }
          env {
            name  = "SPARK_LOCAL_DIRS"
            value = "/tmp/spark"
          }
          env {
            name  = "SPARK_CONF_DIR"
            value = "/opt/bitnami/spark/conf"
          }
          env {
            name  = "HOME"
            value = "/root"
          }
          env {
            name  = "HADOOP_USER_NAME"
            value = "root"
          }
          env {
            name  = "HADOOP_OPTS"
            value = "-Djava.security.krb5.conf=/dev/null"
          }
          env {
            name  = "SPARK_JAVA_OPTS"
            value = "-Djava.security.debug=all"
          }
          env {
            name  = "HADOOP_CONF_DIR"
            value = "/opt/hadoop/etc/hadoop"
          }

          volume_mount {
            name       = "scripts"
            mount_path = "/opt/bitnami/spark/examples"
          }
          volume_mount {
            name       = "hadop-conf"
            mount_path = "/opt/hadoop/etc/hadoop/"
          }
          volume_mount {
            name       = "ivy-cache"
            mount_path = "/root/.ivy2"
          }
        }

        volume {
          name = "scripts"
          config_map {
            name = kubernetes_config_map.spark_job_config.metadata[0].name
          }
        }
        volume {
          name = "hadop-conf"
          config_map {
            name = kubernetes_config_map.spark_job_config.metadata[0].name
            items {
              key  = "core-site.xml"
              path = "core-site.xml"
            }
          }
        }
        volume {
          name = "ivy-cache"
          empty_dir {}
        }

        restart_policy = "Never"
      }
    }
    backoff_limit = 2
  }

  # Trigger rebuild if the config map changes
  lifecycle {
    replace_triggered_by = [
      kubernetes_config_map.spark_job_config.data
    ]
  }
}
