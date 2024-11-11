#!/usr/bin/env bash
export KUBECONFIG=${KUBECONFIG:-~/.kube/config}:$(pwd)/kubectl-config/group-02-kubeconfig.yaml
kubectl config use-context group-02-context
echo "KUBECONFIG set to group-02-context"
