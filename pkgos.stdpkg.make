
include /usr/share/openstack-pkg-tools/pkgos.make

PKGOS_NO_PYTHON    =$(shell echo $(DEBPKGNAME) |  sed s/python-//)
PKGOS_PYTHON_PKG   =$(shell grep -e '^Package: python-'$(PKGOS_NO_PYTHON)'$$'     debian/control | awk '{print $$2}')
PKGOS_PYTHON3_PKG  =$(shell grep -e '^Package: python3-'$(PKGOS_NO_PYTHON)'$$'    debian/control | awk '{print $$2}')
PKGOS_PYTHONDOC_PKG=$(shell grep -e '^Package: python-'$(PKGOS_NO_PYTHON)'-doc$$' debian/control | awk '{print $$2}')

ifeq (python-$(PKGOS_NO_PYTHON), $(PKGOS_PYTHON_PKG))
PKGOS_DH2_LIST=python2,
else
PKGOS_NO_PY2="--no-py2"
endif
ifeq (python3-$(PKGOS_NO_PYTHON), $(PKGOS_PYTHON3_PKG))
PKGOS_DH3_LIST=python3,
else
PKGOS_NO_PY3="--no-py3"
endif
ifeq (python-$(PKGOS_NO_PYTHON)-doc, $(PKGOS_PYTHONDOC_PKG))
PKGOS_DHDOC_LIST=sphinxdoc,
endif
PKGOS_DH_LIST=$(PKGOS_DH2_LIST)$(PKGOS_DH3_LIST)$(PKGOS_DHDOC_LIST)

%:
	dh $@ --buildsystem=python_distutils --with $(PKGOS_DH_LIST)

override_dh_auto_install:
	pkgos-dh_auto_install $(PKGOS_NO_PY2) $(PKGOS_NO_PY3)

ifeq (python3-$(PKGOS_NO_PYTHON), $(PKGOS_PYTHON3_PKG))
override_dh_python3:
	dh_python3 --shebang=/usr/bin/python3
endif

override_dh_auto_clean:
	dh_auto_clean
	rm -rf .testrepository build doc/man

override_dh_auto_test:
ifeq (,$(findstring nocheck, $(DEB_BUILD_OPTIONS)))
	pkgos-dh_auto_test $(PKGOS_NO_PY2) $(PKGOS_NO_PY3) $(PKGOS_TEST_REGEX)
endif

override_dh_sphinxdoc:
ifeq (,$(findstring nodocs, $(DEB_BUILD_OPTIONS)))
	PYTHONPATH=. python3 -m sphinx -b html doc/source $(CURDIR)/debian/$(PKGOS_PYTHONDOC_PKG)/usr/share/doc/$(PKGOS_PYTHONDOC_PKG)/html
	dh_sphinxdoc
endif

# Commands not to run
override_dh_installcatalogs:
override_dh_installemacsen override_dh_installifupdown:
override_dh_installinfo override_dh_installmenu override_dh_installmime:
override_dh_installmodules override_dh_installlogcheck:
override_dh_installpam override_dh_installppp override_dh_installudev:
override_dh_installwm:
override_dh_installxfonts override_dh_gconf override_dh_icons:
override_dh_perl override_dh_usrlocal:
