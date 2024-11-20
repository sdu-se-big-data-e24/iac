#!/usr/bin/env bash

# Port forward redpanda to localhost through Kubernetes
kubectl port-forward svc/redpanda 8080:8080 &
echo "Access redpanda at http://localhost:8080"
