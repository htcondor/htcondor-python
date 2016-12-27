
Jupyter Dockerfiles for HTCondor
================================

This repository contains several Dockerfiles for use in the JupyterHub-based
HTCondor tutorials.

Effectively, they are a fork of the Dockerfiles maintained by the JupyterHub
project, swapping the underlying OS for RHEL7 (as this has broader support from
the OSG) and adding a personal HTCondor instance that launches alongside the
notebook.  Accordingly, I have left the upstream's copyright statements and
license (BSD 3-clause) in place.

