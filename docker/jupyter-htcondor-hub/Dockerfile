
# Build as jupyterhub/singleuser
# Run with the DockerSpawner in JupyterHub

FROM bbockelm/jupyter-base-hub

MAINTAINER Brian Bockelman <bbockelm@cse.unl.edu>

USER root

# Overwrites the startup script from JupyterHub; this script basically
# does the same thing but also invokes condor_master
ADD singleuser.sh /srv/singleuser/singleuser.sh

USER jovyan

# Add custom HTCondor configurations
ADD user_config /home/jovyan/.condor/user_config

# Create directories that HTCondor won't create itself.
RUN mkdir -p /home/jovyan/condor/{execute,lock,log,run,spool}

CMD ["sh", "/srv/singleuser/singleuser.sh"]

