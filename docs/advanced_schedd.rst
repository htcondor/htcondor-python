
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

