#! /bin/bash

## Tool's Flag

while (( "$#" ))
do
  case "$1" in
    -c|--cluster)
      CLUSTER=$2
      shift 2
      ;;
    -d|--dir)
      DIR=$2
      shift 2
      ;;
    -f|--file)
      FILE=$2
      shift 2
      ;;
  esac
done
