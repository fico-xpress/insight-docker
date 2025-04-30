ARG IMAGE_WORKBENCH
FROM ${IMAGE_WORKBENCH}

USER root

RUN echo "Running security updates on workbench" \
    && yum -y --setopt=timeout=30 --security update \
    && yum clean all \
    && rm -rf /var/cache/yum

USER workbench

CMD ["/bin/bash", "/workbench-app/run.local.sh"]