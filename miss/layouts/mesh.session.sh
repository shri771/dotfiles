# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "~/WorkSpace/meshery/mes/"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "mesh"; then

    new_window "Term"
    run_cmd "cd ~/WorkSpace/meshery/mes/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='~/WorkSpace/meshery/mes/'"
    run_cmd "clear"

    new_window "Vim"
    run_cmd "cd ~/Workspace/meshery/meshery/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='~/WorkSpace/meshery/mes/'"
    run_cmd "clear"

    new_window "server"
    run_cmd "cd ~/Workspace/meshery/meshery/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='~/Workspace/meshery/meshery/'"
    run_cmd "clear"

    new_window "Vim"
    run_cmd "cd ~/Workspace/meshery/meshery"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='~/WorkSpace/meshery/meshery'"
    run_cmd "clear"
     select_window 2


fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
