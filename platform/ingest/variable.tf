variable "name" {
  description = "The name of the ingest service"
  type        = string
}

variable "endpoint_url" {
  description = "The URL of the endpoint to be ingested"
  type        = string
}

variable "namespace" {
  description = "The namespace to deploy the ingest services to"
  type        = string
}

variable "image" {
  description = "The image to use for the ingest services"
  type        = string
}

variable "order_by" {
  description = "The order by field for the endpoint"
  type        = string
}

variable "kafka_topic" {
  description = "The Kafka topic to send the data to"
  type        = string
}

variable "redis_host" {
  description = "The host of the Redis instance"
  type        = string
}

variable "redis_db" {
  description = "The Redis database to use"
  type        = number
}
