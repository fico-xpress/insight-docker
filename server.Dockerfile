ARG IMAGE_SERVER
FROM ${IMAGE_SERVER}

USER root

RUN echo "Running security updates on insight-server" \
    && yum -y --setopt=timeout=30 --security update \
    && yum clean all \
    && rm -rf /var/cache/yum

USER xpress

ENTRYPOINT [ "tini", "--", "./entrypoint.sh" ]