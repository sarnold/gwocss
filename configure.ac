dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.61])
AC_INIT([gwocss],[2.2.4],[stephen.arnold42@gmail.com])
AM_INIT_AUTOMAKE

AM_MAINTAINER_MODE

dnl Check Fortran stuff.
dnl AC_PROG_F77_C_O
dnl AC_PROG_F77(g77 f77 fort77 fl32 xlf cf77 f90 xlf90)

AC_PROG_FC
AM_PROG_CC_C_O
AC_F77_LIBRARY_LDFLAGS

dnl Checks for programs.
AC_PROG_MAKE_SET
AC_PROG_RANLIB
dnl AC_PROG_LIBTOOL
AC_PROG_INSTALL

dnl override presets with user input if present
dnl
if test -n "$user_cflags"
then
  CFLAGS="$user_cflags"
fi
dnl

dnl Checks for header files.
AC_STDC_HEADERS
AC_HAVE_HEADERS(math.h)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T

dnl Checks for libraries.
dnl ANSICFLAGS=$CFLAGS
dnl SAVED_CFLAGS=$CFLAGS
dnl CFLAGS="$CFLAGS -static"
dnl SAVED_LDFLAGS=$LDFLAGS
dnl LDFLAGS="$LDFLAGS -lm "

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
dnl CFLAGS=$SAVED_CFLAGS
dnl LDFLAGS=$SAVED_LDFLAGS

dnl Checks for library functions.

dnl Enable and check for degug flags
AC_ARG_ENABLE([debug],
[  --enable-debug    Turn on debugging],
[case "${enableval}" in
  yes) debug=true ;;
  no)  debug=false ;;
  *) AC_MSG_ERROR([bad value ${enableval} for --enable-debug]) ;;
esac],[debug=false])
AM_CONDITIONAL([DEBUG], [test x$debug = xtrue])

AC_CONFIG_FILES(Makefile src/Makefile)

AC_OUTPUT()
