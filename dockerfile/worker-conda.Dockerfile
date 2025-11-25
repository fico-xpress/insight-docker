ARG IMAGE_WORKER
FROM ${IMAGE_WORKER}

USER root
SHELL ["/bin/bash", "-c"]

RUN echo "Running security updates on insight-worker" \
    && yum -y --setopt=timeout=30 --security update \
    && yum clean all \
    && rm -rf /var/cache/yum

# Installers and checksums can be found here: https://docs.anaconda.com/miniconda/miniconda-other-installer-links/
ARG MINICONDA_VERSION="py312_24.4.0-0"
ARG MINICONDA_URL_BASE="https://repo.anaconda.com/miniconda"
ARG MINICONDA_CHECKSUM_X64="b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
ARG MINICONDA_CHECKSUM_ARM64="832d48e11e444c1a25f320fccdd0f0fabefec63c1cd801e606836e1c9c76ad51"
ARG MINICONDA_DIR="/opt/miniconda"

# Install Miniconda

RUN echo "Installing miniconda" \
    && case `arch` in \
        aarch64|arm64) \
           ARCH_CONDA=aarch64  \
           MINICONDA_CHECKSUM=${MINICONDA_CHECKSUM_ARM64} \
           ;; \
        *) \
           ARCH_CONDA=x86_64 \
           MINICONDA_CHECKSUM=${MINICONDA_CHECKSUM_X64} \
        ;; \
    esac \
    && MINICONDA_URL="${MINICONDA_URL_BASE}/Miniconda3-${MINICONDA_VERSION}-Linux-${ARCH_CONDA}.sh" \
    && curl ${CURL_ARGS} --location --output miniconda.sh ${MINICONDA_URL} \
    && echo "${MINICONDA_CHECKSUM}  miniconda.sh" | sha256sum -c \
    && mv miniconda.sh /tmp/miniconda.sh \
    && chmod u+x /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p ${MINICONDA_DIR} \
    && rm -rf /tmp/miniconda.sh \
    && ln -s /opt/miniconda/bin/conda /usr/bin/conda \
    && echo "Replacing default conda repository with conda-forge" \
    && conda config --system --append channels conda-forge \
    && conda config --system --remove channels defaults \
    && conda init bash --system

USER worker
WORKDIR /worker
ENV CONDA_ROOT_PREFIX=/home/worker/.conda

# Copy environments
COPY --chown=worker:worker --chmod=755 dockerfile/conda-entrypoint.sh .
COPY --chown=worker:worker ../environments/* ./environments/
VOLUME /worker/environments/

ENTRYPOINT [ "tini", "--", "./conda-entrypoint.sh" ]