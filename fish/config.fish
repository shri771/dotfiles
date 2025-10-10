# set -Ux PERL5LIB /usr/share/perl5/vendor_perl
# ====================================
# ENVIRONMENT VARIABLES & INITIAL SETUP
# ====================================
set -U fish_greeting ""
set -x MANPAGER "nvim +Man!"

# Set Neovim as the default editor
set -x VISUAL nvim
set -x EDITOR nvim

# ====================================
# FISH COLORS & SYNTAX HIGHLIGHTING
# ====================================
# Use your existing color scheme
set -U fish_color_autosuggestion 7d7d7d
set -U fish_color_cancel -r
set -U fish_color_command brcyan
set -U fish_color_comment brmagenta
set -U fish_color_cwd green
set -U fish_color_cwd_root red
set -U fish_color_end green
set -U fish_color_error ff6c6b
set -U fish_color_escape brcyan
set -U fish_color_history_current --bold
set -U fish_color_host normal
set -U fish_color_host_remote yellow
set -U fish_color_normal brcyan
set -U fish_color_operator brcyan
set -U fish_color_param brcyan
set -U fish_color_quote yellow
set -U fish_color_redirection cyan --bold
set -U fish_color_search_match white --background=brblack
set -U fish_color_selection white --bold --background=brblack
set -U fish_color_status red
set -U fish_color_user brgreen
set -U fish_color_valid_path --underline
set -U fish_pager_color_completion normal
set -U fish_pager_color_description yellow -i
set -U fish_pager_color_prefix normal --bold --underline
set -U fish_pager_color_progress brwhite --background=cyan
set -U fish_pager_color_selected_background -r

# Custom fzf color scheme, inheriting the terminal background
# --- FZF CONFIGURATION (for jethrokuan/fzf plugin) ---

# 1. Set LAYOUT for the history (Ctrl-R) window.
# This is the specific variable for the plugin and will NOT affect other fzf windows.
set -g fzf_history_opts "--height 50% --layout=default --border=rounded --margin=1"

# 2. Set default options for COLORS ONLY.
# By keeping layout settings out of here, we avoid conflicts.
# This will apply to ALL fzf windows.
set -x FZF_DEFAULT_OPTS "\
--color=spinner:#f8f8f2,hl:#bd93f9,fg:#f8f8f2,header:#6272a4 \
--color=info:#bd93f9,pointer:#ff79c6,marker:#ff79c6,fg+:#f8f8f2 \
--color=prompt:#50fa7b,hl+:#f8f8f2,border:#6272a4,bg+:reverse"

set -U FZF_TMUX 1

# ====================================
# KEY BINDINGS
# ====================================
set -U fish_key_bindings fish_default_key_bindings

function fish_user_key_bindings
    bind \cb backward-word
    bind \cf forward-word

    # History bindings for !! and !$
    if test "$fish_key_bindings" = fish_vi_key_bindings
        bind -Minsert ! __history_previous_command
        bind -Minsert '$' __history_previous_command_arguments
    else
        bind ! __history_previous_command
        bind '$' __history_previous_command_arguments
    end
end

# ====================================
# UTILITY FUNCTIONS
# ====================================

# Ctrl+T binding for Workspace FZF launcher
# This overrides the default fzf Ctrl+T file search
function workspace_launcher
    # Run the script
    /home/sh/dotfiles/scripts/terminal/Workspacefzf.sh
    commandline -f repaint
end

# Bind Ctrl+T to the workspace launcher function
bind \ct workspace_launcher
# History functions for !! and !$ support
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]; commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""; commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

# Text processing utilities
function coln -d "Print specific column from input"
    awk '{print $'$argv[1]'}'
end

function rown -a index -d "Print specific row from input"
    sed -n "$index p"
end

function skip -a n -d "Skip first n lines"
    tail +(math 1 + $n)
end

function take -a number -d "Take first n lines"
    head -$number
end

# ====================================
# DOTFILE MANAGEMENT
# ====================================

function open_dotfile
    set target_directory $argv[1]
    set target_file $argv[2]

    if string match -q "*-" (status current-command)
        cd $target_directory
        return
    end

    if test (pwd) = $target_directory
        if test -n "$target_file"
            nvim $target_directory/$target_file
        else
            nvim .
        end
    else
        cd $target_directory
        if test -n "$target_file"
            nvim $target_file
        else
            nvim .
        end
    end
end

# Dotfile shortcuts
function hycn
    open_dotfile ~/dotfiles/hypr
end

function hycn-
    open_dotfile ~/dotfiles/hypr
end

function swcn
    open_dotfile ~/dotfiles/swaync/
