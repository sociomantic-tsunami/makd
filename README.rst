====
Makd
====

Description
===========

**Makd** is a GNU Make library/framework based on Makeit_, adapted to D. It
combines the power of Make and rdmd to provide a lot of free functionality,
like implicit rules to compile binaries (only when necessary), tracking if any
of the source files changed, it improves considerably Make's output, it
provides a default test target that runs unittests and arbitrary integration
tests, it detects if you change the compilation flags and recompile if
necessary, etc.

Makd by default runs dmd1 compiler, as it supports D1, but compiling with D2 is
also supported (see under `D2 support`_ for details).

Versioning
----------

MakD complies with `Netptune <https://github.com/sociomantic-tsunami/neptune>`_
for versioning.

Support Guarantees
------------------

* Major branch development period: undefined
* Maintained minor versions: 2 most recent

Maintained Major Branches
-------------------------

====== ==================== ===============
Major  Initial release date Supported until
====== ==================== ===============
v1.x.x v1.4.0_: 24/06/2016  TBD
====== ==================== ===============
.. _v1.4.0: https://github.com/sociomantic-tsunami/makd/releases/tag/v1.4.0


.. contents::


Files / Quickstart
==================

First of all, is important to clarify that Makd do some assumptions on your
project's layout. All sources files should be located in ``src/`` on the root
of the project (you can override this by overriding the ``$(SRC)`` variable
though). This is the bare minimum you have to know, but there are a few more
conventions (for example, integration tests should go to ``test/``), they will
be explained when explaining the features that rely on them.

Top-level Makefile
------------------
To get started you need to have makd as a submodule (or copy it to your project)
and create a top-level makefile for your project (or convert the old one).

A typical Top-level ``Makefile`` should look like this:

.. code:: make

        # Include the top-level makefile
        include submodules/makd/Makd.mak

Assuming your makd installation is in ``submodules/makd``. By default, the
default target when typing just ``make`` is ``all``, and you can add targets to
it, which will be explained later.

You can change this default target by explicitly overriding the
``.DEFAULT_GOAL`` variable, which tells GNU Make which target should be built
when you just run ``make`` without arguments. If you set it, make sure you
define it **after** including ``Makd.mak``, order is important in this case:

.. code:: make

        # Default goal for building this directory
        .DEFAULT_GOAL := some-target

This ``Makefile`` file should be written only once and never touched again (most
likely). But in your project you might have more than one Makefile, for example
you could have one in your ``src`` directory and another one in your ``test``
directory, so you can do ``make`` in ``src`` without specifying ``-C ..``. Also,
probably your ``.DEFAULT_GOAL`` in the ``src/Makefile`` will be ``all`` while
the one in ``test/Makefile`` can be ``test`` instead.


Build.mak
---------
This is the file where you define what your ``Makefile`` will actually do. Makd
does a lot for you, so this file is usually very terse. To define a binary to
compile, all you need to write in your ``Build.mak`` is this:

.. code:: make

        $B/someapp: $C/src/main/someapp.d

That's it, this is the bare minimum you need. With this you can now write
``make $PWD/build/devel/bin/someapp`` and you should get your binary there (why
``build/devel/bin`` will be explained later in the next section). ``$B`` is
a special variable holding the path where your binaries will be stored, and
``$C`` is a special variable storing the current path (the path where the
current ``Build.mak`` is, not the directory where ``make`` was invoked). Both
are absolute paths, to enable Makd to support building the project from
different locations (to make this work you should refer to all the project
files using this ``$C/`` *prefix* when you refer to the current directory of
your ``Build.mak``).

Usually you want a shortcut to type less, so you might want to add:

.. code:: make

        .PHONY: someapp
        someapp: $B/someapp

Now you can simply write ``make someapp`` to build it. Simple.

But maybe you want to type just ``make``. Since the ``.DEFAULT_GOAL`` defined in
your ``Makefile`` is ``all``, you can use the special ``all`` variable to add
targets to build when is called:

.. code:: make

        all += someapp

Now you can simply write ``make`` and you'll get your program built.

Putting it all together, your file should look like:

.. code:: make

        .PHONY: someapp
        someapp: $B/someapp
        $B/someapp: $C/src/main/someapp.d
        all += someapp


Config.mak
----------
Makd has a lot of configuration variables available. This file lives in the
top-level directory of the project and serves as a global configuration point.
There is only one ``Config.mak`` per project, so the configuration defined here
should make sense for all the ``Makefile``\ s defined across the project. For
example you could redefine the colors used here, or the default DMD binary to
use. This is why this file, when present, should be always added to the version
control system. But normally you shouldn't need to create this file.

