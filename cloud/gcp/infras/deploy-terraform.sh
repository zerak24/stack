#! /bin/bash
while getopts a:p: flag
do
  case "${flag}" in
    a) action=${OPTARG};;
    p) part=${OPTARG};;
  esac
done

if [ -z ${action} ] || [ -z ${part} ]; then
  echo "wrong args"
  exit 1
fi

if [ "${action}" != "plan" ] && [ "${action}" != "apply" ];then
  echo "wrong action"
  exit 1
fi

if [ $(ls | grep ${part} | wc -l) -eq 0 ];then
  echo "wrong part"
  exit 1
fi

pushd $part
command="terraform ${action} -var=\"inputs=\$(yq '.inputs.${part}' ../variables.yaml -o j -I=0)\" -var=\"project=\$(yq '.inputs.project' ../variables.yaml -o j -I=0)\""
eval $command
popd