### ADDING TO THE PATH
# First line removes the path; second line sets it.  Without the first line,
# your path gets massive and fish becomes very slow.
set -e fish_user_paths
set -U fish_user_paths $HOME/.bin $HOME/.local/bin $HOME/.config/emacs/bin $HOME/Applications /var/lib/flatpak/exports/bin/ $fish_user_paths

### EXPORT ###
set -U fish_greeting ""
set TERM xterm-256color # Sets the terminal type
set -Ux EDITOR nvim
set -Ux VISUAL nvim
set -gx PATH $HOME/.local/bin $PATH
set -Ux TERM xterm-256color
set -U LC_CTYPE en_US.UTF-8
eval ($HOME/.config/tmux/plugins/tmuxifier/bin/tmuxifier init - fish)
export XCURSOR_THEME=Bibata-Modern-Classic
export XCURSOR_SIZE=22
set -Ux QT_ICON_THEME WhiteSur-dark
set -Ux PERL5LIB /usr/share/perl5/vendor_perl
set -Ux BORG_PASSCOMMAND "cat $HOME/.borg_passphrase"
##local
##set -x LANG en_US.UTF-8


### SET MANPAGER
### Uncomment only one of these!

### "nvim" as manpager
set -x MANPAGER "nvim +Man!"

### "less" as manpager
# set -x MANPAGER "less"

### ENABLE VIM KEYBINDINGS ###
function fish_user_key_bindings
    # fish_default_key_bindings
    fish_vi_key_bindings
end
### END OF VI MODE ###

### AUTOCOMPLETE AND HIGHLIGHT COLORS ###
set fish_color_normal brcyan
set fish_color_autosuggestion '#7d7d7d'
set fish_color_command brcyan
set fish_color_error '#ff6c6b'
set fish_color_param brcyan

### FUNCTIONS ###

# Functions needed for !! and !$
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

# The bindings for !! and !$
if [ "$fish_key_bindings" = fish_vi_key_bindings ]
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

# Function for creating a backup file
# ex: backup file.txt
# result: copies file as file.txt.bak
function backup --argument filename
    cp $filename $filename.bak
end

# Function to expand :: to /home/shri/
function expand_colon
    # Get the current command line input
    set cmd (commandline)

    # Replace :: with /home/shri/
    set cmd (string replace "hm" "/home/shri/" $cmd)

    # Update the command line with the replaced value
    commandline -r $cmd
end
function fish_preexec
    expand_colon
end

# Function for copying files and directories, even recursively.
# ex: copy DIRNAME LOCATIONS
# result: copies the directory and all of its contents.
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (echo $argv[1] | trim-right /)
        set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

function expand_double_colon
    commandline -r (string replace -a '::' '~/' (commandline -t))
    commandline -f repaint
end


# Function for printing a column (splits input on whitespace)
# ex: echo 1 2 3 | coln 3
# output: 3
function coln
    while read -l input
        echo $input | awk '{print $'$argv[1]'}'
    end
end

# Function for printing a row
# ex: seq 3 | rown 3
# output: 3
function rown --argument index
    sed -n "$index p"
end

# Function for ignoring the first 'n' lines
# ex: seq 10 | skip 5
# results: prints everything but the first 5 lines
function skip --argument n
    tail +(math 1 + $n)
end

# Function for taking the first 'n' lines
# ex: seq 10 | take 5
# results: prints only the first 5 lines
function take --argument number
    head -$number
end

# Function for org-agenda
function org-search -d "send a search string to org-mode"
    set -l output (/usr/bin/emacsclient -a "" -e "(message \"%s\" (mapconcat #'substring-no-properties \
        (mapcar #'org-link-display-format \
        (org-ql-query \
        :select #'org-get-heading \
        :from  (org-agenda-files) \
        :where (org-ql--query-string-to-sexp \"$argv\"))) \
        \"
    \"))")
    printf $output
end

