#!/bin/bash
# Installs Strimzi Kafka operator cluster-wide if not already installed
# Can be safely called multiple times (idempotent)

OPERATOR_NAMESPACE=${KAFKA_OPERATOR_NAMESPACE:-kafka-operator}

echo "Checking for Strimzi operator in $OPERATOR_NAMESPACE..."

# Check if operator already exists
if kubectl get deployment -n $OPERATOR_NAMESPACE strimzi-cluster-operator &>/dev/null; then
    echo "Strimzi operator already installed in $OPERATOR_NAMESPACE"
    exit 0
fi

echo "Installing Strimzi operator in $OPERATOR_NAMESPACE..."

# Create namespace
kubectl create namespace $OPERATOR_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repo
helm repo add strimzi https://strimzi.io/charts/ 2>/dev/null || true
helm repo update strimzi

# Install operator
helm upgrade --install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
    --namespace $OPERATOR_NAMESPACE \
    --set watchAnyNamespace=true

echo "Strimzi operator installed successfully in $OPERATOR_NAMESPACE"
