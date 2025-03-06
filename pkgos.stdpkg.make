
include /usr/share/openstack-pkg-tools/pkgos.make

PKGOS_NO_PYTHON    =$(shell echo $(DEBPKGNAME) |  sed s/python-//)
PKGOS_PYTHONDOC_PKG=$(shell grep -e '^Package: python-'$(PKGOS_NO_PYTHON)'-doc$$' debian/control | awk '{print $$2}')

ifeq (python-$(PKGOS_NO_PYTHON)-doc, $(PKGOS_PYTHONDOC_PKG))
PKGOS_DHDOC_LIST=sphinxdoc,
endif

%:
	dh $@ --buildsystem=python_distutils --with $(PKGOS_DHDOC_LIST)python3

override_dh_auto_install:
	pkgos-dh_auto_install

override_dh_python3:
	dh_python3 --shebang=/usr/bin/python3

override_dh_auto_clean:
	dh_auto_clean
	rm -rf .testrepository build doc/man

override_dh_auto_test:
ifeq (,$(findstring nocheck, $(DEB_BUILD_OPTIONS)))
	pkgos-dh_auto_test $(PKGOS_TEST_REGEX)
endif

ifeq (python-$(PKGOS_NO_PYTHON)-doc, $(PKGOS_PYTHONDOC_PKG))
override_dh_sphinxdoc:
ifeq (,$(findstring nodocs, $(DEB_BUILD_OPTIONS)))
	PYTHONPATH=. python3 -m sphinx -b html doc/source $(CURDIR)/debian/$(PKGOS_PYTHONDOC_PKG)/usr/share/doc/$(PKGOS_PYTHONDOC_PKG)/html
	dh_sphinxdoc
endif
endif
