#! /bin/bash

## Tool's Flag

while (( "$#" ))
do
  case "$1" in
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
CONFIG_FILE_PATH="$ROOT_HELM/config.yaml"

## Setup Function

function setup() {
  source ${ROOT_HELM}/tools/setup.sh
  
  install_terraform
  install_yq
  install_helm3
  install_gcloud
  install_kubectl
}

## Check Syntax Function

function check_flag() {
  if [ "${ACTION}" != "plan" ] && [ "${ACTION}" != "apply" ] && [ "${ACTION}" != "destroy" ] && [ "${ACTION}" != "debug" ] && [ "${ACTION}" != "push" ]
  then
    echo "Wrong action flag"
    exit 1
  fi

  if [ ! -z ${FILE} ] && [ ! -f ${FILE} ]
  then
    echo "Wrong file flag"
    exit 1
  fi

  if [ ! -z ${DIRECTORY} ] && [ ! -d ${DIRECTORY} ]
  then
    echo "Wrong directory flag"
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
  CLUSTER=$(basename ${FILE} | cut -d"." -f1)
  RELEASE=$(yq '.deploy_config.namespace' ${FILE})
  if [ "${RELEASE}" == "null" ]; then
    RELEASE=$(basename $(dirname ${FILE}))
  fi
  NAMESPACE=$(yq '.deploy_config.namespace' ${FILE})
  CHART_REPO=$(yq '.chart.repository' ${FILE})
  CHART_VERSION=$(yq '.chart.version' ${FILE})
  REPO_NAME=$(yq '.helm_repo.name' ${CONFIG_FILE_PATH})
  REPO_URL=$(yq '.helm_repo.repoUrl' ${CONFIG_FILE_PATH})
  REPO_USERNAME=$(yq '.helm_repo.username' ${CONFIG_FILE_PATH})
  REPO_PASSWORD=$(yq '.helm_repo.password' ${CONFIG_FILE_PATH})
}

function add_helm_repo() {
	if [ $(helm repo list | grep -E "${REPO_NAME}" | wc -l) -eq 0 ]; then
		command="helm repo add ${REPO_NAME} ${REPO_URL} --username=${REPO_USERNAME} --password=${REPO_PASSWORD}"
	fi
  eval $command
}

function helm_action() {
  HELM_ACTION=""
  HELM_FLAG=""
  HELM_PLUGINS="secrets"
  case ${ACTION} in
    plan)
    HELM_ACTION="diff upgrade"
    HELM_FLAG="--install --namespace=${NAMESPACE} --values=${FILE} --kube-context=${CLUSTER} ${RELEASE} ${CHART_REPO} --version=${CHART_VERSION}"
    ;;
    apply)
    HELM_ACTION="upgrade --install"
    HELM_FLAG="--install --namespace=${NAMESPACE} --values=${FILE} --kube-context=${CLUSTER} ${RELEASE} ${CHART_REPO} --version=${CHART_VERSION}"
    ;;
    destroy)
    HELM_ACTION="uninstall"
    HELM_FLAG="--namespace=${NAMESPACE} --kube-context=${CLUSTER} ${RELEASE}"
    ;;
    debug)
    HELM_ACTION="template"
    HELM_FLAG="--namespace=${NAMESPACE} --values=${FILE} --kube-context=${CLUSTER} ${RELEASE} ${CHART_REPO} --version=${CHART_VERSION}"
    ;;
    push)
    HELM_ACTION="cm-push"
    HELM_FLAG="${DIRECTORY} ${REPO_NAME}"
    ;;
  esac
  command="helm ${HELM_PLUGINS} ${HELM_ACTION} ${HELM_FLAG}"
}

## Main Function

setup
check_flag
check_automation
load_config
add_helm_repo
helm_action
