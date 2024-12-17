#!/usr/bin/env bash

# Get list of files in $(pwd)/kubectl-config/
files=$(ls "$(pwd)/kubectl-config/")

# make string withthem all for KUBECONFIG
KUBECONFIG=""
for file in $files; do
    KUBECONFIG="$KUBECONFIG:$(pwd)/kubectl-config/$file"
done
export KUBECONFIG=${KUBECONFIG:1}

# Ask which context to use
echo "Available contexts:"
kubectl config get-contexts

echo "Enter the context you want to use:"
read context

kubectl config use-context $context
