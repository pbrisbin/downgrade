  $ source "$TESTDIR/../helper.sh"

From a single directory

  $ cache=$(mktemp -d)
  > touch \
  >   "$cache/foo-1.0-any.pkg.tar.gz" \
  >   "$cache/foo-2.0-any.pkg.tar.gz" \
  >   "$cache/foo-3.5-any.pkg.tar.xz" \
  >   "$cache/foo-1.1-any.pkg.tar.gz" \
  >   "$cache/foo-completions-1.1-any.pkg.tar.gz"
  > write_pacman_conf "CacheDir = $cache/"
  > DOWNGRADE_FROM_CACHE=1 search_packages 'foo' | sort
  /tmp/*/foo-1.0-any.pkg.tar.gz (glob)
  /tmp/*/foo-1.1-any.pkg.tar.gz (glob)
  /tmp/*/foo-2.0-any.pkg.tar.gz (glob)
  /tmp/*/foo-3.5-any.pkg.tar.xz (glob)
