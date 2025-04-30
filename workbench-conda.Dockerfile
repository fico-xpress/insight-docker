ARG IMAGE_WORKBENCH
FROM ${IMAGE_WORKBENCH}

USER root
SHELL ["/bin/bash", "-c"]

RUN echo "Running security updates on workbench" \
    && yum -y --setopt=timeout=30 --security update \
    && yum clean all \
    && rm -rf /var/cache/yum

# Installers and checksums can be found here: https://docs.anaconda.com/miniconda/miniconda-other-installer-links/
ARG MINICONDA_VERSION="py312_24.4.0-0"
ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh"
ARG MINICONDA_CHECKSUM_ARM64="b6597785e6b071f1ca69cf7be6d0161015b96340b9a9e132215d5713408c3a7c"
ARG MINICONDA_DIR="/opt/miniconda"

# ------------------------------------------------------------------------------
# 1. Install miniconda + checksums
# ------------------------------------------------------------------------------
RUN echo "Installing miniconda" \
    && curl ${CURL_ARGS} --location --output miniconda.sh ${MINICONDA_URL} \
    && echo "${MINICONDA_CHECKSUM_ARM64}  miniconda.sh" | sha256sum -c \
    && mv miniconda.sh /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p ${MINICONDA_DIR} \
    && rm -rf /tmp/miniconda.sh \
    && ln -s ${MINICONDA_DIR}/bin/conda /usr/bin/conda \
    \
    && echo "Replacing default conda repository with conda-forge" \
    && conda config --system --append channels conda-forge \
    && conda config --system --remove channels defaults \
    && conda init bash --system \
    \
    && ${MINICONDA_DIR}/bin/conda config --system --append envs_dirs /conda/envs \
    \
    && echo "Installing miniconda security fixes" \
    # temporary fix to make sure libarchive and libmamba are compatible by pulling from the same channel
    # https://github.com/conda/conda-libmamba-solver/issues/283
    # previously the security fix below would re-install libarchive from conda-forge and leave libmamba from defaults \
    && ${MINICONDA_DIR}/bin/conda install \
        libxml2=2.12.5 \
        cryptography=42.0.2 \
        libmamba \
        libarchive \
        -c conda-forge --force-reinstall \
    && ${MINICONDA_DIR}/bin/conda clean -a -y

ENV CONDA_EXE=/usr/bin/conda
ENV CONDA_ROOT_PREFIX=/conda
ENV PATH="${MINICONDA_DIR}/bin:${PATH}"

# Verify micromamba
RUN conda --version

# ------------------------------------------------------------------------------
# 2. /conda dirs
# ------------------------------------------------------------------------------
RUN mkdir -p /conda
RUN mkdir -p /conda/envs /conda/locks/projects /conda/locks/users

# ------------------------------------------------------------------------------
# 3. /etc/conda
# ------------------------------------------------------------------------------
RUN mkdir -p /etc/conda && \
    touch /etc/conda/.condarc && \
    chown -R workbench:workbench /etc/conda && \
    chmod -R 777 /etc/conda

# ------------------------------------------------------------------------------
# 4. Final ownership
# ------------------------------------------------------------------------------
RUN chown -R workbench:workbench /conda/envs && \
    chown -R workbench:workbench /conda/locks

USER workbench

WORKDIR /
ENV CONDA_ROOT_PREFIX=/conda
