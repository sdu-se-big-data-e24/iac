resource "schemaregistry_subject" "ProductionConsumptionSettlement-value" {
  subject = "ProductionConsumptionSettlement-value"
  schema  = file("../../schema/avro/Production_and_Consumption_Settlement.avsc")
}