This file (and Config.local.mak_) should only define variables, as it's parsed
before any other variables or functions are defined. All the predefined variable
and functions available in Build.mak_ are not available here, except for
``$F``, ``$T`` and ``$R``, so use with care (see `Predefined variables`_ for
details).


Config.local.mak
----------------
This is a local (personal) version of the Config.mak_, so users can customize
the build system to their taste. Here is where you usually should define which
Flavors_ to compile by default, or which colors to use, or the path to
a non-conventional compiler location. This file should never be added to the
version control system.

This file is loaded **after** Config.mak_ so it overrides its values.


The build directory
-------------------
Everything built by Makd is left in the ``build`` directory (or the directory
specified in ``BUILD_DIR_NAME`` variable if you defined it). In the build
directory you can find these other directories and files:

``<flavor>``
        Makd support Flavors_ (also called variants), by default flags are
        provided for the *devel* and the *production* flavors. All the symbols
        produced by the *devel* variant (the default) for example, will live in
        the ``devel`` subdirectory in the build directory.

``last``
        This is a symbolic link to the latest flavor that has been built. Is
        useful to use by script, where you do ``make`` but you don't know the
        name of the default flavor. Then you can just access to ``build/last``.

``doc``
        Generated documentation is put in this directory. Flavors shouldn't
        affect how the documentation is built, so there is only one ``doc``
        directory.

Each flavor directory have a set of files and directories of its own:

``bin``
        This is where the generated binaries are left.

``tmp``
        This is where object files, dependencies files and any other temporary
        file is left. Usually after a build all the contents of this directory
        is trash and only works as a cache. If you remove this directory a new
        build will be triggered next time you run make though, even if nothing
        changed. The project directory structure is replicated inside this
        directory, except for the directories specified by the
        ``BUILD_DIR_EXCLUDE`` variable (by default the build directory itself,
        the ``.git`` directory and the submodule directories).

``pkg``
        Generated packages are built in this directory. You can change this via
        the ``P`` variable.

``build-d-flags``
        A signature file to keep track of building flags changes.



Usage
=====

Building a project
------------------
Once you have the basic setup done, you can already enjoy a lot of small cool
features. For example you get a nice, terse and colorful output, for example::

        mkversion src/Version.d
        rdmd1 build/devel/bin/someapp

If there are any errors, messages will appear in red so they are easier to spot.

If you like the good old make verbose output, just use ``make V=1`` and you'll
get everything. If you don't like colors, just use ``make COLOR=``. Makd also
honours Make options ``--silent``, ``--quiet`` and ``-s``. So if you want to
avoid all output, just use ``make -s`` as usual.

All these variables can be configured in your Config.local.mak_ if you want to
always have it verbose or whatever.

If you want to force a build there is also the not-so-known ``make -B``, there
is no need to use the built-in ``make clean`` target and destroy all your cache
(with all the other Flavors_ you compiled in the past).

By default the ``devel`` flavor is compiled, but you can compile the
``production`` flavor by using ``make F=production``.

Also, if you have several cores, use ``make -j2`` and enjoy of Make's
parallelism for free! (this will use 2 cores, you can use ``-j3`` for 3 and so
on).

If you want to build as much as possible without stopping, you can also use
``make -k`` (for ``--keep-going``) so Make doesn't stop on the first error.
This is particularly useful for Testing_, if you want to find out how many tests
are broken without fixing everything first.

Finally, if you want to speed things up a little bit, you can use ``make -r``,
which suppress the many Make predefined rules, which we don't use and sometime
makes Make evaluate more options than needed.

Of course you can combine many Makd and Make options, and specify more than one
target, for example::

        make -Brj4 F=production V=1 COLOR= all test


Predefined targets
------------------
So, we already shown you can use a couple of built-in predefined targets. The
whole set of predefined targets are:

* ``all``
* ``clean``
* ``test``
* ``fasttest``
* ``unittest``
* ``allunittest``
* ``fastunittest``
* ``integrationtest``
* ``doc``
* ``pkg``
* ``graph-deps``

Not all of them will be useful out of the box, you need to assign other targets
to them to be useful. In this category are: ``all`` and ``doc``. For ``all`` we
already saw how to feed it, just add targets to the predefined variable with
the same name (``all += sometarget``). All those special target behaves the
same.

