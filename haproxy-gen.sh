#!/bin/sh
set -e

service_host=$1
service_id=$2

cat >>/usr/local/etc/haproxy/haproxy.cfg <<EOL
global
    pidfile /var/run/haproxy.pid
    tune.ssl.default-dh-param 2048
    log 127.0.0.1:1514 local0

    # disable sslv3, prefer modern ciphers
    ssl-default-bind-options no-sslv3
    ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS

    ssl-default-server-options no-sslv3
    ssl-default-server-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS

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
    acl url_service_front path_beg /
    acl domain_service_front hdr(host) -i ${service_host}
    use_backend service_back if url_service_front domain_service_front

backend service_back
    mode http
    log global
    server ${service_id} ${service_id}:80
EOL
