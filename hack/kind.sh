#!/bin/bash
# Copyright Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#
set -e

# Check prerequisites
REQUISITES=("kubectl" "kind" "docker")
for item in "${REQUISITES[@]}"; do
    if [[ -z $(which "${item}") ]]; then
        echo "${item} cannot be found on your system, please install ${item}"
        exit 1
    fi
done

# Function to print the usage message
function printHelp() {
    echo "Usage: "
    echo "    $0 --cluster-name dev-cluster --k8s-release 1.26.6 --ip-octet 255"
    echo ""
    echo "Where:"
    echo "    -n|--cluster-name  - name of the k8s cluster to be created"
    echo "    -r|--k8s-release   - the release of the k8s to setup, latest available if not given"
    echo "    -s|--ip-octet      - the 3rd octet for public ip addresses, 255 if not given, valid range: 0-255"
    echo "    -h|--help          - print the usage of this script"
}

# create registry container unless it already exists
# reg_name='kind-registry'
# reg_port='5001'
# if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
#     docker run \
#         -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
#         registry:2
# fi

# Setup default values
CLUSTERNAME="dev-cluster"
K8SRELEASE=""
IPSPACE=255

# Handling parameters
while [[ $# -gt 0 ]]; do
    optkey="$1"
    case $optkey in
    -h | --help)
        printHelp
        exit 0
        ;;
    -n | --cluster-name)
        CLUSTERNAME="$2"
        shift
        shift
        ;;
    -r | --k8s-release)
        K8SRELEASE="--image=kindest/node:v$2"
        shift
        shift
        ;;
    -s | --ip-space)
        IPSPACE="$2"
        shift
        shift
        ;;
    *) # unknown option
        echo "parameter $1 is not supported"
        exit 1
        ;;
    esac
done

# Create k8s cluster using the giving release and name
if [[ -z "${K8SRELEASE}" ]]; then
    kind create cluster --name "${CLUSTERNAME}" --config cluster.yaml
else
    kind create cluster "${K8SRELEASE}" --name "${CLUSTERNAME}" --config cluster.yaml
fi
# Setup cluster context
kubectl cluster-info --context "kind-${CLUSTERNAME}"

# connect the registry to the cluster network if not already connected
# if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
#     docker network connect "kind" "${reg_name}"
# fi

# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: local-registry-hosting
#   namespace: kube-public
# data:
#   localRegistryHosting.v1: |
#     host: "localhost:${reg_port}"
#     help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
# EOF

echo installing nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.19.0 TARGET_ARCH=x86_64 sh -
cd istio-1.19.0
export PATH=$PWD/bin:$PATH
istioctl install --set profile=default -y

echo "Kubernetes cluster ${CLUSTERNAME} was created successfully!"
