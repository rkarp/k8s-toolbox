#!/bin/bash

set -e

if [ -n "$SKAFFOLD_CONFIG" ] ; then
  SKAFFOLD_CONFIG_OPTION="--filename=$SKAFFOLD_CONFIG"
fi
if [ -n "$SKAFFOLD_MODULES" ] ; then
  SKAFFOLD_MODULES_OPTION="--module=$SKAFFOLD_MODULES"
fi
if [ -n "$SKAFFOLD_PROFILES" ] ; then
  SKAFFOLD_PROFILES_OPTION="--profile=$SKAFFOLD_PROFILES"
fi

mkdir -p temp

SKAFFOLD_CFG_OPTIONS="$SKAFFOLD_CONFIG_OPTION $SKAFFOLD_MODULES_OPTION $SKAFFOLD_PROFILES_OPTION"

if [ -n "$REGISTRY_HOST" ] ; then
  if [ -z "$REGISTRY_PASSWORD" ] ; then
    echo "ERROR: 'REGISTRY_PASSWORD' not set"
    exit 1
  fi
  if [ -z "$REGISTRY_USER" ] ; then
    REGISTRY_USER=user
    echo "'REGISTRY_USER' not set, using user '$REGISTRY_USER' for Docker login"
  fi
  if [ -z "$REGISTRY_NAMESPACE" ] ; then
    REGISTRY_NAMESPACE=$K8S_NAMESPACE
    echo "'REGISTRY_NAMESPACE' not set, using 'K8S_NAMESPACE'='$K8S_NAMESPACE' for docker repository namespace"
  fi

  echo "$REGISTRY_PASSWORD" | docker login -u $REGISTRY_USER --password-stdin "$REGISTRY_HOST"

  TAGS_FILE=temp/skaffold-image-tags.json
  skaffold build "$SKAFFOLD_CFG_OPTIONS" --default-repo="$REGISTRY_HOST"/"$REGISTRY_NAMESPACE" \
    --file-output="$TAGS_FILE" --cache-artifacts=false --push=true "$SKAFFOLD_CUSTOM_REGISTRY_OPTIONS"

  if [ -n "$K8S_INTERNAL_REGISTRY_HOST" ] ; then
    echo "'K8S_INTERNAL_REGISTRY_HOST' set, adjusting generated Skaffold tags"
    sed -i "s|$REGISTRY_HOST|$K8S_INTERNAL_REGISTRY_HOST|g" "$TAGS_FILE"
  fi

  SKAFFOLD_BUILD_ARTIFACTS_OPTION="--build-artifacts=$TAGS_FILE"
else
  echo "INFO: 'REGISTRY_HOST' is empty, skipping image build steps"
fi

if [ -n "$K8S_SERVER_URL" ] ; then
  if [ -z "$K8S_USER_TOKEN" ] ; then
    echo "K8S_USER_TOKEN must not be empty"
    exit 1
  fi
  if [ -n "$K8S_SERVER_CERTIFICATE_PATH" ] ; then
    KUBECTL_SERVER_CERTIFICATE_OPTIONS="--embed-certs --certificate-authority $K8S_SERVER_CERTIFICATE_PATH"
  fi
  if [ -n "$K8S_NAMESPACE" ] ; then
    KUBECTL_NAMESPACE_OPTION="--namespace=$K8S_NAMESPACE"
  fi
  if [ -z "$K8S_CLUSTER_NAME" ] ; then
    K8S_CLUSTER_NAME=target-cluster
  fi

  TARGET_KUBECONFIG=temp/kubeconfig.yaml
  TARGET_KUBECONFIG_OPTION="--kubeconfig=$TARGET_KUBECONFIG"
  kubectl $TARGET_KUBECONFIG_OPTION config set-cluster $K8S_CLUSTER_NAME --server="$K8S_SERVER_URL" "$KUBECTL_SERVER_CERTIFICATE_OPTIONS" "$K8S_CUSTOM_SERVER_OPTIONS"
  kubectl $TARGET_KUBECONFIG_OPTION config set-credentials $K8S_CLUSTER_NAME-user --token="$K8S_USER_TOKEN"
  kubectl $TARGET_KUBECONFIG_OPTION config set-context $K8S_CLUSTER_NAME-context --cluster=$K8S_CLUSTER_NAME --user=$K8S_CLUSTER_NAME-user "$KUBECTL_NAMESPACE_OPTION"
  kubectl $TARGET_KUBECONFIG_OPTION config use-context $K8S_CLUSTER_NAME-context
fi

if [ -n "$TARGET_KUBECONFIG" ] ; then
  TARGET_KUBECONFIG_OPTION="--kubeconfig=$TARGET_KUBECONFIG"
  skaffold deploy "$TARGET_KUBECONFIG_OPTION" "$SKAFFOLD_CFG_OPTIONS" "$SKAFFOLD_BUILD_ARTIFACTS_OPTION"
else
  echo "K8S_SERVER_URL is empty, skipping Skaffold deployment steps"
fi