# Copies the file to Backup dir
function ba
    # Ensure at least one argument is provided
    if test (count $argv) -eq 0
        echo "Usage: ba <file1> [file2 ...]"
        return 1
    end

    # Set backup directory
    set -l backup_dir ~/backups

    # Create the backup directory if it doesn't exist
    mkdir -p $backup_dir

    # Iterate over arguments to copy each file or directory
    for file in $argv
        if test -e $file
            cp -a $file $backup_dir
            echo "Backup of $file completed to $backup_dir"
        else
            echo "Error: $file does not exist" >&2
        end
    end
end

## Git Funcions ##
# Pushes git with a arugument
function gph
    # Ensure at least two arguments are provided
    if test (count $argv) -lt 2
        echo "Usage: gph <file1> [file2 ...] <commit message>"
        return 1
    end

    # Extract the commit message (last argument) and files (all but last)
    set commit_message $argv[-1]
    set files $argv[1..-2]

    # Add files, commit, push, and display status
    git add $files
    if not git commit -m "$commit_message"
        echo "Failed to commit changes" >&2
        return 1
    end

    echo "============================================================"
    if not git push
        echo "Failed to push changes" >&2
        return 1
    end
    echo "============================================================"
    git status
end


function ups
    echo "Refreshing Arch Linux mirrors for best performance..."
    if not reflector --latest 10 --sort rate --protocol https --save ~/mirrorlist
        echo "Error: Failed to refresh mirrors using reflector" >&2
        return 1
    end
    echo "Mirrors updated successfully. Note: Changes saved to ~/mirrorlist; root privileges are required to apply them."

    echo "Synchronizing package databases (read-only)..."
    if not pacman -Sy --dbpath ~/.cache/pacman/db
        echo "Error: Failed to synchronize package databases (read-only)" >&2
        return 1
    end

    echo "Checking for security updates (read-only)..."
    set security_updates (checkupdates | grep -Ei 'linux|kernel|openssl|gpg|glibc|systemd|crypt' | awk '{print $1}')
    if test (count $security_updates) -eq 0
        echo "No security updates available."
        return 0
    end

    echo "The following security updates are available:"
    echo $security_updates

    echo "Note: You need root privileges to apply updates. Use 'sudo pacman -S <packages>' to install them."
end


## Open config in nvim ##
function open_dotfile
    # Generalized function for handling dotfiles
    # Arguments: target_directory, target_file
    # If no file is passed, opens the target directory in Neovim
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

# Configs path
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


function sysr
    if test (count $argv) -eq 0
        printf "Usage: scr <service1> [service2 ...]\n" >&2
        return 1
    end

    sudo systemctl daemon-reload
    if test $status -ne 0
        printf "Failed to reload systemd daemon\n" >&2
        return 1
    end

    for service in $argv
        printf "Restarting %s...\n" $service
        sudo systemctl restart $service
        if test $status -ne 0
            printf "Failed to restart service: %s\n" $service >&2
        else
            printf "Service %s restarted successfully.\n" $service
        end
    end
end

# Function to Show Status of systemd se or tim
function syss
    if test (count $argv) -eq 0
        printf "Usage: scs <service-or-timer> [more...]\n" >&2
        return 1
    end

    for unit in $argv
        if not string match -q -- "*.service" "$unit" && not string match -q -- "*.timer" "$unit"
            printf "Error: '%s' is not a valid .service or .timer\n" "$unit" >&2
            continue
        end

        printf "\n--- Status of %s ---\n" "$unit"
        systemctl status "$unit" --no-pager
    end
end

# Function to change CPU governor 
function cpm --description "Change CPU power mode"
    if test (count $argv) -eq 0
        echo "Usage: cpm -p (performance) | -b (battery saver)"
        return 1
    end

    switch $argv[1]
        case -p
            echo "Setting CPU mode to Performance..."
            echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        case -b
            echo "Setting CPU mode to Battery Saver..."
            echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        case '*'
            echo "Invalid option. Use -p for Performance or -b for Battery Saver."
            return 1
    end
end

