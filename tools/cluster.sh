#!/bin/bash

## Tool's Flag

while (( "$#" ))
do
  case "$1" in
    -c|--cluster)
      CLUSTER=$2
      shift 2
      ;;
    -p|--provider)
      PROVIDER=$2
      shift 2
      ;;
  esac
done

PROJECT_CONFIG="../cloud/$PROVIDER/env/$CLUSTER/project.yaml"
gcloud container clusters get-credentials $CLUSTER --location=$(yq '.inputs.project.region' $PROJECT_CONFIG)