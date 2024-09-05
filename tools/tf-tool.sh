#! /bin/bash

## Tool's Flag

while (( "$#" ))
do
  case "$1" in
    -h|--help)
      echo "
-a|--action              : action want to execute (plan, apply, destroy, debug)
-c|--cluster             : .yaml file want to execute with action flags
-p|--part                : part of cloud want to execute with action flags (apps, domains, infras)
-i|--items    (optional) : list of items (separate with comma) want to execute with action flags if not define all items will be chosen
  |--ci       (optional) : auto yes every questions
"
      exit 0
      ;;
    -a|--action)
      action=$2
      shift 2
      ;;
    -c|--cluster)
      cluster=$2
      shift 2
      ;;
    -p|--part)
      part=$2
      shift 2
      ;;
    -i|--items)
      items=$2
      shift 2
      ;;
    --ci)
      auto="-auto-approve"
      shift 1
      ;;
  esac
done

## Variables

action_list="plan apply destroy debug"
root_cloud_directory="."
cloud_directory="${root_cloud_directory}/cloud"
cluster_directory="${cloud_directory}/${cluster}"
items_directory="${cluster_directory}/${part}"
project_file="${cluster_directory}/project.yaml"
additional_arguments=""
all=""

AWS_PROFILE=$(yq '.terraform.profile' ${project_file})
export AWS_PROFILE=${AWS_PROFILE}

## Setup Function

function setup() {
  source ${root_cloud_directory}/tools/setup.sh
  
  install_terraform
  install_terragrunt
  install_yq
}

## Check Syntax Function

function check_flag() {
  if [ $(echo ${action_list} | grep ${action} | wc -l) -eq 0 ]
  then
    echo "Wrong action"
    exit 1
  fi

  if [ -z "${cluster}" ] || [ ! -d "${cluster_directory}" ]
  then
    echo "Cluster not existed"
    exit 1
  fi

  for item in $(echo ${items} | tr ',' ' ')
  do
    if [ ! -d "${items_directory}/${item}" ]
    then
      echo "Item ${item} not existed"
      exit 1
    fi
  done
}

## Terraform Function

function terraform_execute() {
  additional_arguments="${additional_arguments} --terragrunt-forward-tf-stdout"

  action_command="terragrunt ${all} ${action} ${additional_arguments}"

  pushd "${items_directory}/${item}"
  eval $action_command
  popd
}

function check_automation() {
  if [ "${action}" == "apply" ] || [ "${action}" == "destroy" ] && [ -z ${auto} ]
  then
    echo -n "This is ${action} action. Are you sure that you wanna do this ? [y/N]: "
    read -r ans
    if [ "${ans}" != "y" ] && [ "${ans}" != "yes" ]
    then
      exit
    fi
    additional_arguments="${additional_arguments} -auto-approve"
  fi
}

function terraform_action() {
  if [ -z ${items} ]
  then
    all="run-all"
    terraform_execute
  else
    for item in $(echo ${items} | tr ',' ' ')
    do
      terraform_execute
    done
  fi
}

## Main Function

setup
check_flag
check_automation
terraform_action
