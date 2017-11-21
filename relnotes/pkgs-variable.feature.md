## Packages to be build can be specified via `PKG_FILES`

`mkpkg`

A new `PKG_FILES` variable holds all package definitions to be build.

The purpose is to allow one to exclude some packages from being built if need be, for example for `F=production` or `DVER=2` only packages.

The `PKG_FILES` variable comes populated with `pkg/*.pkg` by default, it can be completely overridden or it can be filtered-out as follows:
```make
ifeq ($(DVER),1)
PKG_FILES := $(filter-out $(PKG)/D2OnlyApp.pkg,$(PKG_FILES))
endif
```
