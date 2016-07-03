tmp ?= $(abspath tmp)

installer_version := 1

.SECONDEXPANSION :

.PHONY : all
all : lzfse-$(installer_version).pkg

.PHONY : clean
clean :
	-rm -f lzfse-$(installer_version).pkg
	-rm -rf $(tmp)


##### lzfse ##########
lzfse_sources := $(shell find lzfse -type f \! -name .DS_Store)

$(tmp)/install/usr/local/bin/lzfse \
$(tmp)/install/usr/local/include/lzfse.h \
$(tmp)/install/usr/local/lib/liblzfse.a : $(tmp)/installed.stamp.txt
	@:

$(tmp)/installed.stamp.txt : \
			$(tmp)/build/bin/lzfse \
			$(tmp)/build/bin/liblzfse.a \
			lzfse/src/lzfse.h \
			| $(tmp)/install
	cd lzfse && $(MAKE) install BUILD_DIR=$(tmp)/build INSTALL_PREFIX=$(tmp)/install/usr/local
	date > $@

$(tmp)/build/bin/lzfse \
$(tmp)/build/bin/liblzfse.a : $(tmp)/built.stamp.txt
	@:

$(tmp)/built.stamp.txt : $(lzfse_sources) | $(tmp)/build
	cd lzfse && $(MAKE) BUILD_DIR=$(tmp)/build
	date > $@

$(tmp)/build \
$(tmp)/install :
	mkdir -p $@


##### pkg ##########

$(tmp)/lzfse-$(installer_version).pkg : \
		Makefile \
		$(tmp)/install/usr/local/bin/lzfse \
		$(tmp)/install/usr/local/include/lzfse.h \
		$(tmp)/install/usr/local/lib/liblzfse.a \
		$(tmp)/install/etc/paths.d/lzfse.path
	pkgbuild \
		--root $(tmp)/install \
		--identifier com.ablepear.lzfse \
		--ownership recommended \
		--version $(installer_version) \
		$@

$(tmp)/install/etc/paths.d/lzfse.path : lzfse.path | $(tmp)/install/etc/paths.d
	cp $< $@

$(tmp)/install/etc/paths.d :
	mkdir -p $@


##### product ##########

lzfse-$(installer_version).pkg : \
		Makefile \
		$(tmp)/lzfse-$(installer_version).pkg \
		$(tmp)/distribution.xml \
		$(tmp)/resources/background.png \
		$(tmp)/resources/license.html \
		$(tmp)/resources/welcome.html
	productbuild \
		--distribution $(tmp)/distribution.xml \
		--resources $(tmp)/resources \
		--package-path $(tmp) \
		--version $(installer_version) \
		--sign 'Able Pear Software Incorporated' \
		$@

$(tmp)/distribution.xml \
$(tmp)/resources/welcome.html : $(tmp)/% : % Makefile | $$(dir $$@)
	sed -e s/{{installer_version}}/$(installer_version)/g $< > $@

$(tmp)/resources/background.png \
$(tmp)/resources/license.html : $(tmp)/% : % | $(tmp)/resources
	cp $< $@

$(tmp) \
$(tmp)/resources :
	mkdir -p $@

