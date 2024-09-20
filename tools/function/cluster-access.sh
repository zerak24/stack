#!/bin/bash

# setup function
function setup() {
  source ${root_config_directory}/tools/function/setup.sh
  
  install_aws
}

# check syntax
function check_flag() {
  if [ ! -z ${directory} ] && [ ! -d ${cluster_directory} ]
  then
    echo "Directory not existed"
    exit 1
  fi
}

# execute logic
function access_action() {
  # command="gcloud container clusters get-credentials ${cluster} --location=$(yq '.terraform_config.zone' ${project_config})"
  command="aws eks --region $(yq '.terraform_config.zone' ${project_config}) update-kubeconfig --name ${cluster}"

  eval $command
  # echo $command
}

# main function
function cluster_main() {
  
  # variables
  root_config_directory=$root_directory
  cloud_directory="${root_config_directory}/cloud"
  cluster_directory="${cloud_directory}/${directory}"
  if [ -z $directory ]
  then
    project_config="${root_config_directory}/cloud/${cluster}/project.yaml"
  else
    project_config="${root_config_directory}/cloud/${directory}/project.yaml"
  fi

  # functions
  setup
  check_flag
  access_action  
}
