#! /bin/bash

# tool's flag
case "$1" in
  -h|--help)
    echo "
help menu for tools command

cloud  : action in cloud infrastructure
k8s    : action in kubernetes cluster
access : access or init kubernetes cluster profile

show help with every single subcommand
tools.sh [subcommand] --help
"
    exit 0
    ;;
  *)
    subcommand=$1
    shift 1
    ;;
esac

while (( "$#" ))
do
  case "$1" in
    -h|--help)
      case "$subcommand" in
        cloud)
          echo "
help menu for cloud subcommand

-a|--action              : action want to execute (plan, apply, destroy, debug)
-d|--directory           : directory store config that want to execute with action flags
-p|--part                : part of cloud want to execute with action flags (apps, domains, infras)
-i|--items    (optional) : list of items (separate with comma) want to execute with action flags if not define all items will be chosen
  |--ci       (optional) : auto yes every questions
"
          ;;
        k8s)
          echo "
help menu for k8s subcommand

-a|--action               : action want to execute (plan, apply, destroy, push, debug)
-f|--file                 : .yaml file want to execute with action flags
-d|--directory (optional) : directory of helm charts want to execute with action flags if use helm repository please define in .yaml file
  |--ci        (optional) : auto yes every questions
"
          ;;
        access)
          echo "
help menu for access subcommand

-c|--cluster   : cluster want to access to or init
-d|--directory : directory store config of cluster
"
          ;;
      esac
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
    -f|--file)
      file=$2
      shift 2
      ;;
    -d|--directory)
      directory=$2
      shift 2
      ;;
    --ci)
      auto="-auto-approve"
      shift 1
      ;;
  esac
done

# variables
root_directory="."

# execute logic
case "$subcommand" in
  cloud)
    source ${root_directory}/tools/function/tf-tool.sh
    terraform_main
    ;;
  k8s)
    source ${root_directory}/tools/function/k8s-tool.sh
    k8s_main
    ;;
  access)
    source ${root_directory}/tools/function/cluster-access.sh
    cluster_main
    ;;
esac