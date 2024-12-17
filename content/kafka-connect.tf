locals {
  topics = {
    "ConsumptionIndustry"             = true
    "ProductionConsumptionSettlement" = true
  }
}

resource "kafka-connect_connector" "hdfs-sink-avro" {
  for_each = local.topics

  name = "hdfs-sink-avro-${each.key}"

  config = {
    "name"                                = "hdfs-sink-avro-${each.key}",
    "connector.class"                     = "io.confluent.connect.hdfs.HdfsSinkConnector",
    "tasks.max"                           = "10",
    "topics"                              = each.key,
    "hdfs.url"                            = "hdfs://namenode:9000",
    "flush.size"                          = "5",
    "rotate.interval.ms"                  = "3600000", # 1 hour
    "format.class"                        = "io.confluent.connect.hdfs.avro.AvroFormat",
    "key.converter.schemas.enable"        = "false",
    "key.converter"                       = "org.apache.kafka.connect.storage.StringConverter",
    "key.converter.schema.registry.url"   = "http://kafka-schema-registry:8081",
    "value.converter.schemas.enable"      = "false",
    "value.converter.schema.registry.url" = "http://kafka-schema-registry:8081",
    "value.converter"                     = "io.confluent.connect.avro.AvroConverter"
  }
}

resource "kafka-connect_connector" "hdfs-sink-parquet" {
  for_each = local.topics

  name = "hdfs-sink-parquet-${each.key}"

  config = {
    "name"                                = "hdfs-sink-parquet-${each.key}",
    "connector.class"                     = "io.confluent.connect.hdfs.HdfsSinkConnector",
    "tasks.max"                           = "5",
    "topics"                              = each.key,
    "hdfs.url"                            = "hdfs://namenode:9000",
    "flush.size"                          = "5000",
    "rotate.interval.ms"                  = "3600000", # 1 hour
    "format.class"                        = "io.confluent.connect.hdfs.parquet.ParquetFormat",
    "key.converter.schemas.enable"        = "false",
    "key.converter"                       = "org.apache.kafka.connect.storage.StringConverter",
    "key.converter.schema.registry.url"   = "http://kafka-schema-registry:8081",
    "value.converter.schemas.enable"      = "false",
    "value.converter.schema.registry.url" = "http://kafka-schema-registry:8081",
    "value.converter"                     = "io.confluent.connect.avro.AvroConverter"
  }
}
