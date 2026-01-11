#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/../../scripts/lib/chaosmania.sh

# Parse arguments
parse_args "$@"

# Setup scenario
SCENARIO=cm-simple-kafka

# Setup namespace
setup_namespace $SCENARIO

echo
echo "Ensuring Kafka operator is installed"
ensure_kafka_operator

echo
echo "Creating Kafka cluster in $NAMESPACE"
$SCRIPT_DIR/../../scripts/infrastructure/create-kafka-cluster.sh \
    $NAMESPACE \
    simple-kafka-cluster \
    $SCRIPT_DIR/strimzi-kafka

# Deploy single instance
upgrade_single "producer" $NAMESPACE $SCENARIO $SCRIPT_DIR "--set" "replicaCount=1" \
    "--set" "services[0].name=kafka-producer" \
    "--set" "services[0].type=kafka-producer" \
    "--set" "services[0].config.peer_service=kafka" \
    "--set" "services[0].config.peer_namespace=$SCENARIO" \
    "--set" "services[0].config.brokers[0]=simple-kafka-cluster-kafka-brokers.$SCENARIO.svc.cluster.local:9092" \
    "--set" "services[0].config.tls_enable=false" \
    "--set" "services[0].config.sasl_enable=false"

upgrade_single "consumer" $NAMESPACE $SCENARIO $SCRIPT_DIR "--set" "replicaCount=1" \
    "--set" "background_services[0].name=kafka-consumer" \
    "--set" "background_services[0].type=kafka-consumer" \
    "--set" "background_services[0].config.peer_service=kafka" \
    "--set" "background_services[0].config.peer_namespace=$SCENARIO" \
    "--set" "background_services[0].config.brokers[0]=simple-kafka-cluster-kafka-brokers.$SCENARIO.svc.cluster.local:9092" \
    "--set" "background_services[0].config.tls_enable=false" \
    "--set" "background_services[0].config.sasl_enable=false" \
    "--set" "background_services[0].config.topic=test1" \
    "--set" "background_services[0].config.group=my-consumer-group" \
    "--set" "background_services[0].config.script=\"function run() { var msg = ctx.get_message(); ctx.print('Received message: ' + msg); }\"" \
    "--set" "enabled_background_services[0]=kafka-consumer"

# Deploy client
upgrade_client $NAMESPACE $SCENARIO $SCRIPT_DIR "client" "producer" "/scenarios/$SCENARIO-plan.yaml"
