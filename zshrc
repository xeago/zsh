#
# Executes commands at the start of an interactive session.
#

# keybindings
bindkey -e

# Jobs
setopt LONG_LIST_JOBS     # List jobs in the long format by default.
setopt AUTO_RESUME        # Attempt to resume existing job before creating a new process.
setopt NOTIFY             # Report status of background jobs immediately.
unsetopt BG_NICE          # Don't run all background jobs at a lower priority.

# Add all modules under .zsh/**/
#fpath=("$HOME/.zsh/**/" $fpath)
fpath+=( ~/.zsh/*(/) )

# Options
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
setopt PATH_DIRS           # Perform path search even on command names with slashes.
setopt AUTO_MENU           # Show completion menu on a successive tab press.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash.

WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Styles

# Use caching to make completion for cammands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

# Case-insensitive (all), partial-word, and then substring completion.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
unsetopt CASE_GLOB

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Complete with dots http://stackoverflow.com/a/844299
expand-or-complete-with-dots() {
  print -P -n "%F{red}...%f"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

autoload -U split-shell-arguments

function rationalise-dot() {
  local reply REPLY REPLY2
  if [[ $_IS_PASTING = 1 ]]; then
    zle self-insert
    return
  fi
  #local MATCH
  if [[ $LBUFFER =~ '(^|/| |  |'$'\n''|\||;|&)\.\.$' ]]; then
    LBUFFER+=/
    zle self-insert
    zle self-insert

    split-shell-arguments
    (( REPLY -= 1 ))  # The actual $REPLY is whitespace. See doc for ssa.
    zle -M ${reply[$REPLY]:a}
  else
    zle self-insert
  fi
}

zle -N rationalise-dot
bindkey . rationalise-dot
# without this, typing a . aborts incremental history search
bindkey -M isearch . self-insert

#
# Prompt
#
autoload -Uz promptinit
promptinit
prompt xeago
setopt autocd

#setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

#
# Terminal title
#
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] && [[ -z "$INSIDE_EMACS" ]]; then
  update_terminal_cwd() {
    printf '\e]7;%s\a' "file://$HOSTNAME${PWD/@ @%20}"
  }
  autoload add-zsh-hook
  add-zsh-hook chpwd update_terminal_cwd
  update_terminal_cwd
fi

#
# Apple Terminal session resumption
#
if [[ -e "$HOME/.zsh/sessions/sessions.zsh" ]] then;
  source $HOME/.zsh/sessions/sessions.zsh
  shell_session_save_user_state() {
    whence gcloud >/dev/null && echo 'scloud && echo Loaded gcloud.'
    [[ -n "$VIRTUAL_ENV" ]] && echo 'source '$VIRTUAL_ENV'/bin/activate && echo Activated virtualenv.'
  }
fi

#
# Ruby rbenv
#
if (( $+commands[rbenv] )) then;
  eval "$(rbenv init - --no-rehash zsh)"
fi

#
# Use z to jump around
#
if [[ -e "$HOME/.zsh/z/z.sh" ]] then;
  source $HOME/.zsh/z/z.sh
fi

#
# Source spotify functions
#
if [[ -e "$HOME/.zsh/spotify/spotify.zsh" ]] then;
  source $HOME/.zsh/spotify/spotify.zsh
fi

#
# Source google functions
#
if [[ -e "$HOME/.zsh/google/google.zsh" ]] then;
  source $HOME/.zsh/google/google.zsh
fi

#
# Syntax highlighting
#
if [[ -e "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] then;
  source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
fi

#
# Completion
#
# Finally initialize the completions

# Load and initialize the completion system ignoring insecure directories.
autoload -Uz compinit && compinit -i

if [[ -e "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] then;
  source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi


autoload -U url-quote-magic; zle -N self-insert url-quote-magic
