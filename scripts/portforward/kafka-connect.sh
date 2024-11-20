#!/usr/bin/env bash

kubectl port-forward svc/kafka-connect 8083 & 
echo "Access Kafka connect at http://localhost:8083"