## End of Open Config ##

# Tmux Funcions #
# Open aw config and thmes
function txaw
    # Check if the "aw" session exists in tmux
    if tmux has-session -t aw ^/dev/null
        tmux attach-session -t aw
        return 0
    else

     # Run Neovim immediately
     nvim +q

     # Check if Tmuxifier is installed and load the session
     if type -q tmuxifier
        tmuxifier load-session aw; or begin
            echo "Failed to load Tmuxifier session 'aw'" >&2
            return 1
        end
     else
        echo "Tmuxifier is not installed or not in your PATH" >&2
        return 1
     end
    end
end


function shpwd-
    # List all saved Wi-Fi connections of type "wifi" and process each one
    nmcli connection show | awk '$3=="wifi" {print $1}' | while read ssid
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



function en
    # If only one argument, encrypt the file.
    if test (count $argv) -eq 1
        set file $argv[1]
        echo "Encrypting file: $file"
        
        # Determine the output filename:
        if test (string match -r '.*\.txt$' $file)
            set outfile (string replace -r '\.txt$' '.gpg' $file)
        else
            set outfile "$file.gpg"
        end

        echo "Output file: $outfile"
        gpg --symmetric --cipher-algo AES256 -o "$outfile" "$file"

        # Clear cached passphrase
        gpgconf --kill gpg-agent
        gpgconf --launch gpg-agent

    else if test (count $argv) -eq 2
        set encfile $argv[1]
        set dest $argv[2]

        # If second argument is ".", derive output filename by stripping .gpg
        if test "$dest" = "."
            set dest (string replace -r '\.gpg$' '' $encfile)
        end

        echo "Decrypting file: $encfile to $dest"
        gpg -o "$dest" -d "$encfile"

        # Clear cached passphrase
        gpgconf --kill gpg-agent
        gpgconf --launch gpg-agent

    else
        echo "Usage:"
        echo "  en <file>                  # Encrypts <file> and appends .gpg"
        echo "  en <encrypted_file> <dest> # Decrypts <encrypted_file> to <dest>"
        echo "     If <dest> is '.' then the original filename is restored"
        return 1
    end
end

function cd
    z $argv
end

# 1. Force directory completions for cd
complete -c cd -x -a '(__fish_complete_directories)'


### END OF FUNCTIONS ###


### ALIASES ###
# navigation
alias .='cd'
alias ..='cd ..'
alias .3='cd ../../..'
alias .2='cd ../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

#path for con
alias tpcn=' sudo nvim /etc/X11/xorg.conf.d/40-libinput.conf'
alias vn='variety --next'
alias vp='variety'
alias n='nvim'
alias cd='z'
alias sn='sudo -E XDG_RUNTIME_DIR=/run/user/$(id -u) HOME=/home/sh nvim'
alias tlp-m='tlp-stat -p | grep scaling_governor'
alias syst='systemctl list-timers --all '
alias imp='kitty +kitten icat'
alias syscn='cd /etc/systemd/system/ && sn .'
alias syscn-='cd /etc/systemd/system/'
alias suse='fastfetch'
alias speed='speedtest'
alias mke='chmod +x'
alias nm-a='nmcli device wifi list'
alias nm-c='nmcli connection show'
alias en-='bash $HOME/scripts/system/edit_gpg.sh'
alias ventoy='cd $HOME/Downloads/ISO/ventoy-1.1.05/ &&  ./VentoyGUI.x86_64'
alias shpwd='nmcli -g WIFI-QR device wifi show-password'
alias vm='source ~/.venvs/pyprland/bin/activate.fish'
alias rm='trash-put'
alias nxt='playerctl next'
alias prs='playerctl previous'

# vim and emacst
alias emacs="emacsclient -c -a 'emacs'"
alias em='/usr/bin/emacs -nw'
alias rem="killall emacs || echo 'Emacs server not running'; /usr/bin/emacs --daemon" # Kill Emacs and restart daemon..

