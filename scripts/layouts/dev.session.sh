# Default session # You can leave the session root as a fallback baseline
session_root "~/Workspace/"

if initialize_session "dev"; then

  # --- Window 1: term ---
  window_root "~/Workspace/"

  new_window "term"
  run_cmd "clear"

  # --- Window 2: vim ---
  window_root "~/Workspace/"
  new_window "vim"
  run_cmd "clear"

  select_window "vim"

fi

finalize_and_go_to_session
