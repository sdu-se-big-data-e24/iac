locals {
  ingest_endpoints = {
    production_and_consumption_settlement = {
      name         = "production-and-consumption-settlement"
      endpoint_url = "https://api.energidataservice.dk/dataset/ProductionConsumptionSettlement"
      kafka_topic  = "production_and_consumption_settlement"
      order_by     = "HourUTC"
    },
    power_system_right_now = {
      name         = "power-system-right-now"
      endpoint_url = "https://api.energidataservice.dk/dataset/PowerSystemRightNow"
      kafka_topic  = "power_system_right_now"
      order_by     = "Minutes1UTC"
    },
    datahub_price_list = {
      name         = "datahub-price-list"
      endpoint_url = "https://api.energidataservice.dk/dataset/DataHubPricelist"
      kafka_topic  = "datahub_price_list"
      order_by     = "ValidFrom"
    },
    consumption_per_industry_public_and_private_municipality_and_hour = {
      name         = "consumption-industry"
      endpoint_url = "https://api.energidataservice.dk/dataset/ConsumptionIndustry"
      kafka_topic  = "consumption_per_industry_public_and_private_municipality_and_hour"
      order_by     = "HourUTC"
    },
  }
}

module "ingest-energinet" {
  source = "./ingest"

  for_each = local.ingest_endpoints

  name         = each.value.name
  endpoint_url = each.value.endpoint_url
  order_by     = each.value.order_by
  kafka_topic  = each.value.kafka_topic
  image        = "ingest-energinet-producer:latest"
  namespace    = var.namespace
  redis_host   = kubernetes_service.redis.metadata.0.name
  redis_db     = 0

  providers = {
    kubernetes = kubernetes
  }
}
