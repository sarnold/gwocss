AM_CPPFLAGS    = -I$(top_srcdir)/inc -I$(includedir)

## -std=legacy gives IEEE float warnings
## -frecord-marker=8 is for compatibility

LEGACY         = -frecord-marker=8 -finit-local-zero -fno-automatic \
                 -fdollar-ok -fno-underscoring
WARN           = -Wall -Wtabs
TRAPS          = -fbacktrace -ffpe-trap=zero,overflow,underflow
IEEE           = -fno-unsafe-math-optimizations -frounding-math -fsignaling-nans

AM_FFLAGS      = -std=gnu $(DBG) -fPIC -DPIC \
                 -fall-intrinsics \
                 $(WARN) $(LEGACY) \
                 $(IEEE) $(TRAPS) \
                 $(AM_CPPFLAGS)

gwocss_FFLAGS  = $(AM_FFLAGS)

gwocss_LDFLAGS = -static-libgfortran $(DBG)

pkglibexec_PROGRAMS   = gwocss

gwocss_SOURCES = bal5.f \
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

