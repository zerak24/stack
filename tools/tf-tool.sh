#! /bin/bash

## Tool's Flag

while (( "$#" ))
do
  case "$1" in
    -h|--help)
      echo "
-a|--action              : action want to execute (plan, apply, destroy)
-c|--cluster             : .yaml file want to execute with action flags
-i|--item                : item want to execute with action flags (apps, domains, infras)
-t|--targets  (optional) : list of targets want to execute with action flags if not define all targets will be chosen
-p|--provider            : directory of helm charts want to execute with action flags if use helm repository please define in .yaml file
  |--profile  (optional) : use with provider is aws
  |--ci       (optional) : auto yes every questions
"
      exit 0
      ;;
    -a|--action)
      ACTION=$2
      shift 2
      ;;
    -c|--cluster)
      CLUSTER=$2
      shift 2
      ;;
    -p|--provider)
      PROVIDER=$2
      shift 2
      ;;
    -i|--item)
      ITEM=$2
      shift 2
      ;;
    -t|--targets)
      TARGETS=$2
      shift 2
      ;;
    --profile)
      AWS_PROFILE=$2
      shift 2
      ;;
    --ci)
      AUTO="-auto-approve"
      shift 1
      ;;
  esac
done

## Variables

root_cloud_directory="."
provider_directory="${root_cloud_directory}/cloud"
cluster_directory="${provider_directory}/${PROVIDER}/env"
modules_directory="${provider_directory}/${PROVIDER}/modules"
item_directory="${cluster_directory}/${CLUSTER}"
project_file="${item_directory}/project.yaml"
if [ -z ${AWS_PROFILE} ]; then
  AWS_PROFILE=$(yq '.inputs.project.profile' ${project_file})
fi
export AWS_PROFILE=${AWS_PROFILE}

## Setup Function

function setup() {
  source ${root_cloud_directory}/tools/setup.sh
  
  install_terraform
  install_yq
}

## Check Syntax Function

function check_flag() {
  if [ "${ACTION}" != "plan" ] && [ "${ACTION}" != "apply" ] && [ "${ACTION}" != "destroy" ]
  then
    echo "Wrong action"
    exit 1
  fi

  if [ $(ls ${provider_directory} | grep -w ${PROVIDER} 2>/dev/null | wc -l) -eq 0 ]
  then
    echo "Wrong provider"
    exit 1
  fi

  if [ $(ls ${cluster_directory} | grep -w ${CLUSTER} 2>/dev/null | wc -l) -eq 0 ]
  then
    echo "Cluster not existed"
    exit 1
  fi

  if [ $(ls ${item_directory} | grep -w ${ITEM} 2>/dev/null | wc -l) -eq 0 ]
  then
    echo "Items not existed"
    exit 1
  fi

  if [ -z ${TARGETS} ]
  then
    TARGETS="all"
  fi
}

## Terraform Function

function terraform_target() {
  path_prefix="../../../../"
  path_target=${item_directory}/${ITEM}/${target}
  var="${path_target}/variables.yaml"
  json_var="${path_target}/variables.tfvars.json"
  state="${path_target}/state/terraform.tfstate"
  module="$(yq '.module' $var)"

  if [ -z "$(yq '.inputs' $var)" ]; then
    exit 0
  fi

  yq eval-all '. as $item ireduce ({}; . * $item) | .inputs' ${var} ${project_file} -o json > $json_var

  init_command="terraform -chdir=${modules_directory}/${module} init"
  action_command="terraform -chdir=${modules_directory}/${module} ${ACTION} -state=${path_prefix}${state} ${AUTO} -var-file=${path_prefix}${json_var}"
  eval $init_command
  eval $action_command

  rm -f $json_var
}

function check_automation() {
  if [ "${ACTION}" == "apply" ] || [ "${ACTION}" == "destroy" ] && [ -z ${AUTO} ]
  then
    echo -n "This is ${ACTION} action. Are you sure that you wanna do this ? [y/N]: "
    read -r ans
    if [ "${ans}" != "y" ] && [ "${ans}" != "yes" ]
    then
      exit
    fi
    AUTO="-auto-approve"
  fi
}

function terraform_action() {
  if [ "${TARGETS}" == "all" ]
  then
    for target in $(ls ${item_directory}/${ITEM})
    do
      terraform_target
    done
  else
    for target in $(echo ${TARGETS} | tr ',' ' ')
    do
      terraform_target
    done
  fi
}

## Main Function

setup
check_flag
check_automation
terraform_action
