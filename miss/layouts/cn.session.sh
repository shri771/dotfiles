# Set a custom session root path. Default is $HOME.
# Must be called before initialize_session.
# session_root "~/Projects/cn"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "cn"; then

    # Create a function to capture the current working directory
    get_current_dir() {
        # Get the current working directory
        pwd
    }

    # Create first window and set the working directory
    new_window "Terminal"
    run_cmd "cd ~/dotfiles/"
    run_cmd "export TMUXIFIER_DEFAULT_PATH='~/dotfiles'"
    run_cmd "clear"
    
    # Store the current directory after opening the first window
    CURRENT_DIR=$(get_current_dir)

    # Create the second window with the same working directory as the first
    new_window "Config"
    run_cmd "cd $CURRENT_DIR"
    run_cmd "clear"
    select_window 2

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
