
# Build as jupyterhub/singleuser
# Run with the DockerSpawner in JupyterHub

FROM bbockelm/jupyter-base-hub

MAINTAINER Brian Bockelman <bbockelm@cse.unl.edu>

USER root

# Create CVMFS root directory.
RUN mkdir /cvmfs

# Overwrites the startup script from JupyterHub; this script basically
# does the same thing but also invokes condor_master
ADD singleuser.sh /srv/singleuser/singleuser.sh

USER jovyan

# Add custom HTCondor configurations
ADD user_config /home/jovyan/.condor/user_config

# Create directories that HTCondor won't create itself.
# Additionally, checkout the tutorials; note we'll attempt to update these at notebook launch.
RUN mkdir -p /home/jovyan/condor/{execute,lock,log,run,spool} /home/jovyan/work && \
    curl -L https://api.github.com/repos/bbockelm/htcondor-python/tarball  | tar zx  --strip-components=1 '*/notebooks' -C /home/jovyan/work

CMD ["sh", "/srv/singleuser/singleuser.sh"]

