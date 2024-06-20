# for fluentbit log
create database fluentbit;
set allow_experimental_object_type=1;
create table kube (timestamp DateTime, log Object('json'), host LowCardinality(String), pod_name LowCardinality(String)) engine = MergeTree order by (host, pod_name, timestamp);
# for tetragon
create table tetragon (timestamp DateTime, process Object('json'),  namespace LowCardinality(String), node_name LowCardinality(String), pod_name LowCardinality(String)) engine = MergeTree order by (pod_name, node_name, namespace, timestamp);