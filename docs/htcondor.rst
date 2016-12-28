
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

   :param file_obj: A file-like object corresponding to an HTCondor event log.
   :param bool is_xml: Specifies whether the event log is XML-formatted.


.. _schedd_class:

Module Classes
--------------

.. class:: Schedd

   Client object for a remote ``condor_schedd``.

   .. method:: __init__( location_ad=None )

      Create an instance of the :class:`Schedd` class.

      :param location_ad: describes the location of the remote ``condor_schedd``
         daemon, as returned by the :meth:`Collector.locate` method. If the parameter is omitted,
         the local ``condor_schedd`` daemon is used.
      :type location_ad: :class:`classad.ClassAd`

   .. method:: transaction(flags=0, continue_txn=False)

      Start a transaction with the ``condor_schedd``.

      Starting a new transaction while one is ongoing is an error unless the ``continue_txn``
      flag is set.

      :param flags: Flags controlling the behavior of the transaction, defaulting to 0.
      :type flags: :class:`TransactionFlags`
      :param bool continue_txn: Set to ``True`` if you would like this transaction to extend any
         pre-existing transaction; defaults to ``False``.  If this is not set, starting a transaction
         inside a pre-existing transaction will cause an exception to be thrown.
      :return: A transaction context manager object.

   .. method:: query( constraint='true', attr_list=[], callback=None, limit=-1, opts=QueryOpts.Default )

      Query the ``condor_schedd`` daemon for jobs.
      
      .. note:: This returns a *list* of :class:`~classad.ClassAd` objects, meaning all results must
         be buffered in memory.  This may be memory-intensive for large responses; we strongly recommend
         to utilize the :meth:`xquery`

      :param constraint: Query constraint; only jobs matching this constraint will be returned; defaults to ``'true'``.
      :type constraint: str or :class:`class.ExprTree`
      :param attr_list: Attributes for the ``condor_schedd`` daemon to project along.
         At least the attributes in this list will be returned.
         The default behavior is to return all attributes.
      :type attr_list: list[str]
      :param callback: A callable object; if provided, it will be invoked for each ClassAd.
         The return value (if note ``None``) will be added to the returned list instead of the
         ad.
      :param int limit: The maximum number of ads to return; the default (``-1``) is to return
         all ads.
      :param opts: Additional flags for the query; these may affect the behavior of the ``condor_schedd``.
      :type opts: :class:`QueryOpts`.
      :return: ClassAds representing the matching jobs.
      :rtype: list[:class:`classad.ClassAd`]

   .. method:: xquery( requirements='true', projection=[] , limit=-1 , opts=QueryOpts.Default , name=None)
   
      Query the condor_schedd daemon for jobs.
      
      As opposed to :meth:`query`, this returns an *iterator*, meaning only one ad is buffered in memory at a time.

      :param requirements: provides a constraint for filtering out jobs. It defaults to ``'true'``.
      :type requirements: str or :class:`~classad.ExprTree`
      :param projection: The attributes to return; an empty list (the default) signifies all attributes.
      :type projection: list[str]
      :param int limit: A limit on the number of matches to return.  The default (``-1``) indicates all
         matching jobs should be returned.
      :param opts: Additional flags for the query, from :class:`QueryOpts`.
      :type opts: :class:`QueryOpts`
      :param str name: A tag name for the returned query iterator. This string will always be
         returned from the :meth:`QueryIterator.tag` method of the returned iterator.
         The default value is the ``condor_schedd``'s name. This tag is useful to identify
         different queries when using the :function:`poll` function.
      :return: An iterator for the matching job ads
      :rtype: :class:`~htcondor.QueryIterator`

   .. method:: act( action, job_spec )

      Change status of job(s) in the ``condor_schedd`` daemon. The return value is a ClassAd object
      describing the number of jobs changed.

      This will throw an exception if no jobs are matched by the constraint.

      :param action: The action to perform; must be of the enum JobAction.
      :type action: :class:`JobAction`
      :param job_spec: The job specification. It can either be a list of job IDs or a string specifying a constraint.
         Only jobs matching this description will be acted upon.
      :type job_spec: list[str] or str

   .. method:: edit( job_spec, attr, value )

      Edit one or more jobs in the queue.
      
      This will throw an exception if no jobs are matched by the ``job_spec`` constraint.

      :param job_spec: The job specification. It can either be a list of job IDs or a string specifying a constraint.
         Only jobs matching this description will be acted upon.
      :type job_spec: list[str] or str
      :param str attr: The name of the attribute to edit.
      :param value: The new value of the attribute.  It should be a string, which will
         be converted to a ClassAd expression, or an ExprTree object.  Be mindful of quoting
         issues; to set the value to the string ``foo``, one would set the value to ``'"foo"'``
      :type value: str or :class:`~classad.ExprTree`

   .. method:: history( requirements, projection, match=1 )

      Fetch history records from the ``condor_schedd`` daemon.

      :param requirements: Query constraint; only jobs matching this constraint will be returned;
         defaults to ``'true'``.
      :type constraint: str or :class:`class.ExprTree`
      :param projection: Attributes that are to be included for each returned job.
         The empty list causes all attributes to be included.
      :type projection: list[str]
      :param int match: An limit on the number of jobs to include; the default (``-1``)
         indicates to return all matching jobs.
      :return: All matching ads in the Schedd history, with attributes according to the
         ``projection`` keyword.
      :rtype: :class:`HistoryIterator`

   .. method:: submit( ad, count = 1, spool = false, ad_results = None )
   
      Submit one or more jobs to the ``condor_schedd`` daemon.

      This method requires the invoker to provide a ClassAd for the new job cluster;
      such a ClassAd contains attributes with different names than the commands in a
      submit description file. As an example, the stdout file is referred to as ``output``
      in the submit description file, but ``Out`` in the ClassAd.
      
      .. hint:: To generate an example ClassAd, take a sample submit description
         file and invoke::

            condor_submit -dump <filename> [cmdfile]

         Then, load the resulting contents of ``<filename>`` into Python.

      :param ad: The ClassAd describing the job cluster.
      :type ad: :class:`~classad.ClassAd`
      :param int count: The number of jobs to submit to the job cluster. Defaults to ``1``.
      :param bool spool: If ``True``, the clinent inserts the necessary attributes
         into the job for it to have the input files spooled to a remote 
         ``condor_schedd`` daemon. This parameter is necessary for jobs submitted
         to a remote ``condor_schedd`` that use HTCondor file transfer.
      :param ad_results: If set to a list, the list object will contain the job ads
         resulting from the job submission.
         These are needed for interacting with the job spool after submission.
      :type ad_results: list[:class:`~classad.ClassAd`]
      :return: The newly created cluster ID.
      :rtype: int

   .. method:: submitMany( cluster_ad, proc_ads, spool = false, ad_results = None )

      Submit multiple jobs to the ``condor_schedd`` daemon, possibly including
      several distinct processes.

      :param cluster_ad: The base ad for the new job cluster; this is the same format
         as in the :meth:`submit` method.
      :param list proc_ads: A list of 2-tuples; each tuple has the format of ``(proc_ad, count)``.
         For each list entry, this will result in count jobs being submitted inheriting from
         both ``cluster_ad`` and ``proc_ad``.
      :param bool spool: If ``True``, the clinent inserts the necessary attributes
         into the job for it to have the input files spooled to a remote 
         ``condor_schedd`` daemon. This parameter is necessary for jobs submitted
         to a remote ``condor_schedd`` that use HTCondor file transfer.
      :param ad_results: If set to a list, the list object will contain the job ads
         resulting from the job submission.
         These are needed for interacting with the job spool after submission.
      :type ad_results: list[:class:`~classad.ClassAd`]
      :return: The newly created cluster ID.
      :rtype: int

   .. method:: spool(ad_list)

      Spools the files specified in a list of job ClassAds
      to the ``condor_schedd``.

      :param ad_list: A list of job descriptions; typically, this is the list
         filled by the ``ad_results`` argument of the :meth:`submit` method call.
      :type ad_list: list[:class:`~classad.ClassAds`]
      :raises RuntimeError: if there are any errors.

   .. method:: retrieve(job_spec)

      Retrieve the output sandbox from one or more jobs.

      :param job_spec: An expression matching the list of job output sandboxes
         to retrieve.
      :type job_spec: list[:class:`~classad.ClassAd`]
      
   .. method:: refreshGSIProxy(cluster, proc, filename, lifetime)
   
      Refresh the GSI proxy of a job; the job's proxy will be replaced the contents
      of the provided ``filename``.

      .. note:: Depending on the lifetime of the proxy in filename, the resulting lifetime
         may be shorter than the desired lifetime.

      :param int cluster: Cluster ID of the job to alter.
      :param int proc: Process ID of the job to alter.
      :param int lifetime: Indicates the desired lifetime (in seconds) of the delegated proxy.
         A value of ``0`` specifies to not shorten the proxy lifetime.
         A value of ``-1`` specifies to use the value of configuration variable
         ``DELEGATE_JOB_GSI_CREDENTIALS_LIFETIME``.

   .. method:: negotiate( (str)accounting_name )

      Begin a negotiation cycle with the remote schedd for a given user.

      .. note:: The returned :class:`ScheddNegotiate` additionally serves as a context manager,
         automatically destroying the negotiation session when the context is left.

      :param str accounting_name: Determines which user the client will start negotiating with.
      :return: An iterator which yields resource request ClassAds from the ``condor_schedd``.
         Each resource request represents a set of jobs that are next in queue for the schedd
         for this user.
      :rtype: :class:`ScheddNegotiate`
      
   .. method:: reschedule()

      Send reschedule command to the schedd.


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

   .. directQuery( daemon_type, name = '', projection = [], statistics = '' )

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

