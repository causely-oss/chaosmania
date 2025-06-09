#!/bin/bash

# Set variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

IMAGE_TAG=latest
CHAOS_HOST=frontend
NAMESPACE=chaosmania

cd $SCRIPT_DIR

# Delete existing Helm release if it exists
helm delete --namespace ${NAMESPACE} client-bet

# Install or upgrade the Helm chart for the client
helm upgrade --install --create-namespace --namespace ${NAMESPACE} client-bet ../../helm/client \
  --set chaos.plan="/plans/many_requests.yaml" \
  --set chaos.host=${CHAOS_HOST} \
  --set image.tag=${IMAGE_TAG}
