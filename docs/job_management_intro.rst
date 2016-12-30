
Submitting and Managing Jobs
============================

The two most common HTCondor command line tools are ``condor_q`` and ``condor_submit``; in :doc:`htcondor_intro`
we learning the :meth:`~htcondor.Schedd.xquery` method that corresponds to ``condor_q``.  Here, we will learn the
Python binding equivalent of ``condor_submit``.

As usual, we start by importing the relevant modules::

   >>> import htcondor