TODO: This section has not yet been written.

.. _useful_enums:

Useful Enumerations
-------------------

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


.. class:: JobAction

   Different actions that may be performed on a job in queue.

   .. attribute:: Hold

      Put a job on hold, vacating a running job if necessary.  A job will stay in the hold state until explicitly acted upon by the admin or owner.

   .. attribute:: Release

      Release a job from the hold state, returning it to ``Idle``.

   .. attribute:: Suspend

      Suspend the processes of a running job (on Unix platforms, this triggers a ``SIGSTOP``).
      The job's processes stay in memory but no longer get scheduled on the CPU.

   .. attribute:: Continue

      Continue a suspended jobs (on Unix, ``SIGCONT``).
      The processes in a previously suspended job will be scheduled to get CPU time again.

   .. attribute:: Remove

      Remove a job from the Schedd's queue, cleaning it up first on the remote host (if running).
      This requires the remote host to acknowledge it has successfully vacated the job, meaning ``Remove`` may not be instantaneous.

   .. attribute:: RemoveX

      Immediately remove a job from the schedd queue, even if it means the job is left running on the remote resource.

   .. attribute:: Vacate

      Cause a running job to be killed on the remote resource and return to idle state.
      With ``Vacate``, jobs may be given significant time to cleanly shut down.

   .. attribute:: VacateFast

      Vacate a running job as quickly as possible, without providing time for the job to cleanly terminate.


.. class:: TransactionFlags

   Flags affecting the characteristics of a transaction.

   .. attribute:: NonDurable

      Non-durable transactions are changes that may be lost when the ``condor_schedd``
      crashes.  ``NonDurable`` is used for performance, as it eliminates extra ``fsync()`` calls.

   .. attribute:: SetDirty

      This marks the changed ClassAds as dirty, causing an update notification to be sent
      to the ``condor_shadow`` and the ``condor_gridmanager``, if they are managing the job.

  .. attribute:: ShouldLog

     Causes any changes to the job queue to be logged in the relevant job event log.

.. class:: QueryOpts

   Flags sent to the ``condor_schedd`` during a query to alter its behavior.
   
   .. attribute:: Default
   
      Queries should use all default behaviors.
      
   .. attribute:: AutoCluster
   
      Instead of returning job ads, return an ad per auto-cluster.
      
