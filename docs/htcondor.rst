
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

      :param pool: A ``host:port`` pair specified for the remote collector
         (or a list of pairs for HA setups). If omitted, the value of
         configuration parameter ``COLLECTOR_HOST`` is used.
      :type pool: str or list[str]

   .. method:: locate( daemon_type, name )

      Query the ``condor_collector`` for a particular daemon.

      :param daemon_type: The type of daemon to locate.
      :type daemon_type: :class:`DaemonTypes`
      :param str name: The name of daemon to locate. If not specified, it searches for the local daemon.
      :return: a minimal ClassAd of the requested daemon, sufficient only to contact the daemon;
         typically, this limits to the ``MyAddress`` attribute.
      :rtype: :class:`classad.ClassAd`

   .. method:: locateAll( daemon_type )

      Query the condor_collector daemon for all ClassAds of a particular type. Returns a list of matching ClassAds.

      :param daemon_type: The type of daemon to locate.
      :type daemon_type: :class:`DaemonTypes`
      :return: Matching ClassAds
      :rtype: list[:class:`classad.ClassAd`]

   .. method:: query( ad_type, constraint='true', attrs=[], statistics='' )

      Query the contents of a condor_collector daemon. Returns a list of ClassAds that match the constraint parameter.

      :param ad_type: The type of ClassAd to return. If not specified, the type will be ANY_AD.
      :type ad_type: :class:`AdTypes`
      :param constraint: A constraint for the collector query; only ads matching this constraint are returned.
         If not specified, all matching ads of the given type are returned.
      :type constraint: str or :class:`classad.ExprTree`
      :param attrs: A list of attributes to use for the projection.  Only these attributes, plus a few server-managed,
         are returned in each :class:`classad.ClassAd`.
      :type attrs: list[str]
      :param list[str] statistics: Statistics attributes to include, if they exist for the specified daemon.
      :return: A list of matching ads.
      :rtype: list[:class:`classad.ClassAd`]

   .. directQuery( daemon_type, (str)name = '', projection = [], statistics = '' )

      Query the specified daemon directly for a ClassAd, instead of using the ClassAd from the ``condor_collector`` daemon.
      Requires the client library to first locate the daemon in the collector, then querying the remote daemon.

      :param daemon_type: Specifies the type of the remote daemon to query.
      :type daemon_type: :class:`DaemonTypes`
      :param str name: Specifies the daemon's name. If not specified, the local daemon is used.
      :param projection: is a list of attributes requested, to obtain only a subset of the attributes from the daemon's :class:`classad.ClassAd`.
      :type projection: list[str]
      :param statistics: Statistics attributes to include, if they exist for the specified daemon.
      :type statistics: str
      :return: The ad of the specified daemon.
      :rtype: :class:`classad.ClassAd`

   .. method:: advertise( ad_list, command="UPDATE_AD_GENERIC", use_tcp=True )

      Advertise a list of ClassAds into the condor_collector.

      :param ad_list: :class:`classad.ClassAds` to advertise.
      :type ad_list: list[:class:`classad.ClassAds`]
      :param str command: An advertise command for the remote ``condor_collector``. It defaults to ``UPDATE_AD_GENERIC``.
         Other commands, such as ``UPDATE_STARTD_AD``, may require different authorization levels with the remote daemon.
      :param bool use_tcp: When set to true, updates are sent via TCP.  Defaults to ``True``.


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

.. class:: DaemonTypes

   An enumeration of different types of daemons available to HTCondor.

   .. attribute:: Collector

      Ads representing the ``condor_collector``.

   .. attribute:: Negotiator

      Ads representing the ``condor_negotiator``.

   .. attribute:: Schedd

      Ads representing the ``condor_schedd``.

   .. attribute:: Startd

      Ads representing the resources on a worker node.

   .. attribute:: HAD

      Ads representing the high-availability daemons (``condor_had``).

   .. attribute:: Master

      Ads representing the ``condor_master``.

   .. attribute:: Generic

      All other ads that are not categorized as above.

   .. attribute:: Any

      Any type of daemon; useful when specifying queries where all matching
      daemons should be returned.

.. _useful_enums:

Useful Enumerations
-------------------

TODO: This section has not yet been written.
