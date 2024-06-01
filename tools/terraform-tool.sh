#! /bin/bash

## Tool's Flag

while (( "$#" ))
do
  case "$1" in
    -a|--action)
      ACTION=$2
      shift 2
      ;;
    -c|--cluster)
      CLUSTER=$2
      shift 2
      ;;
    --ci)
      # CI=true
      AUTO="-auto-approve"
      shift 1
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
  esac
done

## Global Variables
ROOT_CLOUD="."
PROVIDER_PATH="${ROOT_CLOUD}/cloud"
CLUSTER_PATH="${PROVIDER_PATH}/${PROVIDER}/env"
MODULES_PATH="${PROVIDER_PATH}/${PROVIDER}/modules"
ITEM_PATH="${CLUSTER_PATH}/${CLUSTER}"
PROJECT="${ITEM_PATH}/project.yaml"


## Additional Soure

source ${ROOT_CLOUD}/tools/setup.sh

## Check Syntax Function

function check_flag() {
  if [ "${ACTION}" != "plan" ] && [ "${ACTION}" != "apply" ] && [ "${ACTION}" != "destroy" ]
  then
    echo "WRONG ACTION FLAG"
    exit 1
  fi

  if [ $(ls ${PROVIDER_PATH} | grep -w ${PROVIDER} 2>/dev/null | wc -l) -eq 0 ]
  then
    echo "WRONG PROVIDER FLAG"
    exit 1
  fi

  if [ $(ls ${CLUSTER_PATH} | grep -w ${CLUSTER} 2>/dev/null | wc -l) -eq 0 ]
  then
    echo "WRONG CLUSTER FLAG"
    exit 1
  fi

  if [ $(ls ${ITEM_PATH} | grep -w ${ITEM} 2>/dev/null | wc -l) -eq 0 ]
  then
    echo "WRONG ITEMS FLAG"
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

  if [ -f $path_target ]
  then
    var="${path_target}"
  fi

  for part in $(yq '.inputs | keys | .[]' $var)
  do
    command="terraform ${ACTION} ${AUTO} -chdir ${MODULES_PATH}/${part} -var=\"inputs=\$(yq '.inputs.${part}' ${var} -o j -I=0)\" -var=\"project=\$(yq '.inputs.project' ${PROJECT} -o j -I=0)\""
    echo $command
    # eval $command  
  done
}

function check_automation() {
  if [ "${ACTION}" == "apply" ] || [ "${ACTION}" == "destroy" ] && [ -z ${AUTO} ]
  then
    echo -n "This is ${ACTION} action. Are you sure that you wanna do this ? Did you run plan action yet ? [y/n]: "
    read -r ans
    if [ "${ans}" != "y" ] && [ "${ans}" != "yes" ]
    then
      exit
    fi
    AUTO="-auto-approve"
  fi
}

## Setup Function

install_terraform
install_yq
install_helm3
install_gcloud

## Main Function

check_flag
check_automation

if [ "${TARGETS}" == "all" ]
then
  for target in $(ls $ITEM_PATH/${ITEM})
  do
    terraform_target
  done
else
  for target in $(echo ${TARGETS} | tr ',' ' ')
  do
    terraform_target
  done
fi
