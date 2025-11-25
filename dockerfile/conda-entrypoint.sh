#!/bin/bash
set -e
source ~/.bashrc

# Check if environment exists
while read -r YMLPATH; do
    echo "Updating environment from $YMLPATH"
    conda env update -f "$YMLPATH" --prune
done < <(find ./environments -type f -name environment.yml)

if [ -z "${MINICONDA_ENV}" ]; then
  echo 'Variable MINICONDA_ENV not set, so not activating a default Conda environment'
else
  echo "Activating environment ${MINICONDA_ENV}"
  conda activate "${MINICONDA_ENV}"
  echo "Environment ${MINICONDA_ENV} successfully activated"
  if [ -f "${CONDA_ROOT_PREFIX}/envs/${MINICONDA_ENV}/bin/python" ]; then
    export PYTHON_EXE="${CONDA_ROOT_PREFIX}/envs/${MINICONDA_ENV}/bin/python"
  fi
  if [ -d "${CONDA_ROOT_PREFIX}/envs/${MINICONDA_ENV}/lib/R" ]; then
    export R_HOME="${CONDA_ROOT_PREFIX}/envs/${MINICONDA_ENV}/lib/R"
  fi
fi

#echo "PYTHON_EXE is <${PYTHON_EXE}>"
#echo "R_HOME is <${R_HOME}>"
#echo "JAVA_HOME is <${JAVA_HOME}>"
#echo "PATH starts with <${PATH%%:/opt*}>"
# Run original entrypoint
./entrypoint.sh