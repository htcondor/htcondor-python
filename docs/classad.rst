
:mod:`classad` -- ClassAd reference
===================================

.. module:: classad
   :platform: Unix, Windows, Mac OS X
   :synopsis: Work with the ClassAd language
.. moduleauthor:: Brian Bockelman <bbockelm@cse.unl.edu>

.. class:: ClassAd

   The :class:`ClassAd` object is the python representation of a ClassAd.
   Where possible, the :class:`ClassAd` attempts to mimic a python dictionary.
   When attributes are referenced, they are converted to python values if possible;
   otherwise, they are represented by a :class:`ExprTree` object.
   
   The :class:`ClassAd` object is iterable (returning the attributes) and implements
   the dictionary protocol.  The ``items``, ``keys``, ``values``, ``get``, ``setdefault``,
   and ``update`` methods have the same semantics as a dictionary.
   
   .. method:: __init__( ad )
   
      Create a new ClassAd object; can be initialized via a string (which is
      parsed as an ad) or a dictionary-like object.
      
      .. note:: Where possible, we recommend using the dedicated parsing functions
      (:func:`parseOne`, :func:`parseNext`, or :func:`parseAds`) instead of using
      the constructor.
      
      :param ad: Initial values for this object.
      :type ad: str or dict

   .. method:: eval( attr )
   
      Evaluate an attribute to a python object.  The result will *not* be an :class:`ExprTree`
      but rather an built-in type such as a string, integer, boolean, etc.
      
      :param str attr: Attribute to evaluate.
      :return: The Python object corresponding to the evaluated ClassAd attribute
      :raises ValueError: if unable to evaluate the object.
      
   .. method:: lookup( attr )
   
      Look up the :class:`ExprTree` object associated with attribute.
      
      No attempt will be made to convert to a Python object.

      :param str attr: Attribute to evaluate.
      :return: The :class:`ExprTree` object referenced by ``attr``.

   .. method:: printOld( )
   
      Serialize the ClassAd in the old ClassAd format.

      :return: The "old ClassAd" representation of the ad.
      :rtype: str

   .. method:: flatten( expression )
   
      Given ExprTree object expression, perform a partial evaluation.
      All the attributes in expression and defined in this ad are evaluated and expanded.
      Any constant expressions, such as ``1 + 2``, are evaluated; undefined attributes
      are not evaluated.
      
      :param expression: The expression to evaluate in the context of this ad.
      :type expression: :class:`ExprTree`
      :return: The partially-evaluated expression.
      :rtype: :class:`ExprTree`

   .. method:: matches( ad )
   
      Lookup the ``Requirements`` attribute of given ``ad`` return ``True`` if the
      ``Requirements`` evaluate to ``True`` in our context.

      :param ad: ClassAd whose ``Requirements`` we will evaluate.
      :type ad: :class:`ClassAd`
      :return: ``True`` if we satisfy ``ad``'s requirements; ``False`` otherwise.
      :rtype: bool

   .. method:: symmetricMatch( ad )
   
      Check for two-way matching between given ad and ourselves.
      
      Equivalent to ``self.matches(ad) and ad.matches(self)``.
      
      :param ad: ClassAd to check for matching.
      :type ad: :class:`ClassAd`
      :return: ``True`` if both ads' requirements are satisfied.
      :rtype: bool
      
   .. method:: externalRefs( expr )
   
      Returns a python list of external references found in ``expr``.
      
      An external reference is any attribute in the expression which *is not* defined
      by the ClassAd object.

      :param expr: Expression to examine.
      :type expr: :class:`ExprTree`
      :return: A list of external attribute references.
      :rtype: list[str]

   .. method:: internalRefs( expr )
   
      Returns a python list of internal references found in ``expr``.
      
      An internal reference is any attribute in the expression which *is* defined by the
      ClassAd object.
      
      :param expr: Expression to examine.
      :type expr: :class:`ExprTree`
      :return: A list of internal attribute references.
      :rtype: list[str]

.. class:: ExprTree

   The :class:`ExprTree` class represents an expression in the ClassAd language.
   
   As with typical ClassAd semantics, lazy-evaluation is used.  So, the expression ``"foo" + 1``
   does not produce an error until it is evaluated with a call to ``bool()`` or the :meth:`ExprTree.eval`
   method.
   
   .. note:: The python operators for ExprTree have been overloaded so, if ``e1`` and ``e2`` are :class:`ExprTree` objects,
   then ``e1 + e2`` is also an :class:``ExprTree`` object.  However, Python short-circuit evaluation semantics
   for ``e1 && e2`` cause ``e1`` to be evaluated.  In order to get the "logical and" of the two expressions *without*
   evaluating, use ``e1.and_(e2)``.  Similarly, ``e1.or_(e2)`` results in the "logical or".

   .. method:: __init__( expr )

      Parse the string ``expr`` as a ClassAd expression.
      
      :param str expr: Initial expression, serialized as a string.

   .. method:: __str__( )
   
      Represent and return the ClassAd expression as a string.
      
      :return: Expression represented as a string.
      :rtype: str

   .. method:: __int__( )
   
      Converts expression to an integer (evaluating as necessary).

   .. method:: __float__( )

      Converts expression to a float (evaluating as necessary).

   .. method:: and_(expr2)
   
      Return a new expression, formed by ``self && expr2``.
      
      :param expr2: Right-hand-side expression to "and"
      :type expr2: :class:`ExprTree`
      :return: A new expression, defined to be ``self && expr2``.
      :rtype: :class:`ExprTree`
      
   .. method:: or_(expr2)
   
      Return a new expression, formed by ``self || expr2``.
      
      :param expr2: Right-hand-side expression to "or"
      :type expr2: :class:`ExprTree`
      :return: A new expression, defined to be ``self || expr2``.
      :rtype: :class:`ExprTree`

   .. method:: is_(expr2)
   
      Logical comparison using the "meta-equals" operator.
      
      :param expr2: Right-hand-side expression to ``=?=`` operator.
      :type expr2: :class:`ExprTree`
      :return: A new expression, formed by ``self =?= expr2``.
      :rtype: :class:`ExprTree`

   .. method:: isnt_(expr2)
   
      Logical comparison using the "meta-not-equals" operator.
      
      :param expr2: Right-hand-side expression to ``=!=`` operator.
      :type expr2: :class:`ExprTree`
      :return: A new expression, formed by ``self =!= expr2``.
      :rtype: :class:`ExprTree`

   .. method:: sameAs(expr2)
   
      Returns ``True`` if given :class:`ExprTree` is same as this one.
      
      :param expr2: Expression to compare against.
      :type expr2: :class:`ExprTree`
      :return: ``True`` if and only if ``expr2`` is equivalent to this object.
      :rtype: bool

   .. method:: eval( )
   
      Evaluate the expression and return as a ClassAd value,
      typically a Python object.

      :return: The evaluated expression as a Python object.

