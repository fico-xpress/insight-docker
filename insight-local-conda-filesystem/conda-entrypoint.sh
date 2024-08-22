#!/bin/bash
set -e
source ~/.bashrc

# Check if environment exists
if ! { conda env list | grep "${MINICONDA_ENV}"; } >/dev/null 2>&1; then
  echo "Creating environment ${MINICONDA_ENV}"
  conda env create -f ./environments/environment.yml
else
  echo "Updating environment ${MINICONDA_ENV}"
  conda env update -f ./environments/environment.yml --prune
fi

echo "Activating environment ${MINICONDA_ENV}"
conda activate "${MINICONDA_ENV}"

# Run original entrypoint
./entrypoint.sh