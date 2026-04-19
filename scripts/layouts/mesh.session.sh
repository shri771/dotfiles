# Default session # You can leave the session root as a fallback baseline
session_root "~/Workspace/meshery/meshery"

if initialize_session "mesh"; then

  # --- Window 1: term ---
  window_root "~/Workspace/meshery/meshery/master/"
  new_window "term"
  run_cmd "clear"

  # --- Window 2: vim ---
  window_root "~/Workspace/meshery/meshery/master/"
  new_window "vim"
  run_cmd "clear"

  # --- Window 3: vim-2 ---
  window_root "~/Workspace/meshery/meshery/master/"
  new_window "vim-2"
  run_cmd "clear"

  # --- Window 4: server ---
  window_root "~/Workspace/meshery/meshery/master/"
  new_window "server"
  run_cmd "minikube start"
  run_cmd "make server"

  # Select the 'vim' window on startup
  select_window "vim"

fi

finalize_and_go_to_session