The built-in ``*unittest`` target will compile and run the unittests in every
``.d`` file found in the ``$(SRC)`` directory. The ``integrationtest`` target
will compile and run every test program in ``test/``. The ``test`` target
includes the ``allunittest`` and ``integrationtest`` targets by default, but
you can add more by using the ``test`` special variable (``test += mytest``).
The ``fasttest`` target will only run the ``fastunittest`` target by default,
but you can add more too by using the ``fasttest`` special variable.

See the Testing_ section for more details.

The ``pkg`` target builds all packages defined in ``$P``, see Packaging_
section for more details.

The ``clean`` target simply removes `The build directory`_ recursively. Just
remember to put all your generated files there and the clean target will always
work ;). If you can't do that (because you generated a source file for example),
you can use the special variable ``clean`` too (``clean += src/trash.d
src/garbage.d`` for example).

The ``doc`` target will, by default, call `harbored-mod
<https://github.com/kiith-sa/harbored-mod>`_ tool to generate the documentation
for the project from DDOC comments inside source files.  Harbored-mod is
choosen because it also allows Markdown syntax which makes the documentation
easier to read in the source files, as it doesn't require as much DDOC macros
as the dmd.

The ``graph-deps`` target is used to generate a dependencies graph. To generate
this graph the ``dot`` tool from the `graphviz <http://www.graphviz.org/>`_
visualization software is used (the location of the tool can be specified via
the ``DOT`` variable). By default only cyclic dependencies are generated in the
graph, but other kind of dependencies graphs can be generated (please take
a look at the ``./graph-deps --help`` ouput for details, you can override the
options to pass to ``graph-deps`` using the ``GRAPH_DEPS_FLAGS`` variables).

Predefined variables
--------------------
There are a lot of predefined variables provided by Makd, we've already seen
quite a few important ones (``F``, ``COLOR``, ``V`` for example).

Some of these variables are meant to be overridden and some are mean to be just
used (read-only), otherwise the library could break. Here we list a lot of them,
but always check the source ``Makd.mak`` if you want to know them all!

The standard Make variable ``LDFLAGS`` have a special treatment when used with
``dmd``/``rdmd``: the ``-L`` is automatically prepended, so if you need to
specify libraries to link to, just use ``-lname``, not ``-L-lname`` (same with
any other linker flag).

D2 support
~~~~~~~~~~
There is experimental support to build projects using D2. You just have to use
the special variable ``DVER``. For example::

        make DVER=2 test

Inside your ``Build.mak`` you can also use this to build your project
differently in D1 and D2, for example:

.. code:: make

        ifeq ($(DVER),2)
        rule: d2_file.d
        endif

To make project always use D2 compiler, simply define this variable in
``Config.mak``:

        DVER:=2

Variables you might want to override
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* The special target variables ``all``, ``test``, ``doc``.
* Color handling variables (``COLOR``\ * variables, please look at the Makd.mak
  source for details).
* ``F`` to change the default Flavor to build.
* ``V`` to change the default verboseness.
* ``BUILD_DIR_NAME`` and ``BUILD_DIR_EXCLUDE``, but usually you shouldn't.
* ``P`` is where built packages will be created. Defaults to ``$G/pkg``.
* Program location variables: ``DC`` is the D compiler to use, you can build
  your project with a different DMD by using ``make
  DC=/usr/bin/experimental-dmd`` for example. Same for ``RDMD`` and ``FPM``.
* Less likely you might want to override the ``DFLAGS``, ``RDMDFLAGS`` or
  ``FPMFLAGS``, but usually there are better methods to do that instead.
* ``TEST_FILTER_OUT`` to exclude some files from the unit tests or integration
  tests.
* ``TEST_RUNNER_MODULE`` and ``TEST_RUNNER_STRING`` are used to override the
  module or string to inject in the unittest file that runs all the unit tests.
  See Testing_ for details.
* ``SRC`` is where all the source files of your project is expected to be. By
  default is ``src`` but you can override it with ``.`` if you keep the source
  file in the top-level. The path must be relative to the project's top-level
  directory. It's using mainly to search for unittests.
* ``PKG`` is where package definitions are searched. When building packages,
  each ``*.pkg`` file in that directory will be built. By default ``$T/pkg``.
* ``PKG_DEFAULTS`` contains the default options passed to ``mkpkg``.
* ``PKG_PREBUILD`` hold commands to run previous to build packages.
* ``PROJECT_NAME`` contains the name of the project, used in documentation
  generatation. It defaults to the name of the top directory.
* ``VERSION_FILE`` is the location where to write a D module storing detailed
  information on the Git version and build information (like person who did the
  build, date, etc.). If this file shouldn't be generated at all, you can set
  this variable to be empty. By default it ``$(GS)/Version.d``.