# Changing "ls" to "eza"
alias ls='eza -al --color=always --group-directories-first' # my preferred listing
alias la='eza -a --color=always --group-directories-first' # all files and dirs
alias ll='eza -l --color=always --group-directories-first' # long format
alias lt='eza -aT --color=always --group-directories-first' # tree listing
alias l.='eza -a | egrep "^\."'
alias l.='eza -al --color=always --group-directories-first ../' # ls on the PARENT directory
alias l..='eza -al --color=always --group-directories-first ../../' # ls on directory 2 levels up
alias l...='eza -al --color=always --group-directories-first ../../../' # ls on directory 3 levels up
alias temp='watch -n 1 sensors'
alias cmd='command '

# pacman and yay
alias pacins='sudo pacman -S' # update only standard pkgs
alias pacrm='sudo pacman -R' # Refresh pkglist & update standard pkgs
alias parsua='paru -Sua --noconfirm' # update only AUR pkgs (paru)
alias parsyu='paru -Syu --noconfirm' # update standard pkgs and AUR pkgs (paru)
alias unlock='sudo rm /var/lib/pacman/db.lck' # remove pacman lock
alias orphan='sudo pacman -Rns (pacman -Qtdq)' # remove orphaned packages (DANGEROUS!)
alias pkgin='bash $HOME/scripts/terminal/pkg_search.sh'

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# adding flags
alias df='df -h' # human-readable sizes
alias free='free -m' # show sizes in MB
alias grep='grep --color=auto' # colorize output (good for log files)

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Merge Xresources
alias merge='xrdb -merge ~/.Xresources'

# git
alias add='git add '
alias addall='git add .'
alias bh='git branch'
alias gst='git status'
alias gpha='bash ~/scripts/terminal/git_push.sh'
alias ck='git checkout'
alias cl='git clone'
alias gfz='bash $HOME/scripts/terminal/git-restore-fzf.sh'
alias cm='git commit -m'
alias alc='git commit -am'
alias fetch='git fetch'
alias pl='git pull origin'
alias ph='git push origin'
alias tag='git tag'
alias newtag='git tag -a'

#Snapper
function snc
    if test (count $argv) -eq 0
        echo "Usage: snc <snapshot description>"
        return 1
    end
    sudo snapper -c root create --description "$argv"
end
alias snl="sudo snapper -c root list"
alias sno="  dolphin  /.snapshots/"
alias snd="bash $HOME/scripts/terminal/del_snapshot.sh"
alias snr="bash $HOME/scripts/terminal/res_snapshot.sh"
# tmux
alias tx="tmux"
alias txa="tmux a"
#alias txc="bash ~/scripts/txc.sh"
alias txc="gcc -o ~/scripts/terminal/txc ~/scripts/terminal/txc.c && ~/scripts/terminal/txc"
alias txt="gcc -o ~/scripts/terminal/txt ~/scripts/terminal/txt.c && ~/scripts/terminal/txt"

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# gpg encryption
# verify signature for isos
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
# receive the key of a developer
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

# change your default USER shell
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Log out and log back in for change to take effect.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Log out and log back in for change to take effect.'"
alias tofish="sudo chsh $USER -s /bin/fish && echo 'Log out and log back in for change to take effect.'"

# bare git repo alias for dotfiles
alias config="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME"

# termbin
alias tb="nc termbin.com 9999"

# the terminal rickroll
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

# Mocp must be launched with bash instead of Fish!
alias mocp="bash -c mocp"

### RANDOM COLOR SCRIPT ###
# Get this script from my GitLab: gitlab.com/dwt1/shell-color-scripts
# Or install it from the Arch User Repository: shell-color-scripts
#colorscript random

### SETTING THE STARSHIP PROMPT ###
starship init fish | source

# Generated for envman. Do not edit.
test -s ~/.config/envman/load.fish; and source ~/.config/envman/load.fish

# Created by `pipx` on 2025-02-28 09:09:27
set PATH $PATH /home/sh/.local/bin
zoxide init fish | source
