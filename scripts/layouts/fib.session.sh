# Default session
session_root "~/Workspace/fabric/"

if initialize_session "fib"; then

  window_root "~/Workspace/fabric/"
  new_window "term"
  run_cmd "clear"

  window_root "~/Workspace/fabric/"
  new_window "vim"
  run_cmd "clear"

  window_root "~/Workspace/fabric/"
  new_window "vim-2"
  run_cmd "clear"

  window_root "~/Workspace/fabric/"
  new_window "server"
  run_cmd "clear"

  select_window "vim"

fi

finalize_and_go_to_session
