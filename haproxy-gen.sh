#!/bin/sh
set -e

service_host=$1
service_id=$2
service_location=$3

cat >>/usr/local/etc/haproxy/haproxy.cfg <<EOL
global
    pidfile /var/run/haproxy.pid
    log 127.0.0.1:1514 local0

resolvers docker
    nameserver dns 127.0.0.11:53

defaults
    mode    http
    balance roundrobin

    option  http-keep-alive
    option  forwardfor
    option  redispatch

    maxconn 5000
    timeout connect 5s
    timeout client  20s
    timeout server  20s
    timeout queue   30s
    timeout tunnel  3600s
    timeout http-request 5s
    timeout http-keep-alive 15s

frontend services
    bind *:80
    mode http

    option httplog
    log global
    acl url_${service_id}_front path_beg ${service_location}
    acl domain_${service_id}_front hdr(host) -i ${service_host}
    use_backend ${service_id}_back if url_${service_id}_front domain_${service_id}_front

backend ${service_id}_back
    mode http
    log global
    http-request set-path %[path,regsub(${service_location},/)]
    server ${service_id} ${service_id}:80
EOL
