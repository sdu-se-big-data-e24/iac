#!/usr/bin/env bash

kubectl port-forward svc/namenode 9870:9870 &
echo "Access redpanda at http://localhost:9870"

# Test: curl -s -XGET "http://localhost:9870/webhdfs/v1/?op=LISTSTATUS"
