################################################################################
#   0. OTHER FILES
################################################################################
#   bash completion (LEGACY, bash 3.2)
#   ----------------------------------------------------------------------------
    #if [ -f $(brew --prefix)/etc/bash_completion ]; then
    #    . $(brew --prefix)/etc/bash_completion
    #fi

#   bash completion (bash 4.1+)
#   ----------------------------------------------------------------------------
    [[ -r "/usr/local/etc/bash_completion.d/git-completion.bash" ]] && . "/usr/local/etc/bash_completion.d/git-completion.bash"

    # Seems to point to an old version and doesn't work
    # [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
    #if [ -r $(brew --prefix)/etc/profile.d/bash_completion.sh ]; then
    #  . $(brew --prefix)/etc/profile.d/bash_completion.sh
    #fi
    #export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"

#   golangci-ling bash completion
#   ----------------------------------------------------------------------------
#   TODO: Does not appear to work in v1.20.1
    #source <(golangci-lint completion bash)


#   z configuration (smart command line navigation)
#   ----------------------------------------------------------------------------
    if [ -f $(brew --prefix)/etc/profile.d/z.sh ]; then
        . $(brew --prefix)/etc/profile.d/z.sh
    fi

#   liquidprompt
#   ----------------------------------------------------------------------------
#   https://github.com/nojhan/liquidprompt
#   Only load Liquid Prompt in interactive shells, not from a script or from scp
    [[ $- = *i* ]] && source ~/git/liquidprompt/liquidprompt

#   8b bin
#   ----------------------------------------------------------------------------
#	Only add the 8b bin path to the PATH if it's not already there
#	TODO: Can refactor into its own utility function
#	TODO: Check if directory exists too
	_8B_BIN_PATH=/Users/ekirilov/8b/bin
	[[ ":$PATH:" != *":${_8B_BIN_PATH}:"* ]] && PATH="${_8B_BIN_PATH}:${PATH}"


################################################################################
#   1. ENVIRONMENT CONFIGURATION
################################################################################
#   Change Prompt
#   ------------------------------------------------------------
#	Commented out; using liquidprompt at the moment
#    export PS1="________________________________________________________________________________\n| \w @ \h (\u) \n| => "
#    export PS2="| => "

#   Set Default Editor
#   ------------------------------------------------------------
    export EDITOR=/usr/bin/vim

#   Add color to terminal
#   ------------------------------------------------------------
#   Alternatively: http://osxdaily.com/2012/02/21/add-color-to-the-terminal-in-mac-os-x/
    export CLICOLOR=1
    export LSCOLORS=ExFxBxDxCxegedabagacad

#   Go
#   ----------------------------------------------------------------------------
    export GOPATH=$HOME/go
    [[ ":$PATH:" != *":${GOPATH}/bin:"* ]] && PATH="${GOPATH}/bin:${PATH}"
    
    export GOPRIVATE=git.enova.com

#   Go coverage
#   ----------------------------------------------------------------------------
    cover () {
        t="/tmp/go-cover.$$.tmp"
        go test ./... -coverprofile=$t $@ && go tool cover -html=$t && unlink $t
    }

#   chruby
#   ----------------------------------------------------------------------------
    source /usr/local/share/chruby/chruby.sh
    source /usr/local/share/chruby/auto.sh

#   postgres
#   ----------------------------------------------------------------------------
    _POSTGRESQL_PATH=/usr/local/Cellar/postgresql@11/11.6
     [[ ":$PATH:" != *":${_POSTGRESQL_PATH}/bin:"* ]] && PATH="${_POSTGRESQL_PATH}/bin:${PATH}"


################################################################################
#   2. MAKE TERMINAL BETTER
################################################################################
#   'exa' is a better 'ls'
#   ----------------------------------------------------------------------------
    alias exa='exa --header --git --group-directories-first'
    alias l='exa'
    alias ll='l -la'

