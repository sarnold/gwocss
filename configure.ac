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

dnl disable shared linking if possible
dnl LT_INIT([disable-shared])

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

dnl Checks for header files.
AC_STDC_HEADERS
AC_HAVE_HEADERS(math.h)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T

dnl Checks for libraries.
SAVED_CFLAGS=$CFLAGS
CFLAGS="$CFLAGS -static"
SAVED_LDFLAGS=$LDFLAGS
LDFLAGS="$LDFLAGS -lm"
AC_MSG_CHECKING([whether -lm is needed])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#ifndef __NO_MATH_INLINES
# define __NO_MATH_INLINES 1 /* for glibc */
#endif
#include <math.h>

double a,b;
]],[[
a=sqrt(b);
]])],[
    AC_MSG_RESULT([no])
  ],[
    AC_MSG_RESULT([yes])
    AC_CHECK_LIB([m],[sqrt])
  ])
CFLAGS=$SAVED_CFLAGS
LDFLAGS=$SAVED_LDFLAGS

dnl Checks for library functions.

AC_CONFIG_FILES(Makefile src/Makefile)

AC_OUTPUT()
