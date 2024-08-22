ARG IMAGE_WORKER
FROM ${IMAGE_WORKER}

USER root
SHELL ["/bin/bash", "-c"]

# Installers and checksums can be found here: https://docs.anaconda.com/miniconda/miniconda-other-installer-links/
ARG MINICONDA_VERSION="py312_24.4.0-0"
ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh"
ARG MINICONDA_CHECKSUM_ARM64="b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
ARG MINICONDA_DIR="/opt/miniconda"

# Install Miniconda

RUN echo "Installing miniconda" \
    && curl ${CURL_ARGS} --location --output miniconda.sh ${MINICONDA_URL} \
    && echo "${MINICONDA_CHECKSUM_ARM64}  miniconda.sh" | sha256sum -c \
    && mv miniconda.sh /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p ${MINICONDA_DIR} \
    && rm -rf /tmp/miniconda.sh \
    && ln -s /opt/miniconda/bin/conda /usr/bin/conda \
    && echo "Replacing default conda repository with conda-forge" \
    && conda config --system --append channels conda-forge \
    && conda config --system --remove channels defaults \
    && conda init bash --system

USER worker
WORKDIR /worker

# Copy environments
COPY --chown=worker:worker --chmod=755 conda-entrypoint.sh .
COPY --chown=worker:worker environments/environment.yml ./environments/
VOLUME /worker/environments/

ENTRYPOINT [ "tini", "--", "./conda-entrypoint.sh" ]