#   'bat' is a replacement for 'cat'
#   ----------------------------------------------------------------------------
    alias cat='bat'

#   ----------------------------------------------------------------------------
    alias cp='cp -iv'                           # Preferred 'cp' implementation
    alias mv='mv -iv'                           # Preferred 'mv' implementation
    alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
    alias less='less -FSRXc'                    # Preferred 'less' implementation

    alias be='bundle exec'
    alias berc='bundle exec rails console'
    alias reload='source ~/.bash_profile'
    alias s='$(cat ~/.bash_history | fzf)'

#   Quick navigation
#   ----------------------------------------------------------------------------
    cd() { builtin cd "$@"; exa; }              # Always list directory contents upon 'cd' (using 'exa')
    alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
    alias ..='cd ../'                           # Go back 1 directory level
    alias ...='cd ../../'                       # Go back 2 directory levels
    alias .3='cd ../../../'                     # Go back 3 directory levels
    alias .4='cd ../../../../'                  # Go back 4 directory levels
    alias .5='cd ../../../../../'               # Go back 5 directory levels
    alias .6='cd ../../../../../../'            # Go back 6 directory levels

    alias edit='subl -n -w'                           # edit:         Opens any file in sublime editor
    alias f='open -a Finder ./'                 # f:            Opens current directory in MacOS Finder
    alias ~="cd ~"                              # ~:            Go Home
    alias c='clear'                             # c:            Clear terminal display
    alias which='type -all'                     # which:        Find executables
    alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
    alias show_options='shopt'                  # Show_options: display bash options settings
    alias fix_stty='stty sane'                  # fix_stty:     Restore terminal settings when screwed up
    alias cic='set completion-ignore-case On'   # cic:          Make tab-completion case-insensitive
    mcd () { mkdir -p "$1" && cd "$1"; }        # mcd:          Makes new Dir and jumps inside
    trash () { command mv "$@" ~/.Trash ; }     # trash:        Moves a file to the MacOS trash
    ql () { qlmanage -p "$*" >& /dev/null; }    # ql:           Opens any file in MacOS Quicklook Preview

#   lr:  Full Recursive Directory Listing
#   ------------------------------------------
    alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.            Example: mans mplayer codec
#   --------------------------------------------------------------------
    mans () {
        man $1 | grep -iC2 --color=always $2 | less
    }

#   showa: to remind yourself of an alias (given some part of it)
#   ------------------------------------------------------------
    showa () { /usr/bin/grep --color=always -i -a1 $@ ~/Library/init/bash/aliases.bash | grep -v '^\s*$' | less -FSRXc ; }


################################################################################
#   6. NETWORKING
################################################################################
#	myap
#	----------------------------------------------------------------------------
#	Display my public-facing IP address
    alias myip='curl ip.appspot.com'

#   ii
#   ----------------------------------------------------------------------------
#	display useful host related informaton
    ii() {
        echo -e "\nYou are logged on ${RED}$HOST"
        echo -e "\nAdditionnal information:$NC " ; uname -a
        echo -e "\n${RED}Users logged on:$NC " ; w -h
        echo -e "\n${RED}Current date :$NC " ; date
        echo -e "\n${RED}Machine stats :$NC " ; uptime
        echo -e "\n${RED}Current network location :$NC " ; scselect
        echo -e "\n${RED}Public facing IP Address :$NC " ;myip
        #echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
        echo
    }

################################################################################
#   7. ENOVA
################################################################################
#   Create a loan using ncj
#	----------------------------------------------------------------------------
    function loan
    {
      ncj account create --region=VA
      ncj loan apply --current --with-lender-decision --disbursement_amount=1000 --product=netcredit
    }

#   Create an LOC using ncj
#	----------------------------------------------------------------------------
    function loc
    {
      ncj account create --region=UT
      ncj loan apply --current --with-lender-decision --disbursement_amount=500 --product=netcredit_line_of_credit
    }
