===========================================================
(G)WOCSS - A diagnostic windfield model for complex terrain
===========================================================

  Original code: Copyright (C) 2002 Francis Ludwig
  GNU/Linux port: Copyright (C) 2003-2015 Stephen L Arnold

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

This is the GPL release of Winds On Critical Streamline Surfaces (GWOCSS), 
a diagnostic windfield model for complex terrain.  It can be used for both 
objective analysis (with physics and terrain) of observational data and as 
a way to downscale prognostic model output (ie, to obtain finer resolution 
winds from a coarser grid model output).

Building GWOCSS
===============

Consult the INSTALL file for details on how to build and install binaries of 
GWOCSS.

You can override the usual user flags for debugging and/or optimization;
the configure flag --enable-debug sets DBG = -g so you will need to add your
own debug flags or override the user flags with configure to change debug or
optimization settings.

The basic requirement is a gfotran toolchain, ie, autotools and gcc built
with FORTRAN support but should work with any modern Fortran compiler.

The FFLAGS are specific to gfortran, but the basic autoconf macros allow for 
several other Fortran compilers.  You can override the FFLAGS on the command 
line or edit src/Makefile.in if you're not using GNU Fortran.  Use the model
data and configuration included with the source to verify correct operation.
The current code defaults to running in the parent directory of the input and
output directories.

.. note: Previous versions required (static) libm.a or the glibc-static package
         from your distro.  The current build produces a shared executable with
         a chunk of static lilbgfotran bundled in.

To build and test gwocss manually, clone the repo or download the tarball.
Unpack and cd into the top-level gwocss src directory and run::

 $ ./autogen.sh
 $ ./configure (autogen will run configure by default)
 $ make
 $ gwocss  (this will use the sample data)

Using GWOCSS
============

The Gentoo package will install some helper scripts and a config file to setup
the gwocss sample data and runtime directories based on the domain(s) in the
configuration file (the default is the "demo" domain which uses the sammple
data from Salt Lake).  Add yourself to the gwocss group and then add your
own domains in the same way, eg, make a direectory for your domain with 
sclin and slcout subdirs.  Assuming you already have config, topography,
and the minimum input data::

 $ mkdir -p /var/lib/gwocss/test1/{slcin,slcout}
 $ cp ${HOME}/test1/input_files/* /var/lib/gwocss/test1/slcin/
 $ gwocss test1

Alternatively, you can run the gwocss binary from the build directory in your
$HOME dir somewhere once you have your own domain setup.  For production use
you would need something to retrieve/prepare the input files and something
else to trigger the model when new input data is available (some of these
tools are on the TODO list, feel free to contribute ;)

The basic setup uses the slcin and slcout directories for the default input
and output files; legacy Fortran directory names have been converted to
lowercase, but not the filenames:

 slcin/RUNSTF1.DAT  - runtime configuration and localization parameters,
                      with sample data defaults (location near Salt Lake
                      City, UT).

 slcin/SLC1KM.DAT   - Topographic grid (1 km spacing) for above location.

 slcin/SLCFILES     - names of input files (meteorological data, only one file
                      for the sample problem).  See the next file...

 slcin/10162215WXIN - Input meteorological data, can contain both surface
                      stations and upper air profiles.

 inc/NGRIDS.PAR     - Grid parameters and filename & path sizes.

 inc/*              - Fortran common include files.

More information
================

The file docs/GWOCSS_overview.pdf contains details on the sample problem, as
well as the format and naming convention for the input meteorological data
file(s).  Note the changes mentioned at the top of the document; the files
provided for the sample problem are the current (correct) format (you can
also read the source code).  Also, please ignore the Matlab references...

The following AMS slides/abstract give a brief history/overview of GWOCSS:

http://tinyurl.com/GWOCSS-intro

See the following references for model details::

 Ludwig, F. L., J. M. Livingston, and R. M. Endlich, 1991: "Use of Mass
    Conservation and Dividing Streamline Concepts for Efficient Objective
    Analysis of Winds in Complex Terrain," J. Appl. Meteorol., 30, 1490-1499

 Ludwig, F. L. and D. Sinton, 2000; Evaluating an Objective Wind Analysis
    Technique with a Long Record of Routinely Collected Data, J. Appl.
    Meteorol., 39, 335-348.

 Ludwig, F. L. and R. L. Street, 1995; Modification of Multiresolution Feature
    Analysis for Application to Three-Dimensional Atmospheric Wind Fields, J.
    Atmos. Sci., 52, 139-157.

 Ludwig, F. L., R. L. Street, J. M. Schneider and K. R. Costigan, 1996:
    Analysis of Small-Scale Patterns of Atmospheric Motion in a Sheared,
    Convective Boundary Layer, J. Geophys. Res. (Atmospheres), 101D,
    9391-9411.

Please contact Steve Arnold <stephen.arnold42 _at_ gmail.com> for any questions
concerning this release.