* ``VERSION`` is the version to be used when creating documentation. It's
  obtained via the ``mkversion.sh`` by default.
* ``PKGVERSION`` is the version to be used when creating packages. It's
  obtained via the ``VERSION`` variable by default.
* ``PRE_BUILD_D`` and ``POST_BUILD_D`` hold scripts executed before and after
  running the command to build D targets (when using the ``build_d`` function).
  By default they are used to generate the ``Version.d`` file, but users can
  override it not to generate the file or do something else on top of that.

Some of this variables are typically overridden in the Config.mak_ file, others
in the Build.mak_ file, others in the Config.local.mak_ or directly in the
command line (like the style stuff).

Read-only variables
~~~~~~~~~~~~~~~~~~~
Probably the most important read-only variables are the ones related to
generated objects locations:

* ``T`` is the project's top-level directory (retrieved from git).
* ``R`` is the current directory relatively to ``$T``.
* ``C`` is the directory where the current Build.mak_ is (which might not be the
  same as the Make predefined variable ``CURDIR``). You should always use this
  variable to refer to local project files.
* ``G`` is the base generated files directory, taking into account the flavor
  (for example ``build/devel``).
* ``O`` is the objects/temporary directory (for example ``build/devel/tmp``).
* ``B`` is the generated binaries directory (for example ``build/devel/bin``).
* ``D`` is the generated documentation directory (for example ``build/doc``).
* ``GS`` is the temporary where generated sources are stored, so that
  ``-I$(GC)`` is added to the compiler (for example ``build/devel/include``).

All these variables except for ``R`` are **absolute** paths. This is to work
properly when run in different directories. You should take that into account.

Exported variables
------------------

Sometimes is good to be able to have some information about the environment
provided by Makd. For this purpose, the following variables are exported:

* ``MAKD_TOPDIR``: project's top directory as seen by Makd.

* ``MAKD_PATH``: directory where the ``Makd.mak`` file lives.

* ``MAKD_TMPDIR``: temporary directory inside the build directory that can be
  used for temporary stuff.

* ``MAKD_BINDIR``: directory where build binaries are stored.

* ``MAKD_FLAVOR``: flavor currently being built (usually either ``devel`` or
  ``production``).

* ``MAKD_DVER``: D version used (usually either ``1`` or ``2``).

* ``MAKD_VERBOSE``: indicates if Makd is running in verbose mode (``V=1``).
  This is only considered false when empty, any other value means true.

* ``MAKD_COLOR``: indicates if Makd is running in color mode (``COLOR=1``).
  This is only considered false when empty, any other value means true.

Predefined functions
--------------------
There are a few useful predefined functions you might want to know about. Only
the most important (the ones you are most likely to use) are mentioned here,
once again, please refer to the Makd.mak source if you want to see them all.

exec
~~~~
Probably the most important is ``exec``. This function takes care of the pretty
output and verboseness. Each time you write a custom rule (hopefully you won't
need to do this often), you should probably use it. Here is the function
*signature*:

.. code:: make

        $(call exec,command[,pretty_target[,pretty_command]])

``command`` is the command to execute, ``pretty_target`` is the name that will
be printed as the target that's being build (by default is ``$@``, i.e. the
actual target being built), and ``pretty_command`` is the string that will be
print as the command (by default the first word in ``command``).

Here is an example rule:

.. code:: make

        touch-file:
                $(call exec,touch -m $@)

This will print::

        touch touch-file

When built. And will print ``touch -m touch-file`` if ``V=1`` is used, as
expected.

build_d
~~~~~~~

This is a convenient shortcut to write rules to build D programs. It will run
the ``PRE_BUILD_D`` and ``POST_BUILD_D`` and ``rdmd`` for the actual build.

It takes 3 optional arguments:

1. arguments to be passed to ``BUILD.d`` (usually ``rdmd``)
2. arguments to be passed to the ``PRE_BUILD_D`` script
3. arguments to be passed to the ``POST_BUILD_D`` script

check_deb
~~~~~~~~~
This is a very simple function that just checks a certain Debian package is
installed. The *signature* is::

        $(call check_deb,package_name,required_version[,compare_op])

``package_name`` is, of course, the name of the package to check.
``required_version`` is the version number we require to build the project and
``compare_op`` is the comparison operator it should be used by the check (by
default is >=, but it can be any of <,<=,=,>=,>).

You can use this as the first command to run for a target action, for example:

