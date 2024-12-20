resource "schemaregistry_subject" "production_and_consumption_settlement-value" {
  subject = "production_and_consumption_settlement-value"
  schema  = file("../../schema/avro/production_and_consumption_settlement.avsc")
}

resource "schemaregistry_subject" "power_system_right_now-value" {
  subject = "power_system_right_now-value"
  schema  = file("../../schema/avro/power_system_right_now.avsc")
}

resource "schemaregistry_subject" "datahub_price_list-value" {
  subject = "datahub_price_list-value"
  schema  = file("../../schema/avro/datahub_price_list.avsc")
}

resource "schemaregistry_subject" "consumption_per_industry_public_and_private_municipality_and_hour-value" {
  subject = "consumption_per_industry_public_and_private_municipality_and_hour-value"
  schema  = file("../../schema/avro/consumption_per_industry_public_and_private_municipality_and_hour.avsc")
}
