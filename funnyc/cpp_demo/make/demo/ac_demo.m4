AC_DEFUN([AC_DEMO_FOO],
[
  # Print a helpful message on how to acquire the necessary build dependency.
  # $1 is the help tag: cups, alsa etc
  MISSING_DEPENDENCY=$1

  if test "x$MISSING_DEPENDENCY" = "xopenjdk"; then
    HELP_MSG="OpenJDK distributions are available at http://jdk.java.net/."
  elif test "x$OPENJDK_BUILD_OS_ENV" = "xwindows.cygwin"; then
    cygwin_help $MISSING_DEPENDENCY
  elif test "x$OPENJDK_BUILD_OS_ENV" = "xwindows.msys"; then
    msys_help $MISSING_DEPENDENCY
  else
    PKGHANDLER_COMMAND=

    case $PKGHANDLER in
      apt-get)
        apt_help     $MISSING_DEPENDENCY ;;
      yum)
        yum_help     $MISSING_DEPENDENCY ;;
      brew)
        brew_help    $MISSING_DEPENDENCY ;;
      port)
        port_help    $MISSING_DEPENDENCY ;;
      pkgutil)
        pkgutil_help $MISSING_DEPENDENCY ;;
      pkgadd)
        pkgadd_help  $MISSING_DEPENDENCY ;;
      zypper)
        zypper_help  $MISSING_DEPENDENCY ;;
    esac

    if test "x$PKGHANDLER_COMMAND" != x; then
      HELP_MSG="You might be able to fix this by running '$PKGHANDLER_COMMAND'."
    fi
  fi
])

