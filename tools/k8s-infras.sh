#! /bin/bash

## Tool's Flag

while (( "$#" ))
do
  case "$1" in
    -h|--help)
      echo "
-a|--action               : action want to execute (plan, apply, destroy, push, debug)
-f|--file                 : .yaml file want to execute with action flags
-d|--directory (optional) : directory of helm charts want to execute with action flags if use helm repository please define in .yaml file
  |--ci        (optional) : auto yes every questions
"
      exit 0
      ;;
    -a|--action)
      ACTION=$2
      shift 2
      ;;
    -f|--file)
      FILE=$2
      shift 2
      ;;
    -d|--directory)
      DIRECTORY=$2
      shift 2
      ;;
    --ci)
      AUTO="true"
      shift 1
      ;;
  esac
done

## Global Variables

ROOT_HELM="."
AUTH_FILE_PATH="$ROOT_HELM/key/token/auth.yaml"

## Setup Function

function setup() {
  source ${ROOT_HELM}/tools/setup.sh
  
  install_yq
  install_helm3
  install_kubectl
}

## Check Syntax Function

function check_flag() {
  if [ "${ACTION}" != "plan" ] && [ "${ACTION}" != "apply" ] && [ "${ACTION}" != "destroy" ] && [ "${ACTION}" != "debug" ] && [ "${ACTION}" != "push" ]
  then
    echo "Wrong action"
    exit 1
  fi

  if [ ! -z ${FILE} ] && [ ! -f ${FILE} ]
  then
    echo "File not existed"
    exit 1
  fi

  if [ ! -z ${DIRECTORY} ] && [ ! -d ${DIRECTORY} ]
  then
    echo "Directory not existed"
    exit 1
  fi
}

## Helm Function

function check_automation() {
  if [ "${ACTION}" == "apply" ] || [ "${ACTION}" == "destroy" ] && [ -z ${AUTO} ]
  then
    echo -n "This is ${ACTION} action. Are you sure that you wanna do this ? [y/N]: "
    read -r ans
    if [ "${ans}" != "y" ] && [ "${ans}" != "yes" ]
    then
      exit 0
    fi
  fi
}

function load_config() {
  CHART_REPO=${DIRECTORY}
  if [ ! -z ${FILE} ]; then
    NAMESPACE=$(yq '.deploy_config.namespace' ${FILE})
    CLUSTER=$(yq '.deploy_config.cluster' ${FILE})
    if [ "${CLUSTER}" == "null" ]; then
      CLUSTER=$(basename ${FILE} | cut -d"." -f1)
    fi
    RELEASE=$(yq '.deploy_config.name' ${FILE})
    if [ "${RELEASE}" == "null" ]; then
      RELEASE=$(basename $(dirname ${FILE}))
    fi
    if [ -z $DIRECTORY ]; then
      CHART_REPO=$(yq '.chart.repository' ${FILE})
      CHART_VERSION=$(yq '.chart.version' ${FILE})
    fi
  fi
  REPO_NAME=$(yq '.helm_auth.name' ${AUTH_FILE_PATH})
}

function add_helm_repo() {
	if [ $(helm repo list | grep -E "${REPO_NAME}" | wc -l) -eq 0 ]; then
    REPO_URL=$(yq '.helm_auth.url' ${AUTH_FILE_PATH})
    REPO_USERNAME=$(yq '.helm_auth.username' ${AUTH_FILE_PATH})
    REPO_PASSWORD=$(yq '.helm_auth.password' ${AUTH_FILE_PATH})
		command="helm repo add ${REPO_NAME} ${REPO_URL} --username=${REPO_USERNAME} --password=${REPO_PASSWORD} --insecure-skip-tls-verify"
	fi
  eval $command
}

function helm_action() {
  HELM_ACTION=""
  HELM_FLAG=""
  HELM_PLUGINS="secrets"
  update_helm_repositoy=""
  if [ -z $DIRECTORY ]; then
    update_helm_repositoy="helm repo update ${REPO_NAME}"
  fi
  case ${ACTION} in
    plan)
    HELM_ACTION="diff upgrade"
    HELM_FLAG="--install --namespace=${NAMESPACE} --values=${FILE} --kube-context=${CLUSTER} ${RELEASE} ${CHART_REPO} --version=${CHART_VERSION}"
    eval $update_helm_repositoy
    ;;
    apply)
    HELM_ACTION="upgrade --install"
    HELM_FLAG="--install --namespace=${NAMESPACE} --create-namespace --values=${FILE} --kube-context=${CLUSTER} ${RELEASE} ${CHART_REPO} --version=${CHART_VERSION}"
    eval $update_helm_repositoy
    ;;
    destroy)
    HELM_ACTION="uninstall"
    HELM_FLAG="--namespace=${NAMESPACE} --kube-context=${CLUSTER} ${RELEASE}"
    ;;
    debug)
    HELM_ACTION="template"
    HELM_FLAG="--namespace=${NAMESPACE} --create-namespace --values=${FILE} --kube-context=${CLUSTER} ${RELEASE} ${CHART_REPO} --version=${CHART_VERSION}"
    eval $update_helm_repositoy
    ;;
    push)
    HELM_ACTION="cm-push"
    HELM_FLAG="${DIRECTORY} ${REPO_NAME} --insecure"
    ;;
  esac
  command="helm ${HELM_PLUGINS} ${HELM_ACTION} ${HELM_FLAG}"
  eval $command
}

## Main Function

setup
check_flag
check_automation
load_config
# add_helm_repo
helm_action

