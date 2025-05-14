 # Open config in nvim ##
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
