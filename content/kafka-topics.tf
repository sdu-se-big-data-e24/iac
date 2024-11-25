
# # Make sure we don't lock down ourself on first run of terraform.
# # First grant ourself admin permissions, then add ACL for topic.
# resource "kafka_acl" "global" {
#   resource_name       = "*"
#   resource_type       = "Topic"
#   acl_principal       = "User:*"
#   acl_host            = "*"
#   acl_operation       = "All"
#   acl_permission_type = "Allow"
# }

# resource "kafka_topic" "syslog" {
#   name               = "syslog"
#   replication_factor = 1
#   partitions         = 4

#   config = {
#     "segment.ms"   = "4000"
#     "retention.ms" = "86400000"
#   }

#   depends_on = [kafka_acl.global]
# }

