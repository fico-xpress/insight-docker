ARG IMAGE_WORKBENCH
FROM ${IMAGE_WORKBENCH}

ARG XPRESS_USER_ID=1000
ARG XPRESS_GROUP_ID=1000

USER root

# Make this explicit on startup to avoid pemissions race condition
# with server on macOS.
RUN mkdir -p /public-certificates
RUN chown -R ${XPRESS_USER_ID}:${XPRESS_GROUP_ID} /public-certificates
RUN chmod -R o+r /public-certificates

RUN echo "Running security updates on workbench" \
    && yum -y --setopt=timeout=30 --security update \
    && yum clean all \
    && rm -rf /var/cache/yum

USER workbench

CMD ["/bin/bash", "/workbench-app/run.local.sh"]