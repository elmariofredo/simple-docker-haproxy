#!/bin/sh
set -e

# Generate haproxy config using command arguments
/haproxy-gen.sh ${service_host} ${service_id} > /usr/local/etc/haproxy/haproxy.cfg

echo "=== GENERATED PROXY CONFIG ===>"
cat /usr/local/etc/haproxy/haproxy.cfg
echo "=== GENERATED PROXY CONFIG ===<"

# Use "haproxy-systemd-wrapper" so we can have proper reloadability implemented by upstream
exec /usr/local/sbin/haproxy-systemd-wrapper -p /var/run/haproxy.pid -f /usr/local/etc/haproxy/haproxy.cfg
