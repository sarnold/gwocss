AUTOMAKE_OPTIONS = foreign

SUBDIRS = src

if DEBUG
DBG = -g
endif

GW_SRCS = src/*.f $(GW_INCS)
GW_INCS = inc/*.CMM

DOX     = doxygen
DOCS    = docs

INC     = -I$(top_srcdir)/inc

.NOTPARALLEL:	default

dist_bin_SCRIPTS = scripts/gwocss

nobase_pkgdata_DATA = slcin/10162215WXIN \
                      slcin/RUNSTF1.DAT \
                      slcin/SLC1KM.DAT \
                      slcin/SLCFILES \
                      slcout/LOCLTOPO \
                      slcout/UF1KM-ALLZ.162215 \
                      slcout/VF1KM-ALLZ.162215

$(DOCS)/.keep_dir:
	mkdir -p $(dir $@)
	touch $@

docs:	Doxyfile.html_cfg $(GW_SRCS) $(DOCS)/.keep_dir
	rm -rf $(DOCS)/html
	$(DOX) Doxyfile.html_cfg
	@echo "API docs now in $(DOCS)/html"

docsclean: clean
	rm -rf $(DOCS)/html $(DOCS)/.keep_dir *.xml

am-clean:
	rm -rf gwocss*tar.gz \
	autom4te.cache aclocal.m4 compile config.guess config.log \
	config.status config.sub configure install-sh missing \
	Makefile Makefile.in src/Makefile src/Makefile.in
