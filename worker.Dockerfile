ARG IMAGE_WORKER
FROM ${IMAGE_WORKER}

USER root

RUN echo "Running security updates on insight-worker" \
    && yum -y --setopt=timeout=30 --security update \
    && yum clean all \
    && rm -rf /var/cache/yum

USER worker

ENTRYPOINT [ "tini", "--", "./entrypoint.sh" ]