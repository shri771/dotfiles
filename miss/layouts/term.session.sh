# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "~/dotfiles/"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "term"; then

 new_window "Term-2"
 run_cmd "cd ~/dotfiles/"
 run_cmd "export TMUXIFIER_DEFAULT_PATH='~/dotfiles'"
 run_cmd "clear"
 run_cmd "tmux link-window -s cn:1 -t term"
    run_cmd "if tmux list-windows -t term | grep -q '^1:';
             tmux kill-window -t term:1;
             end"

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
