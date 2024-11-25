resource "kafka-connect_connector" "hdfs-sink" {
  name = "hdfs-sink"

  config = {
    "name"                                = "hdfs-sink"
    "connector.class"                     = "io.confluent.connect.hdfs.HdfsSinkConnector",
    "tasks.max"                           = "1",
    "topics"                              = "INGESTION",
    "hdfs.url"                            = "hdfs://namenode:9000",
    "flush.size"                          = "1",
    "format.class"                        = "io.confluent.connect.hdfs.json.JsonFormat",
    "key.converter.schemas.enable"        = "false",
    "key.converter"                       = "org.apache.kafka.connect.storage.StringConverter",
    "key.converter.schema.registry.url"   = "http://kafka-schema-registry:8081",
    "value.converter.schemas.enable"      = "false",
    "value.converter.schema.registry.url" = "http://kafka-schema-registry:8081",
    "value.converter"                     = "org.apache.kafka.connect.json.JsonConverter"
  }
}
