AUTOMAKE_OPTIONS = foreign

SUBDIRS = src

GW_SRCS = src/*.f $(GW_INCS)
GW_INCS = inc/*.CMM

DOX     = doxygen
DOCS    = docs

INC     = -I$(top_srcdir)/inc

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
