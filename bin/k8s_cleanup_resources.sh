#!/usr/bin/env bash

DEPLOYMENT_NAME="thaoapp"

# Remove service & deployment
echo
echo "Deleting service: ${DEPLOYMENT_NAME}"
./bin/kubectl delete services ${DEPLOYMENT_NAME}

echo
echo "Deleting deployment: ${DEPLOYMENT_NAME}"
./bin/kubectl delete deployments ${DEPLOYMENT_NAME}

# Show cluster's resources
echo
echo "Listing services"
./bin/kubectl get services
echo
echo "Listing deployments"
./bin/kubectl get deployments
echo
echo "Listting pods"
./bin/kubectl get pods
