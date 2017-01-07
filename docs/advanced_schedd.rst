
Advanced Schedd Interaction
===========================

The introductory tutorial only scratches the surface of what the Python bindings
can do with the ``condor_schedd``; this module focuses on covering a wider range
of functionality:

*  Job and history querying.
*  Advanced job submission.
*  Python-based negotiation with the Schedd.

Job and History Querying
------------------------

In :doc:`htcondor_intro`, we covered the :meth:`~htcondor.Schedd.xquery` method
and its two most important keywords:

*  ``requirements``: Filters the jobs the schedd should return.
*  ``projection``: Filters the attributes returned for each job.

For those familiar with SQL queries, ``requirements`` performs the equivalent
as the ``WHERE`` clause while ``projection`` performs the equivalent of the column
listing in ``SELECT``.

There are two other keywords worth mentioning:

*  ``limit``: Limits the number of returned ads; equivalent to SQL's ``LIMIT``.
*  ``opts``: Additional flags to send to the schedd to alter query behavior.
   The only flag currently defined is :attr:`~QueryOpts.AutoCluster`; this
   groups the returned results by the current set of "auto-cluster" attributes
   used by the pool.  It's analogous to ``GROUP BY`` in SQL, except the columns
   used for grouping are controlled by the schedd.

To illustrate these additional keywords, let's first submit a few jobs::

   >>> schedd = htcondor.Schedd()
   >>> sub = htcondor.Submit({
   ...                        "executable": "/bin/sleep",
   ...                        "arguments":  "5m",
   ...                        "hold":       "True",
   ...                       })
   >>> with schedd.transaction() as txn:
   ...     clusterId = sub.queue(10)

.. note:: In this example, we used the ``hold`` submit command to indicate that
   the jobs `should start out in the ``condor_schedd`` in the *Hold* state; this
   is used simply to prevent the jobs from running to completion while you are
   running the tutorial.

We now have 10 jobs running under ``clusterId``; they should all be identical::

   >>> print sum(1 for _ in schedd.xquery(projection=["ProcID"], requirements="ClusterId==%d" % clusterId, limit=5))
   5
   >>> print list(schedd.xquery(projection=["ProcID"], requirements="ClusterId==%d" % clusterId, opts=htcondor.QueryOpts.AutoCluster))

The ``sum(1 for _ in ...)`` syntax is a simple way to count the number of items
produced by an iterator without buffering all the objects in memory.

### Querying many Schedds

On larger pools, it's common to write python scripts that interact with not one but many schedds.  For example,
if you want to implement a "global query" (equivalent to ``condor_q -g``; concatenates all jobs in all schedds),
it might be tempting to write code like this::

   >>> jobs = []
   >>> for schedd_ad in htcondor.Collector().locateAll(htcondor.DaemonTypes.Schedd):
   ...     schedd = htcondor.Schedd(schedd_ad)
   ...     jobs += schedd.xquery()
   >>> print len(jobs)

This is sub-optimal for two reasons:

*  ``xquery`` is not given any projection, meaning it will pull all attributes for all jobs -
   much more data than is needed for simply counting jobs.
*  The querying across all schedds is serialized: we may wait for painfully long on one or two
   "bad apples"

We can instead begin the query for all schedds simultaneously, then read the responses as
they are sent back.  First, we start all the queries without reading responses::

   >>> queries = []
   >>> coll_query = coll.locate(htcondor.AdTypes.Schedd)
   >>> end = time.time()
   >>> for schedd_ad in coll_query:
   ...     schedd_obj = htcondor.Schedd(schedd_ad)
   ...     queries.append(schedd_obj.xquery())

The iterators will yield the matching jobs; to return the autoclusters instead of jobs, use
the ``AutoCluster`` option (``schedd_obj.xquery(opts=htcondor.QueryOpts.AutoCluster)``).  One
auto-cluster ad is returned for each set of jobs that have identical values for all significant
attributes.  A sample auto-cluster looks like::

       [
        RequestDisk = DiskUsage;
        Rank = 0.0;
        FileSystemDomain = "hcc-briantest7.unl.edu";
        MemoryUsage = ( ( ResidentSetSize + 1023 ) / 1024 );
        ImageSize = 1000;
        JobUniverse = 5;
        DiskUsage = 1000;
        JobCount = 1;
        Requirements = ( TARGET.Arch == "X86_64" ) && ( TARGET.OpSys == "LINUX" ) && ( TARGET.Disk >= RequestDisk ) && ( TARGET.Memory >= RequestMemory ) && ( ( TARGET.HasFileTransfer ) || ( TARGET.FileSystemDomain == MY.FileSystemDomain ) );
        RequestMemory = ifthenelse(MemoryUsage isnt undefined,MemoryUsage,( ImageSize + 1023 ) / 1024);
        ResidentSetSize = 0;
        ServerTime = 1483758177;
        AutoClusterId = 2
       ]

We use the :func:`poll` function, which will return when a query has available results::

   >>> job_counts = {}
   >>> for query in htcondor.poll(queries):
   ...    schedd_name = query.tag()
   ...    job_counts.setdefault(schedd_name, 0)
   ...    count = len(query.nextAdsNonBlocking())
   ...    job_counts[schedd_name] += count
   ...    print "Got %d results from %s." % (count, schedd_name)
   >>> print job_counts

The :meth:`~htcondor.QueryIterator.tag` tag is used to identify which query is returned; the
tag defaults to the Schedd's name but can be manually set through the ``tag`` keyword argument
to :meth:`~htcondor.Schedd.xquery`.

### History Queries

After a job has finished in the Schedd, it moves from the queue to the history file.  The
history can be queried (locally or remotely) with the :meth:`~htcondor.Schedd.history` method::

   >>> schedd = htcondor.Schedd()
   >>> for ad in schedd.history('true', ['ProcId', 'ClusterId', 'JobStatus', 'WallDuration'], 2):
   ...     print ad

At the time of writing, unlike :meth:`~htcondor.Schedd.xquery`, :meth:`~htcondor.Schedd.history`
takes positional arguments and not keyword.  The first argument a job constraint; second is the
projection list; the third is the maximum number of jobs to return.

Advanced Job Submission
-----------------------

TODO - this section has yet to be written.

Negotiation with the Schedd
---------------------------

TODO - this section has yet to be written.

