#! /bin/bash

## Tool's Flag

while getopts :a:p:c:i:t: flag
do
  case "${flag}" in
    a) action=${OPTARG};;
    c) cluster=${OPTARG};;
    p) provider=${OPTARG};;
    i) item=${OPTARG};;
    t) targets=${OPTARG};;
  esac
done

## Global Variables

ROOT_CLOUD="."
PROVIDER_PATH="${ROOT_CLOUD}/cloud"
CLUSTER_PATH="${PROVIDER_PATH}/${provider}/env"
ITEM_PATH="${CLUSTER_PATH}/${cluster}"

## Check Syntax Functions

if [ "${action}" != "plan" ] && [ "${action}" != "apply" ] && [ "${action}" != "destroy" ];then
  echo "Err: ACTION FLAG"
  exit 1
fi

if [ $(ls ${PROVIDER_PATH} | grep ${provider} 2>/dev/null | wc -l) -eq 0 ];then
  echo "Err: PROVIDER FLAG"
  exit 1
fi

if [ $(ls ${CLUSTER_PATH} | grep ${cluster} 2>/dev/null | wc -l) -eq 0 ];then
  echo ${cluster}
  echo "Err: CLUSTER FLAG"
  exit 1
fi

if [ $(ls ${ITEM_PATH} | grep ${item} 2>/dev/null | wc -l) -eq 0 ];then
  echo "Err: ITEMS FLAG"
  exit 1
fi

if [ "${targets}" == "" ];then
  targets="all"
fi

## Main Functions

if [ "${targets}" == "all" ]; then
  exit 0
else
  for tag in $(echo ${tags} | tr ',' ' '); do
  path_target=${ITEM_PATH}/${item}/${tag}
  var="${ITEM_PATH}/${item}/${tag}/variables.yaml"
  project="${ITEM_PATH}/project.yaml"
  if [ ! -d $path ]; then
    continue
  fi
  for part in $(yq)
  command="terraform ${action} -chdir ${path} -var=\"inputs=\$(yq '.inputs.${part}' ${var} -o j -I=0)\" -var=\"project=\$(yq '.inputs.project' ${project} -o j -I=0)\""
  echo $command
  # eval $command  
done
fi