end

function swcn-
    open_dotfile ~/dotfiles/swaync/
end

function scr
    open_dotfile ~/dotfiles/scripts/
end

function scr-
    open_dotfile ~/dotfiles/scripts/
end

function wycn
    open_dotfile ~/dotfiles/waybar/
end

function plcn
    open_dotfile ~/dotfiles/polybar/ config.ini
end

function plcn-
    open_dotfile ~/dotfiles/polybar/
end

function wycn-
    open_dotfile ~/dotfiles/waybar/
end

function awcn
    open_dotfile ~/dotfiles/awesome rc.lua
end

function awcn-
    open_dotfile ~/dotfiles/awesome
end

function nvcn
    open_dotfile ~/dotfiles/nvim init.lua
end

function nvcn-
    open_dotfile ~/dotfiles/nvim
end

function fhcn
    open_dotfile ~/dotfiles/fish config.fish
end

function fhcn-
    open_dotfile ~/dotfiles/fish
end

function pycn
    open_dotfile ~/dotfiles/polybar config.ini
end

function pycn-
    open_dotfile ~/dotfiles/polybar
end

function txcn
    open_dotfile ~/dotfiles/tmux tmux.conf
end

function txcn-
    open_dotfile ~/dotfiles/tmux
end

function txs
    open_dotfile ~/dotfiles/tmux/plugins/tmuxifier/layouts
end

function txs-
    open_dotfile ~/dotfiles/tmux/plugins/tmuxifier/layouts
end

function ktcn
    open_dotfile ~/dotfiles/kitty
end

function ktcn-
    open_dotfile ~/dotfiles/kitty
end

# ====================================
# SYSTEM MANAGEMENT FUNCTIONS
# ====================================

function cpm -d "Change CPU power mode"
    argparse 'p/performance' 'b/battery' -- $argv
    or return

    if set -q _flag_performance
        echo "Setting CPU mode to Performance..."
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    else if set -q _flag_battery
        echo "Setting CPU mode to Battery Saver..."
        echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    else
        echo "Usage: cpm -p/--performance | -b/--battery"
        return 1
    end
end

function snc -a description -d "Create snapper snapshot"
    if not set -q description[1]
        echo "Usage: snc <snapshot description>"
        return 1
    end
    sudo snapper -c root create --description "$description"
end

function shpwd- -d "Show WiFi passwords as QR codes"
    nmcli connection show | awk '$3=="wifi" {print $1}' | while read -l ssid
        echo "SSID: $ssid"
        set password (nmcli -s -g 802-11-wireless-security.psk connection show "$ssid")
        if test -n "$password"
            qrencode -t UTF8 "WIFI:S:$ssid;T:WPA;P:$password;;"
        else
            echo "No password found for $ssid"
        end
        echo ""
    end
end

function en -d "Encrypt/decrypt files with GPG"
    switch (count $argv)
        case 1
            set file $argv[1]
            echo "Encrypting file: $file"

            set outfile (string match -r '.*\.txt$' $file && string replace -r '\.txt$' '.gpg' $file || echo "$file.gpg")
            echo "Output file: $outfile"

            gpg --symmetric --cipher-algo AES256 -o "$outfile" "$file"

        case 2
            set encfile $argv[1]
            set dest $argv[2]

            if test "$dest" = "."
                set dest (string replace -r '\.gpg$' '' $encfile)
            end

            echo "Decrypting file: $encfile to $dest"
            gpg -o "$dest" -d "$encfile"

        case '*'
            echo "Usage:"
            echo "  en <file>                  # Encrypts <file> and appends .gpg"
            echo "  en <encrypted_file> <dest> # Decrypts <encrypted_file> to <dest>"
            echo "     If <dest> is '.' then the original filename is restored"
            return 1
    end

    # Clear cached passphrase
    gpgconf --kill gpg-agent
    gpgconf --launch gpg-agent
end

# Override cd to use zoxide
function cd -w z
    z $argv
end

# Add directory completion for cd
complete -c cd -x -a '(__fish_complete_directories)'

# ====================================
# ALIASES
# ====================================

# Navigation
alias .='cd'
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# System config shortcuts
alias tpcn='sudo nvim /etc/X11/xorg.conf.d/40-libinput.conf'
alias syscn='cd /etc/systemd/system/ && sn .'
alias syscn-='cd /etc/systemd/system/'

# Quick commands
alias n='nvim'
alias sn='sudo -E XDG_RUNTIME_DIR=/run/user/$(id -u) HOME=/home/sh nvim'
alias arch='fastfetch'
alias speed='speedtest'
alias mke='chmod +x'