.. code:: make

        myprogram: some-source.d
        	$(call check_deb,dstep,0.0.1)
        	rdmd --build --whatever.

If you need to share it for multiple targets you can just make a simple alias
with a lazy variable:

.. code:: make

        check_dstep = $(call check_deb,dstep,0.0.1)

        myprogram: some-source.d
        	$(check_dstep)
        	rdmd --build --whatever.

V
~~~
OK, this is not really a function, but you might use it in a way that can be
closer to a function than a variable. When we are in verbose mode, ``V`` is
empty and when we are not in verbose mode is set to ``@``. The effect is you
only get some Make output if we are not in verbose mode.

For example, this:

.. code:: make

        test:
                $Vecho test

If called via ``make test`` will produce::

        test

While if called via ``make V=1 test``, it will produce::

        echo test
        test

This is only useful for commands you normally don't want to print, but you want
to be friendly to the user and show the command if verbose mode is used.
Normally you should always use ``$V`` instead of ``@``.

Yes, is a bit confusing that ``$V`` internally becomes empty when you use
``V=1``, but when you use it is very natural :)


Flavors
-------
Flavors are just different ways to compile one project using different flags. By
default the ``devel`` and ``production`` flavors are defined. The `The build
directory`_ stores one subdirectory for each flavor so you can compile one after
the other without mixing objects compiled for one with the other and your cache
doesn't get destroyed by a ``make clean``.

To change variables based on the flavor (or define new flavors), usually the
`Config.mak`_ is the place, and you can use normal Make constructs, for
example:

.. code:: make

        ifeq ($F,devel)
        override DFLAGS += -debug=ProjectDebug
        endif

        ifeq ($F,production)
        override DFLAGS += -version=SuperOptimized
        endif

Usually the ``override`` option is needed, if you want to still add these
special flags even if the user passes a ``DFLAGS=-flag`` to Make.

To compile the project using a particular flavor, just pass the ``F`` variable
to make, for example::

        make F=production

If you need to define more flavors, you can do so by defining the
``$(VALID_FLAVORS)`` variable in your ``Config.mak``, for example:

.. code:: make

        VALID_FLAVORS := devel production profiling


Target specific flags
---------------------
There is a not-so-known Make feature that makes it very easy to override
variables for a particular target, and usually that's the best way to pass
specific variables to a particular target.

For example, you need to link one binary to a particular library but not the
others, then just do:

.. code:: make

        $B/prog-with-lib: override LDFLAGS += -lthelib
        $B/prog-with-lib: $C/src/progwithlibs.d

        $B/prog: $C/src/prog.d

Then ``LDFLAGS`` will only include ``-lthelib`` when the target
``$B/prog-with-lib`` is made, but not others. One catch about this is this
variable override is propagated, so if your target needs to build a prerequisite
first, the building of the prerequisite will also see the modified variable. If
you want to avoid this, Makd also expands the special variable
``$($@.EXTRA_FLAGS)``. That is ``$(<name of the target>.EXTRA_FLAGS)`` (yes,
Make support recursive expansion of variables :D), for example:

.. code:: make

        $B/prog-with-lib.EXTRA_FLAGS := -lthelib
        $B/prog: $C/src/prog.d

Will have a similar effect, but the variable expansion will only work for this
particular target. This is a corner case and hopefully you won't need to use it.


Packaging
---------

Makd supports a simple facility to make packages based on fpm_.  A simple
wrapper program ``mkpkg`` is provided to ease the creation of scripts that use
fpm_ to create packages.  The predefined ``pkg`` target will scan for ``*.pkg``
files in the ``$(PKG)`` directory (by default ``$T/pkg``) and then invoke
``mkpkg`` with them.

These files are expected to be Python scripts. They have some pre-defined
built-in variables, some of which the user is expected to fill and some of
which are tools for the user to define packages.

These are the built-in variables that the user should fill:

``OPTS``
        a ``dict()`` (associative array) where each item will be mapped to
        a fpm_ command-line option. If the key is only one character (for
        example ``c``), it will be passed as ``-<key><value>`` and if it's
        more, it will be passed as ``--<key>=<value>`` (``_`` characters in the
        key will be replaced by ``-`` for convenience). The ``<value>`` can be a
        string or an array of strings. In the latter case, the key is used as fpm_
        flag for each item in ``<value>``. No validation is performed over the
        keys or values, they are just passed blindly to fpm_.

``ARGS``
        a ``list()`` (array) to pass to fpm_ as positional arguments (usually the
        list of files to include in the package).

