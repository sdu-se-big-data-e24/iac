#!/usr/bin/env bash

kubectl port-forward svc/kafka-schema-registry 8081 &
echo "Access Kafka connect at http://localhost:8081"
