## The package iteration can now be specified via `PKGITERATION`

Package versions consist of two components: the _upstream version_, and
the _package iteration_ (corresponding to the `debian_revision` where
deb packages are concerned).

Previously the package iteration was hardcoded to match the distro code
(e.g. `xenial`), disallowing typical patterns referencing the packager
and changes to the packaging rather than the upstream project.

The new `PKGITERATION` variable allows the package iteration to be set
to whatever is wanted, whether via `Config.mak` or the command line.
It still defaults to the distro code, meaning nothing will change for
existing package definitions, but can now be customized where this is
appropriate (e.g. for packages of 3rd-party projects).

Note that if you want to include the distro code in a customized package
iteration, this will have to be included manually.  For example,
`PKGITERATION=3~"$(lsb_release -cs)"` will produce iterations such as
`3~trusty`, `3~xenial`, etc. depending on the distro used to build the
package.

For some examples of how to set the package iteration, see the
 [Debian versioning policy](https://www.debian.org/doc/debian-policy/#version)
and [the Ubuntu `debian_revision` schema](https://askubuntu.com/questions/620533/how-does-ubuntu-name-packages).
