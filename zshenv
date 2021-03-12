#
# Editors
#

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

#
# Paths
#

typeset -gU cdpath fpath mailpath path
typeset -gxU MANPATH
typeset -gxUT INFOPATH infopath

# Set the the list of directories that cd searches.
cdpath=(
 $cdpath
 ~
)

# Set the list of directories that info searches for manuals.
infopath=(
  /usr/local/share/info
  /usr/share/info
  $infopath
)

# Set the list of directories that man searches for manuals.
manpath=(
  /usr/local/share/man
  /usr/share/man
  /opt/homebrew/share/man/
  $manpath
)

for path_file in /etc/manpaths.d/*(.N); do
  manpath+=($(<$path_file))
done
unset path_file


# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  /usr/{bin,sbin}
  /{bin,sbin}
  $path
  ~/Downloads/mongodb-macos-x86_64-4.2.8/bin
)

for path_file in /etc/paths.d/*(.N); do
  path+=($(<$path_file))
done
unset path_file

#
# Temporary Files
#

if [[ -d "$TMPDIR" ]]; then
  export TMPPREFIX="${TMPDIR%/}/zsh"
  if [[ ! -d "$TMPPREFIX" ]]; then
    mkdir -p "$TMPPREFIX"
  fi
fi

#
# Locale
#

export LC_CTYPE="UTF-8"

export TF_CLI_ARGS="-parallelism=30"
