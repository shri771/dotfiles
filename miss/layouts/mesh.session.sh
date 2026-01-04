# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "/home/shri/Workspace/meshery/meshery/"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "mesh"; then

    new_window "Term"
    run_cmd "cd /home/shri/Workspace/meshery/meshery/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='/home/shri/Workspace/meshery/meshery/'"
    run_cmd "clear"

    new_window "Vim"
    run_cmd "cd /home/shri/Workspace/meshery/meshery/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='/home/shri/Workspace/meshery/meshery/'"
    run_cmd "clear"

    new_window "server"
    run_cmd "cd /home/shri/Workspace/meshery/meshery/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='/home/shri/Workspace/meshery/meshery/'"
    run_cmd "clear"

    new_window "Vim-2"
    run_cmd "cd /home/shri/Workspace/meshery/meshery/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='/home/shri/Workspace/meshery/meshery/'"
    run_cmd "clear"

    # default window (index 2)
    select_window 2

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