These variables should never be rebound (never assign to them like ``OPTS
= dict(...)``), you always need to update them instead (normally using
``OPTS.update(...)`` and ``ARGS.extend([...])``).

An extra built-in variable will be available, ``VAR``, containing variables
passed to the ``mkpkg`` util. By default Makd passes the following variables:

``shortname``
        name of the package as calculated from the ``.pkg`` file.

``suffix``
        a suffix to add to the package name to support installing multiple
        versions simultaneously (see `Package suffix`_ for details).

``fullname``
        ``shortname`` with the ``suffix`` appended to it for convenience.

``version``
        package version number as defined by ``PKGVERSION``.

``builddir``
        base build directory (``$G``).

``bindir``
        directory where the built binaries are stored.

``lsb_release``
        Debian ``lsb_release -uc`` content (distribution name).

``mkpkg`` also defines the following built-in functions in the special built-in
variable ``FUN``:

``autodeps(bin[, ...][, path=''])``
        returns a sorted ``list()`` of packages ``bin`` depends on based on the
        outcome of running the ``ldd`` utility and searching to which packages
        the libraries is linked belong to using ``dpkg``. You can specify
        multiple binaries to get a list of dependencies for all of them. This
        function is tightly coupled to Debian packages for now. If a ``path``
        is given, then all the ``bin`` passed will be prepended with this
        ``path``. ``bin``\ s can be passed as multiple arguments or as one
        list.
``mapfiles(src, dst, file[, ...][, append_suffix=True])``
        A very simple function that just returns a list with
        ``{src}/{file}={dst}/{file}{VAR.suffix}`` for each ``file`` passed.
        ``file``\ s can be passed as multiple arguments or as one list. A named
        argument ``append_suffix`` can be passed at the end to control whether
        ``VAR.suffix`` is appended to each destination file. ``append_suffix``
        defaults to ``True`` if not given.
