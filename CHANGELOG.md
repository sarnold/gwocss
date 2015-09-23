# Change Log

## [gwocss 2.2.4_pre20150922](https://github.com/sarnold/gwocss/releases/tag/2.2.4_pre20150922) (2015-09-22)
[Full Changelog](https://github.com/sarnold/gwocss/compare/2.2.3-r1...2.2.4_pre20150922)

Another autotools update to cleanup the build and optimize for proper
gfortran flags (-std and IEEE mth) and shared executable.  Builds and
runs cleanly with latest gcc/gfortran 4.9.3 but the source code still
needs plenty of cleanup to bring it out of the F77 dark ages, and the
output grid results have an occasional minor rounding difference on x86
(currently under investigation).

# Historical changelog information

## [2.2.3-r1](https://github.com/sarnold/gwocss/releases/tag/2.2.3-r1) (2014-07-15)

[Full Changelog](https://github.com/sarnold/gwocss/compare/2.2.3...2.2.3-r1)

Updated build configuration for newer autotools and gcc; mostly changes to 
compiler flags and autotools *.ac files to clean up and simplify the build 
process.

## [2.2.3](https://github.com/sarnold/gwocss/releases/tag/2.2.3) (2009-04-26)

Initial release of WOCSS under GPL with basic autoconf/automake setup.
Although the included license files are GPL v2, this should now be
considered to be covered under the GPL Version 3.

Data ingest, model configuration and localization, and choice of
output grids are left up to you (the user).  The example data sets
are provided so you can check the results of the build on your own
machines/architectures.  More reference documents on WOCSS are
listed in the [overview document](https://github.com/sarnold/gwocss/raw/master/docs/GWOCSS_overview.pdf) 
and on the original (primary) developer's [CV page](http://sfports.wr.usgs.gov/wind/ludwig/CV/ludwig_CV.html)
and via Google, etc.  An additional package of references will be
available in the near future.  See the README file for more info.
