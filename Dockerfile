FROM haproxy:1.7-alpine
MAINTAINER 	Mario Vejlupek <mario@vejlupek.cz>

ENV service_id=change_service_id_var
ENV service_host=change_service_host_var

COPY entrypoint.sh /
COPY haproxy-gen.sh /

ENTRYPOINT ["/entrypoint.sh"]