``desc(OPTS, [type[, prolog[, epilog]]])``
        A simple function to customize ``OPTS['description']``. It can add an
        optional ``type`` of package (will append `` (<type>)`` to the first
        line (short description), ``prolog`` (inserted before the long
        description) and an ``epilog`` (appended at the end of the long
        description. To use only one of them, you can use Python's keyword
        arguments syntax. Examples:

        .. code:: py

                FUN.desc(OPTS, 'common files', 'These are just config files',
                    'Part of whatever') # All specified
                FUN.desc(OPTS, epilog='Just an epilog')
                FUN.desc(OPTS, 'a type', epilog='And an epilog')
                FUN.desc(OPTS, prolog='A prolog',
                    epilog='And an epilog, but no type')

        Note that ``OPTS['desciption']`` must be defined and hold a non-empty
        string.

Generated packages will be stored in the ``$P`` directory (by default
``$G/pkg``. Since each package usually have a different name, as the version
usually changes with each change, all old packages are removed before making
new ones with the ``pkg`` target and also generates a Debian changelog from
the git history (you can override this by re-defining the ``PKG_PREBUILD``
variable).

The options to pass by default to ``mkpkg`` are defined by the variable
``PKG_DEFAULTS``, you can override it if the defaults are not suitable for you
projects. By default it builds Debian packages from files, a Debian changelog
is provided, and a version and iteration (using the Debian version).

Bear in mind that you should use lazy variables when overriding
``PKG_DEFAULTS`` and ``PKG_PREBUILD`` if you want to use variables defined in
the ``pkg`` target.

Please run ``mkpkg --help`` if you want to know more about that utility.

For more details on how to create packages using fpm_ (thus, to know which
options you can define in ``OPTS`` and what to pass as ``ARGS``) please refer
to the `fpm wiki <https://github.com/jordansissel/fpm/wiki>`_.

Specifying dependencies
~~~~~~~~~~~~~~~~~~~~~~~

Since the package version is included in the file, is very complicated to have
the target really based on the package file name, because of this Makd uses
a *stamp* approach. The building of the package will be tracked via the special
file ``$O/pkg-%.stamp`` file.

So when specifying dependencies (this target should depends on all files used
to build the package), you should use this special file instead.

Package suffix
~~~~~~~~~~~~~~

To make it easy to build test packages that can be installed in parallel with
the current packages, the variable ``PKG_SUFFIX`` can be passed to make
when building the package (for example ``make pkg PKG_SUFFIX=-test``). This
will produce a package with name ``name-test``. Bear in mind the files will
conflict if the regular ``name`` package and a suffixed package have the
same files. To avoid this problem, the ``{SUFFIX}`` variable will be replaced
by the contents of the ``PKG_SUFFIX`` variable. So the most common pattern is
to add the suffix to any non-configuration file in the package.

Example
~~~~~~~

For convenience, here is a simple example:

``$P/defaults.py``

.. code:: py

        # This is a normal python module defining some defaults
        OPTS.update(
          description = '''\
        Test package packing some daemon
        This is an extended package description with multiple lines

        This is a longer paragraph in the package description that
        can span multiple lines.''',
          url = 'https://github.com/sociomantic/makd',
          maintainer = 'Sociomantic Labs GmbH <info@sociomantic.com>',
          vendor = 'Sociomantic Labs GmbH',
        )

``$P/daemon.pkg``:

.. code:: py

        import defaults

        bins = 'daemon admtool util1'

        OPTS.update(

          name = VAR.fullname,

          category = 'net',

          depends = FUN.autodeps(bins, path=VAR.bindir) + [
              'bash',
              'libnew' if VAR.lsb_release == 'trusty' else 'libold',
            ],

        )

        ARGS.extend(FUN.mapfiles(VAR.bindir, '/usr/sbin', bins) + [
          'README.rst=/usr/share/doc/' + VAR.fullname '/',
        ])

``$P/client.pkg``:

.. code:: py

        import defaults

        bins = 'client clitool'

        OPTS.update(

          name = VAR.fullname,

          description = FUN.desc(OPTS, 'tools', epilog='These are just ' +
            'utilities for the daemon package'),

          category = 'net',

          depends = FUN.autodeps(bins, path=VAR.bindir),
        )

        ARGS.extend(FUN.mapfiles(VAR.bindir, '/usr/bin', bins))
        ARGS.extend(FUN.mapfiles('.', '/etc', 'util.conf', append_suffix=False))

Suppose that the targets ``daemon`` and ``client`` build the binaries
``daemon``, ``admtool``, ``util1`` and ``client``, ``clitool`` respectively,
then you probably want to make sure you build those before making the package,
so in the ``Build.mak`` file you should put something like:

.. code:: make

        $O/pkg-daemon.stamp: daemon

        $O/pkg-client.stamp: util

With this configuration, a call to ``make pkg`` will leave the built packages
in the ``$P`` directory.


Testing
-------
Makd supports testing generally by the special variables ``$(test)`` and
``$(fasttest)``. You can add any custom target to this variables to be executed
when you use the corresponding ``test`` and ``fasttest`` targets.

Automatic *unittest* and integration tests support is added on top of that.

All the tests are built using these extra options::

        -unittest -debug=UnitTest -version=UnitTest

If you have a test script, you can easily add the target to run that script to
``$(test)`` too (or ``$(fasttest))`` and ``$(test)`` if it's really fast).
For example:

.. code:: make

        .PHONY: supertest
        supertest:
                ./super-test.sh
        test += supertest

Then when you run ``make test`` all the *unittests*, integration tests and your
test will run.

Unit tests
~~~~~~~~~~

Only *unittest* that live in the directory specified by the ``$(SRC)`` variable
are built and run automatically, the ``unittest`` target will scan for all the
files with the ``.d`` suffix there.

There are two different categories of *unittest* though: fast and slow. Tests
are assumed to be fast unless they are separated to a different file, with the
suffix ``_slowtest.d``. Usually all the slow tests for module ``m`` should be
moved to ``m_slowtest.d``, but this is just a convention.

The general ``unittest`` target is just an alias for the more specific target
``allunittest`` and it will run all the unit tests (fast and slow). This target
is automatically added to the ``$(test)`` special variable, so they will be run
when using the ``test`` target too. On the other hand, the ``fastunittest``
target will only run the fast unit tests, leaving the slow out, and is added to
the ``fasttest`` target.

Unit tests are compiled in a separate binary that imports all modules in the
project. By default, this binary will just have an empty ``main()`` function
and will let the D runtime to execute the tests by passing ``-unittest``.

If `Ocean <https://github.com/sociomantic-tsunami/ocean>`_ is present as
a submodule, then ``ocean.core.UnitTestRunner`` will be imported instead.

If you want to import a custom module to run the unit tests, you can do so by
specifying the module via the ``TEST_RUNNER_MODULE`` variable. If you do this,
no ``main()`` function will be generated, so the module you are importing
should define it.

If you want to define a custom ``main()`` function, or put any other content
into the file generated to run the unit tests (importing all modules), you can
define ``TEST_RUNNER_MODULE`` as an empty variable and then put the contents
you want to add to the file in the ``TEST_RUNNER_STRING`` variable.

Integration tests
~~~~~~~~~~~~~~~~~

Integration tests are expected to live in the ``test/`` directory, and it is
expected that each subdirectory there is a separate test program, with
a ``main.d`` file as the entry point. So the typical layout for the ``test/``
directory is::

        test/
             test_1/
                    main.d
                    onemodule.d
             test_2/
                    main.d
                    othermodule.d

The ``integrationtest`` target scan for those individual programs (specifically
for files with the pattern: ``test/*/main.d``) and builds them and runs them.

It is also expected that the integration tests are slow, so by default they are
only added to the ``test`` target, but you can manually add them (all or just
a few) to the ``fasttest`` target too (``fasttest += integrationtest`` should be
enough to add them all).

Skipping tests
~~~~~~~~~~~~~~

The ``$(TEST_FILTER_OUT)`` variable is used to exclude some tests. The contents
of this variable will always be applied to the list of files to use in the tests
through the Make ``$(filter-out)`` function.  This means you can use a single
``%`` as a wildcard. You should always use absolute paths (which can be easily
done by applying the prefix ``$C/`` to files). Adding files to the
``$(TEST_FILTER_OUT)`` variable should be done in the Build.mak_ file. Always
use ``+=``, there might be other predefined modules to skip.

For `Unit tests`_, you just have to add the individual files you want to exclude
from the tests. You can use a single ``%`` as a wildcard to exclude a whole
package for example:

.. code:: make

        TEST_FILTER_OUT += \
                $C/src/brokenmodule.d \
                $C/src/brokenpackage/%

For `Integration tests`_, you can only skip a full test program, to do that just
exclude the ``main.d`` for that program. For example:

.. code:: make

        TEST_FILTER_OUT += $C/test/brokenprog/main.d

Adding specific flags
~~~~~~~~~~~~~~~~~~~~~

Some tests might need special flags for the unittest to compile, like when you
need to link to external libraries.

For `Unit tests`_ you can add unittest specific flags by using the following
syntax:

.. code:: make

        $O/%unittests: override LDFLAGS += -lglib-2.0

This will link all the unittests to the glib-2.0 library, both ``fastunittest``
and ``allunittest``. To apply flags to an individual test use a more specific
target, for example:

.. code:: make

        $O/allunittests: override LDFLAGS += -lextra

This will link the *extra* library only to the full unit tests, but not to the
fast ones.

If you want to run the tests using some special options of the unit test runner
(see ``build/last/*unittests -h`` for a list of supported options), you can use
the special variable ``UTFLAGS``, for example::

        make allunittest UTFLAGS="-v -s"

This will print all the executed tests and a summary at the end with the number
of passed tests, failed tests, etc.

Some special options are passed automatically, for example if ``make -k`` is
used, the ``-k`` option will be passed to the unit test runner too, and if
``make V=1`` is used, the options ``-v -s`` will be passed to the unit test
runner.

For `Integration tests`_ the way to pass special flags is similar, but not the
same. Use the following syntax:

.. code:: make

        $O/test-feature: override LDFLAGS += -lglib-2.0

The targets for individual integration test programs are defined following this
pattern: ``$O/test-%``. The previous example will link the program at
``test/feature/main.d`` against glib-2.0 as expected.

To pass flags to the test program execution, you can use the special variable
``$(ITFLAGS)``.  Unfortunately, unless you are running a specific integration
test, the only way to do this for individual suites is to write it in the makefile,
otherwise the same flags will be used to run **all** the integration tests.
To run the *feature* integration test with the flag ``--verbose``, for example,
you can do this (pay attention to the ``.stamp`` suffix, it is necessary):

.. code:: make

        $O/test-feature.stamp: override ITFLAGS += --verbose

If you want to run **all** the integration test programs with the same flags,
you can still use::

        make integrationtest ITFLAGS=--verbose

Re-running unittests manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once you built and ran the unittests once, if you want, for some reason, repeat
the tests, you can just run the generated ``*unittests`` and ``test-*``
programs. All the programs are built in the ``build/last/tmp`` directory (``$O``
more specifically).

A reason to run it again could be to use different command-line options (the
unit tests runner accepts a few, try ``build/last/tmp/allunittests -h`` for
help). For example, if you want to re-run the tests, but without stopping on the
first failure, use::

        build/last/tmp/allunittests -k

This option is used automatically if you run ``make -k``.

Remember to re-run ``make`` if you change any sources, the test programs need to
be re-compiled in that case!


.. _Makeit: https://git.llucax.com/w/software/makeit.git
.. _fpm: https://github.com/jordansissel/fpm

