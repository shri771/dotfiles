# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
#session_root "~/Projects/cn"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "cn"; then

 new_window "Terminal"
 run_cmd "cd ~/dotfiles/"
 run_cmd "export TMUXIFIER_DEFAULT_PATH='~/dotfiles'"
 run_cmd "clear"
 
 new_window "Config"
 run_cmd "cd ~/dotfiles" 
 run_cmd "clear"
 select_window 2 


fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
