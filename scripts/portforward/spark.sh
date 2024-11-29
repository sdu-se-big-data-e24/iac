#!/usr/bin/env bash

kubectl port-forward svc/spark-master-svc 8081:80 &
echo "Spark UI: http://localhost:8081"