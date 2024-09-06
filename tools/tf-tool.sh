#! /bin/bash

## tool's flag

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

## terraform function

# setup
function terraform_setup() {
  source ${root_cloud_directory}/tools/setup.sh
  
  install_terraform
  install_terragrunt
  install_yq
}

# check syntax
function terraform_check_and_convert_flag() {
  if [ $(echo ${action_list} | grep ${action} | wc -l) -eq 0 ]
  then
    echo "Wrong action"
    exit 1
  fi

  if [ "${action}" == "debug" ]
  then
    action="validate-inputs"
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

# execute command
function terraform_execute() {
  action_command="terragrunt run-all ${action} ${additional_arguments}"

  eval $action_command
}

# check automation
function terraform_check_automation() {
  if [ "${action}" == "apply" ] || [ "${action}" == "destroy" ] && [ -z ${auto} ]
  then
    echo -n "This is ${action} action. Are you sure that you wanna do this ? [y/N]: "
    read -r ans
    if [ "${ans}" != "y" ] && [ "${ans}" != "yes" ]
    then
      exit
    fi
    additional_arguments="${additional_arguments} --terragrunt-non-interactive -auto-approve"
  fi
}

# execute logic
function terraform_action() {
  if [ -z ${items} ]
  then
    terraform_execute
  else
    additional_arguments="${additional_arguments} --terragrunt-strict-include"
    for item in $(echo ${items} | tr ',' ' ')
    do
      additional_arguments="${additional_arguments} --terragrunt-include-dir ${items_directory}/${item}"
    done
    terraform_execute
  fi
}

## main function

function terraform_main() {
  # variables

  action_list="plan apply destroy debug"
  root_cloud_directory="."
  cloud_directory="${root_cloud_directory}/cloud"
  cluster_directory="${cloud_directory}/${cluster}"
  items_directory="${cluster_directory}/${part}"
  project_file="${cluster_directory}/project.yaml"
  additional_arguments="--terragrunt-parallelism 3 --terragrunt-forward-tf-stdout"

  AWS_PROFILE=$(yq '.terraform_config.profile' ${project_file})
  export AWS_PROFILE=${AWS_PROFILE}

  # function

  terraform_setup
  terraform_check_and_convert_flag
  terraform_check_automation
  terraform_action
}

terraform_main