# Variety wallpaper
alias vn='variety --next'
alias vp='variety'

# Network
alias nm-a='nmcli device wifi list'
alias nm-c='nmcli connection show'
alias shpwd='nmcli -g WIFI-QR device wifi show-password'

# Utilities
alias imp='kitty +kitten icat'
alias vm='source ~/.venvs/pyprland/bin/activate.fish'
alias rm='trash-put'
alias temp='watch -n 1 sensors'
alias cmd='command '

# Media controls
alias nxt='playerctl next'
alias prs='playerctl previous'

# System monitoring
alias tlp-m='tlp-stat -p | grep scaling_governor'
alias syst='systemctl list-timers --all '

# Scripts
alias en-='bash $HOME/scripts/system/edit_gpg.sh'
alias sf='bash $HOME/scripts/terminal/fzf_search.sh'
alias ventoy='cd $HOME/Downloads/ISO/ventoy-1.1.05/ &&  ./VentoyGUI.x86_64'

# Display
alias hdmiCon='xrandr --output HDMI-1 --same-as eDP-1 --mode 1920x1080'

# Package management
alias pacins='sudo pacman -S'
alias pacrm='sudo pacman -R'
alias parsua='paru -Sua --noconfirm'
alias parsyu='paru -Syu --noconfirm'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias orphan='sudo pacman -Rns (pacman -Qtdq)'
alias pkgin='bash $HOME/scripts/terminal/pkg_search.sh'

# Mirror management
alias mirror='sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist'
alias mirrord='sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist'
alias mirrors='sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist'
alias mirrora='sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist'
alias up_mirr='sudo reflector --country India --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syy && sudo pacman -Syu'

# Enhanced ls with eza
alias ls='eza -al --color=always --group-directories-first'
alias la='eza -a --color=always --group-directories-first'
alias ll='eza -l --color=always --group-directories-first'
alias lt='eza -aT --color=always --group-directories-first'
alias l.='eza -al --color=always --group-directories-first ../'
alias l..='eza -al --color=always --group-directories-first ../../'
alias l...='eza -al --color=always --group-directories-first ../../../'

# System info
alias df='df -h'
alias free='free -m'
alias grep='grep --color=auto'

# Process management
alias psa='ps auxf'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# X resources
alias merge='xrdb -merge ~/.Xresources'

# Git aliases
alias add='git add '
alias addall='git add .'
alias bh='git branch'
alias gst='git status'
alias ck='git checkout'
alias cl='git clone'
alias cm='git commit -m'
alias alc='git commit -am'
alias fetch='git fetch'
alias pl='git pull origin'
alias ph='git push origin'
alias tag='git tag'
alias newtag='git tag -a'

# Git scripts
alias gpha='bash ~/scripts/terminal/git_push.sh'
alias gfz='bash $HOME/scripts/terminal/git-restore-fzf.sh'

# Snapper
alias snl='sudo snapper -c root list'
alias sno='dolphin  /.snapshots/'
alias snd='bash $HOME/scripts/terminal/del_snapshot.sh'
alias snr='bash $HOME/scripts/terminal/res_snapshot.sh'

# Tmux
alias tx='tmux'
alias txa='tmux a'
alias txc='tmuxifier load-session cn'
alias txsc='tmuxifier load-session sc '
alias txdev='tmuxifier load-session dev'

# Journal
alias jctl='journalctl -p 3 -xb'

# GPG
alias gpg-check='gpg2 --keyserver-options auto-key-retrieve --verify'
alias gpg-retrieve='gpg2 --keyserver-options auto-key-retrieve --receive-keys'

# Shell switching
alias tobash='sudo chsh $USER -s /bin/bash && echo "Log out and log back in for change to take effect."'
alias tozsh='sudo chsh $USER -s /bin/zsh && echo "Log out and log back in for change to take effect."'
alias tofish='sudo chsh $USER -s /bin/fish && echo "Log out and log back in for change to take effect."'

# ====================================
# PROMPT AND INTEGRATIONS
# ====================================
# Initialize Starship and Zoxide (at the end for better performance)
if command -q starship
    starship init fish | source
end

if command -q zoxide
    zoxide init fish | source
end
##For go
fish_add_path $HOME/go/bin
source $HOME/.tenv.completion.fish


# The next line updates PATH for the Google Cloud SDK.
if test -f '/home/sh/backups/google-cloud-sdk/path.fish.inc'
    source '/home/sh/backups/google-cloud-sdk/path.fish.inc'
end

# Initialize Carapace for Fish
carapace _carapace | source
