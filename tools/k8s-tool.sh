#! /bin/bash

## tool's flag

# while (( "$#" ))
# do
#   case "$1" in
#     -h|--help)
#       echo "
# -a|--action               : action want to execute (plan, apply, destroy, push, debug)
# -f|--file                 : .yaml file want to execute with action flags
# -d|--directory (optional) : directory of helm charts want to execute with action flags if use helm repository please define in .yaml file
#   |--ci        (optional) : auto yes every questions
# "
#       exit 0
#       ;;
#     -a|--action)
#       action=$2
#       shift 2
#       ;;
#     -f|--file)
#       file=$2
#       shift 2
#       ;;
#     -d|--directory)
#       directory=$2
#       shift 2
#       ;;
#     --ci)
#       auto="true"
#       shift 1
#       ;;
#   esac
# done

## setup function

function setup() {
  source ${root_helm}/tools/setup.sh
  
  install_yq
  install_helm3
  install_kubectl
}

## check syntax function

function check_flag() {
  if [ "${action}" != "plan" ] && [ "${action}" != "apply" ] && [ "${action}" != "destroy" ] && [ "${action}" != "debug" ] && [ "${action}" != "push" ]
  then
    echo "Wrong action"
    exit 1
  fi

  if [ ! -z ${file} ] && [ ! -f ${file} ]
  then
    echo "File not existed"
    exit 1
  fi

  if [ ! -z ${directory} ] && [ ! -d ${directory} ]
  then
    echo "Directory not existed"
    exit 1
  fi
}

## helm function

function check_automation() {
  if [ "${action}" == "apply" ] || [ "${action}" == "destroy" ] && [ -z ${auto} ]
  then
    echo -n "This is ${action} action. Are you sure that you wanna do this ? [y/N]: "
    read -r ans
    if [ "${ans}" != "y" ] && [ "${ans}" != "yes" ]
    then
      exit 0
    fi
  fi
}

function load_config() {
  chart_repo=${directory}
  if [ ! -z ${file} ]
  then
    namespace=$(yq '.deploy_config.namespace' ${file})
    cluster=$(yq '.deploy_config.cluster' ${file})
    if [ "${cluster}" == "null" ]
    then
      cluster=$(basename ${file} | cut -d"." -f1)
    fi
    release=$(yq '.deploy_config.name' ${file})
    if [ "${release}" == "null" ]
    then
      release=$(basename $(dirname ${file}))
    fi
    if [ -z $directory ]
    then
      chart_repo=$(yq '.chart.repository' ${file})
      chart_version=$(yq '.chart.version' ${file})
    fi
  fi
  repo_name=$(yq '.helm_auth.name' ${auth_file_path})
}

function add_helm_repo() {
	if [ $(helm repo list | grep -E "${repo_name}" | wc -l) -eq 0 ]
  then
    repo_url=$(yq '.helm_auth.url' ${auth_file_path})
    repo_username=$(yq '.helm_auth.username' ${auth_file_path})
    repo_password=$(yq '.helm_auth.password' ${auth_file_path})
		command="helm repo add ${repo_name} ${repo_url} --username=${repo_username} --password=${repo_password} --insecure-skip-tls-verify"
	fi
  eval $command
}

function helm_action() {
  helm_action=""
  helm_flag=""
  helm_plugins="secrets"
  update_helm_repositoy=""
  if [ -z $directory ]
  then
    update_helm_repositoy="helm repo update ${repo_name}"
  fi
  case ${action} in
    plan)
    helm_action="diff upgrade"
    helm_flag="--install --namespace=${namespace} --values=${file} --kube-context=${cluster} ${release} ${chart_repo} --version=${chart_version}"
    eval $update_helm_repositoy
    ;;
    apply)
    helm_action="upgrade --install"
    helm_flag="--install --namespace=${namespace} --create-namespace --values=${file} --kube-context=${cluster} ${release} ${chart_repo} --version=${chart_version}"
    eval $update_helm_repositoy
    ;;
    destroy)
    helm_action="uninstall"
    helm_flag="--namespace=${namespace} --kube-context=${cluster} ${release}"
    ;;
    debug)
    helm_action="template"
    helm_flag="--namespace=${namespace} --create-namespace --values=${file} --kube-context=${cluster} ${release} ${chart_repo} --version=${chart_version}"
    eval $update_helm_repositoy
    ;;
    push)
    helm_action="cm-push"
    helm_flag="${directory} ${repo_name} --insecure"
    ;;
  esac

  command="helm ${helm_plugins} ${helm_action} ${helm_flag}"
  
  eval $command
  # echo $command
}

## main function

function k8s_main() {
  # variables

  root_helm="."
  auth_file_path="$root_helm/key/auth/auth.yaml"
  
  # functions

  setup
  check_flag
  check_automation
  load_config
  # add_helm_repo
  helm_action
}

# k8s_main
