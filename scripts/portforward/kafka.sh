#!/usr/bin/env bash

kubectl port-forward svc/kafka 9092 & 
echo "Access Kafka connect at http://localhost:9092"
