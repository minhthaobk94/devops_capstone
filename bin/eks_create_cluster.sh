#!/usr/bin/env bash

CLUSTER="thaoapp"
REGION="us-east-1"
CLUSTER_NAME="${CLUSTER}.${REGION}.eksctl.io"

if ./bin/kubectl config get-clusters | grep -q ${CLUSTER_NAME}; then
    echo
    echo "Cluster '${CLUSTER_NAME}' already exists!"
    echo
else
    echo
    echo "Creating cluster..."
    ./bin/eksctl create cluster --config-file=thaoapp_cluster.yml
fi
