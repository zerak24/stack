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
    --ci)
      AUTO="-auto-approve"
      shift 1
      ;;
  esac
done

## Global Variables

ROOT_CLOUD="."
PROVIDER_PATH="${ROOT_CLOUD}/cloud"
CLUSTER_PATH="${PROVIDER_PATH}/${PROVIDER}/env"
MODULES_PATH="${PROVIDER_PATH}/${PROVIDER}/modules"
ITEM_PATH="${CLUSTER_PATH}/${CLUSTER}"
PROJECT="${ITEM_PATH}/project.yaml"

## Setup Function

function setup() {
  source ${ROOT_CLOUD}/tools/setup.sh
  
  install_terraform
  install_yq
  install_gcloud
}

## Check Syntax Function

function check_flag() {
  if [ "${ACTION}" != "plan" ] && [ "${ACTION}" != "apply" ] && [ "${ACTION}" != "destroy" ]
  then
    echo "Wrong action"
    exit 1
  fi

  if [ $(ls ${PROVIDER_PATH} | grep -w ${PROVIDER} 2>/dev/null | wc -l) -eq 0 ]
  then
    echo "Wrong provider"
    exit 1
  fi

  if [ $(ls ${CLUSTER_PATH} | grep -w ${CLUSTER} 2>/dev/null | wc -l) -eq 0 ]
  then
    echo "Cluster not existed"
    exit 1
  fi

  if [ $(ls ${ITEM_PATH} | grep -w ${ITEM} 2>/dev/null | wc -l) -eq 0 ]
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
  path_target=${ITEM_PATH}/${ITEM}/${target}
  var="${path_target}/variables.yaml"
  state="../../../../${path_target}/state/terraform.tfstate"

  for part in $(yq '.inputs | keys | .[]' $var)
  do
    init_command="terraform -chdir=\"${MODULES_PATH}/${part}\" init"
    action_command="terraform -chdir=\"${MODULES_PATH}/${part}\" ${ACTION} -state=\"${state}\" ${AUTO} -var=\"inputs=\$(yq '.inputs.${part}' ${var} -o j -I=0)\" -var=\"project=\$(yq '.inputs.project' ${PROJECT} -o j -I=0)\""
    eval $init_command  
    eval $action_command
  done
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
    for target in $(ls ${ITEM_PATH}/${ITEM})
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
