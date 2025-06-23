# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "~/WorkSpace/"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "dev"; then

    new_window "Terminal"
    run_cmd "cd ~/WorkSpace/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='~/WorkSpace/158309813/'"
    run_cmd "clear"

    new_window "Vim"
    run_cmd "cd ~/WorkSpace/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='~/WorkSpace/158309813/'"
    run_cmd "clear"
    run_cmd "fzf ."

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
