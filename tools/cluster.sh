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

PROJECT_CONFIG="./cloud/${CLUSTER}/project.yaml"
if [ "${PROVIDER}" == "gcp" ]; then
  gcloud container clusters get-credentials ${CLUSTER} --location=$(yq '.inputs.project.region' ${PROJECT_CONFIG})
elif [ "${PROVIDER}" == "aws" ]; then
  aws eks --region $(yq '.inputs.project.region' ${PROJECT_CONFIG}) update-kubeconfig --name ${CLUSTER}
fi
