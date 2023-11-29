#! /bin/bash
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

RED="BA1A1A"
GREEN="14C560"
NODE_SUMMARY="Node in Develop Cluster is Down"
KONG_SUMMARY="Kong in Develop Cluster is CrashLoopBackOff"
ALERT="ALERT"
RESOLVED="RESOLVED"

if [ $(ls $NODE_FLAG 2>/dev/null | wc -l) -eq 0 ]
then
    echo 0 > $NODE_FLAG
fi

if [[ $(curl --silent --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/nodes | jq '.items[] | select(any(.status.conditions[]; .type=="Ready" and .status!="True")).metadata.name') != '' ]]
then
    if [ $(cat $NODE_FLAG | grep 0 | wc -l) -gt 0 ]
    then
        echo 1 > $NODE_FLAG
        sed -e "s/XXXDATEXXX/$(date)/g" -e "s/XXXCOLORXXX/$RED/g" -e "s/XXXALERTXXX/$ALERT/g" -e "s/XXXSUMMARYXXX/$NODE_SUMMARY/g" tmpl.json > /tmp/alert.json
        curl -H 'Content-Type: application/json' -d @/tmp/alert.json $WEBHOOK
    fi
else
    if [ $(cat $NODE_FLAG | grep 1 | wc -l) -gt 0 ]
    then
        sed -e "s/XXXDATEXXX/$(date)/g" -e "s/XXXCOLORXXX/$GREEN/g" -e "s/XXXALERTXXX/$RESOLVED/g" -e "s/XXXSUMMARYXXX/$NODE_SUMMARY/g" tmpl.json > /tmp/alert.json
        curl -H 'Content-Type: application/json' -d @/tmp/alert.json $WEBHOOK
        echo 0 > $NODE_FLAG
    fi
fi

if [ $(ls $KONG_FLAG 2>/dev/null | wc -l) -eq 0 ]
then
    echo 0 > $KONG_FLAG
fi

if [[ $(curl --silent --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api/v1/namespaces/platform/pods?label=kong-kong | jq '.items[] | select((.metadata.name? | match("kong-kong-*")) and any(.status.containerStatuses[]; .state.waiting.reason=="CrashLoopBackOff")).metadata.name') != '' ]]
then
    if [ $(cat $KONG_FLAG | grep 0 | wc -l) -gt 0 ]
    then
        echo 1 > $KONG_FLAG
        sed -e "s/XXXDATEXXX/$(date)/g" -e "s/XXXCOLORXXX/$RED/g" -e "s/XXXALERTXXX/$ALERT/g" -e "s/XXXSUMMARYXXX/$KONG_SUMMARY/g" tmpl.json > /tmp/alert.json
        curl -H 'Content-Type: application/json' -d @/tmp/alert.json $WEBHOOK
    fi
else
    if [ $(cat $KONG_FLAG | grep 1 | wc -l) -gt 0 ]
    then
        sed -e "s/XXXDATEXXX/$(date)/g" -e "s/XXXCOLORXXX/$GREEN/g" -e "s/XXXALERTXXX/$RESOLVED/g" -e "s/XXXSUMMARYXXX/$KONG_SUMMARY/g" tmpl.json > /tmp/alert.json
        curl -H 'Content-Type: application/json' -d @/tmp/alert.json $WEBHOOK
        echo 0 > $KONG_FLAG
    fi
fi