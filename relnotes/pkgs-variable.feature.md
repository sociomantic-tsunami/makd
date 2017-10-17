* `PKG_FILES`

  This variable holds all package definitions to be build. The purpose is to allow one to exclude
  some packages from being built if need be, for example for `F=production` or `DVER=2`
  only packages.
  It can be filtered-out, e.g:
  ```
  ifeq ($(DVER),1)
  PKG_FILES := $(filter-out $(PKG)/D2OnlyApp.pkg,$(PKG_FILES))
  endif
  ```
