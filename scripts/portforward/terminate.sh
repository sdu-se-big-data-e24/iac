#!/usr/bin/env bash

# Terminate port forward
kill $(ps aux | grep 'kubectl port-forward' | awk '{print $2}') 2> /dev/null
