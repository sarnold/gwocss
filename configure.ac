dnl Process this file with autoconf to produce a configure script.
AC_INIT([gwocss],[2.2.3],[stephen.arnold42@gmail.com])

AM_INIT_AUTOMAKE([1.9])

AC_PREREQ([2.52])

AM_MAINTAINER_MODE

AC_PREFIX_PROGRAM(gfortran)

dnl Check Fortran stuff.
AC_PROG_F77_C_O
AC_PROG_F77(g77 f77 fort77 fl32 xlf cf77 f90 xlf90)
AC_F77_LIBRARY_LDFLAGS

dnl Checks for programs.
AC_PROG_MAKE_SET

dnl AC_PROG_RANLIB
dnl AC_PROG_LIBTOOL
dnl AC_PROG_INSTALL

dnl override presets with user input if present
dnl
if test -n "$user_cflags"
then
  CFLAGS="$user_cflags"
fi
dnl

ARCHIVE="ar"
ANSICFLAGS=$CFLAGS

dnl Checks for libraries.

dnl Checks for header files.

dnl Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T

dnl Checks for library functions.

AC_CONFIG_FILES(Makefile src/Makefile)

AC_OUTPUT()
