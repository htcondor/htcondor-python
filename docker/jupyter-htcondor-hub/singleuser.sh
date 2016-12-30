#!/bin/sh
set -e

notebook_arg=""
if [ -n "${NOTEBOOK_DIR:+x}" ]
then
    notebook_arg="--notebook-dir=${NOTEBOOK_DIR}"
fi

# Attempt to update with the latest tutorials.
curl -L https://api.github.com/repos/bbockelm/htcondor-python/tarball  | tar zx  --strip-components=1 '*/notebooks' -C /home/jovyan/work

condor_master

exec jupyterhub-singleuser \
  --port=8888 \
  --ip=0.0.0.0 \
  --user=$JPY_USER \
  --cookie-name=$JPY_COOKIE_NAME \
  --base-url=$JPY_BASE_URL \
  --hub-prefix=$JPY_HUB_PREFIX \
  --hub-api-url=$JPY_HUB_API_URL \
  ${notebook_arg} \
  $@
