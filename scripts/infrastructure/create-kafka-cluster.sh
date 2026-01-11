#!/bin/bash
# Creates a Kafka cluster in the specified namespace
# Usage: create-kafka-cluster.sh <namespace> <cluster-name> <resources-dir>

NAMESPACE=$1
CLUSTER_NAME=$2
RESOURCES_DIR=$3

if [ -z "$NAMESPACE" ] || [ -z "$CLUSTER_NAME" ] || [ -z "$RESOURCES_DIR" ]; then
    echo "Usage: $0 <namespace> <cluster-name> <resources-dir>"
    exit 1
fi

echo "Creating Kafka cluster '$CLUSTER_NAME' in namespace '$NAMESPACE'..."

# Apply cluster resources
kubectl apply -n $NAMESPACE -f $RESOURCES_DIR/kafka-cluster.yaml
kubectl apply -n $NAMESPACE -f $RESOURCES_DIR/kafka-topic.yaml

echo "Waiting for Kafka cluster to be ready..."
kubectl wait --for=condition=Ready kafka -n $NAMESPACE $CLUSTER_NAME --timeout=300s

# Install exporter if config exists
if [ -f "$RESOURCES_DIR/kafka-exporter-values.yaml" ]; then
    echo "Installing Kafka exporter..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
    helm upgrade --install kafka-exporter-$NAMESPACE prometheus-community/prometheus-kafka-exporter \
        --namespace $NAMESPACE \
        --values $RESOURCES_DIR/kafka-exporter-values.yaml
    echo "Kafka exporter installed successfully"
fi

echo "Kafka cluster '$CLUSTER_NAME' is ready in namespace '$NAMESPACE'"
