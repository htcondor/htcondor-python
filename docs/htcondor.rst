
:mod:`htcondor` -- HTCondor Reference
=====================================

.. module:: htcondor
   :platform: Unix, Windows, Mac OS X
   :synopsis: Interact with the HTCondor daemons
.. moduleauthor:: Brian Bockelman <bbockelm@cse.unl.edu>

This page is an exhaustive reference of the API exposed by the :mod:`htondor`
module.  It is not meant to be a tutorial for new users but rather a helpful
guide for those who already understand the basic usage of the module.

This reference covers the following:

* :ref:`common_module_functions`: The more commonly-used :mod:`htcondor` functions.
* :class:`Schedd`: Interacting with the ``condor_schedd``.
* :class:`Collector`: Interacting with the ``condor_collector``.
* :class:`Submit`: Submitting to HTCondor.
* :class:`Claim`: Working with HTCondor claims.
* :class:`Param`: Working with the parameter objects.
* :ref:`esoteric_module_functions`: Less-commonly used :mod:`htcondor` functions.
* :ref:`useful_enums`: Useful enumerations.

.. _common_module_functions:

Common Module-Level Functions and Objects
-----------------------------------------

.. function:: platform()

   Returns the platform of HTCondor this module is running on.

.. function:: version()

   Returns the version of HTCondor this module is linked against.

.. function:: reload_config()

   Reload the HTCondor configuration from disk.

.. function:: enable_debug()

   Enable debugging output from HTCondor, where output is sent to ``stderr``.
   The logging level is controlled by the ``TOOL_DEBUG`` parameter.

.. function:: enable_log()

   Enable debugging output from HTCondor, where output is sent to a file.
   The log level is controlled by the parameter ``TOOL_DEBUG``, and the
   file used is controlled by ``TOOL_LOG``.

.. function:: read_events(file_obj, is_xml = True)

   Read and parse an HTCondor event log file. Returns a Python iterator of ClassAds.

   * Parameter ``file_obj`` is a file object corresponding to an HTCondor event log.
   * The optional parameter ``is_xml`` specifies whether the event log is XML-formatted.


.. _schedd_class:

Module Classes
--------------

.. class:: Schedd

   Client object for a remote ``condor_schedd``.

   .. method:: __init__( location_ad )

      Create an instance of the :class:`Schedd` class.

      Optional parameter ``location_ad`` describes the location of the remote ``condor_schedd``
      daemon, as returned by the :meth:`Collector.locate` method. If the parameter is omitted,
      the local ``condor_schedd`` daemon is used.

   .. method:: transaction(flags=0, continue_txn=False)

      Start a transaction with the condor_schedd. Returns a transaction context manager.
      Starting a new transaction while one is ongoing is an error.

      The optional parameter flags defaults to 0. Transaction flags are from the the enum
      :class:`TransactionFlags`, and the three flags are NonDurable, SetDirty, or ShouldLog.
      NonDurable is used for performance, as it eliminates extra fsync() calls. If the
      ``condor_schedd`` crashes before the transaction is written to disk, the transaction
      will be retried on restart of the condor_schedd. SetDirty marks the changed ClassAds
      as dirty, so an update notification is sent to the ``condor_shadow`` and the
      ``condor_gridmanager``.  ``ShouldLog`` causes changes to the job queue to be logged in the job event log file.

      The optional parameter ``continue_txn`` defaults to ``False``; set the value to true to extend an ongoing transaction.


.. _collector_class:

.. class:: Collector

   Client object for a remote ``condor_collector``.  The interaction with the
   collector broadly has three aspects:

   * Locating a daemon.
   * Query the collector for one or more specific ClassAds.
   * Advertise a new ad to the ``condor_collector``.

   .. method:: __init__( pool = None )

      Create an instance of the :class:`Collector` class.

      :param pool: A``host:port`` pair specified for the remote collector
         (or a list of pairs for HA setups). If omitted, the value of
         configuration parameter ``COLLECTOR_HOST`` is used.
      :type pool: str or list[str]

   .. locate( daemon_type, name )

      Query the ``condor_collector`` for a particular daemon.

      :param htcondor.DaemonTypes daemon_type: The type of daemon to locate.
      :param name: The name of daemon to locate. If not specified, it searches for the local daemon.
      :return: a minimal ClassAd of the requested daemon, sufficient only to contact the daemon;
         typically, this limits to the ``MyAddress`` attribute.
      :rtype: classad.ClassAd


.. _submit_class:

.. class:: Submit

   TODO: This section has not yet been written.


.. _claim_class:

.. class:: Claim

   TODO: This section has not yet been written.

.. _param_class:

.. class:: Param

   TODO: This section has not yet been written.


.. _esoteric_module_functions:

Esoteric Module-Level Functions
-------------------------------

TODO: This section has not yet been written.


.. _useful_enums:

Useful Enumerations
-------------------

TODO: This section has not yet been written.
