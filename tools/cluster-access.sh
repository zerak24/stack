#!/bin/bash

## Tool's Flag

# while (( "$#" ))
# do
#   case "$1" in
#     -c|--cluster)
#       cluster=$2
#       shift 2
#       ;;
#     -d|--directory)
#       directory=$2
#       shift 2
#       ;;
#   esac
# done

function cluster_main() {
  # variables

  if [ -z $directory ]
  then
    project_config="./cloud/${cluster}/project.yaml"
  else
    project_config="./cloud/${directory}/project.yaml"
  fi

  # functions
  
  ## GCP
  # command="gcloud container clusters get-credentials ${cluster} --location=$(yq '.terraform_config.zone' ${project_config})"

  ## AWS
  command="aws eks --region $(yq '.terraform_config.zone' ${project_config}) update-kubeconfig --name ${cluster}"

  eval $command
  # echo $command
}

# cluster_main