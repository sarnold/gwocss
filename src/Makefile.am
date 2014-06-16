


AM_FFLAGS     = -finit-local-zero -fno-automatic -fall-intrinsics -fdollar-ok -std=legacy $(AM_CPPFLAGS)

AM_CPPFLAGS   = -I$(top_srcdir)/inc -I$(includedir) -I$(top_srcdir)

LD            = $(FC)

AM_LDFLAGS    = -g -static

bin_PROGRAMS  = gwocss

gwocss_SOURCES = bal5.f    \
                betpar.f \
                dopsig.f \
                flowht.f \
                geosig.f \
                input.f \
                interp.f \
                invwt.f \
                levwnd.f \
                output.f \
                resig.f \
                richardson.f \
                strat.f \
                topo.f \
                utils.f \
                vertvel.f \
                winterp.f \
                windest.f \
                wocss.f

gwocss_LDADD  = -lm


