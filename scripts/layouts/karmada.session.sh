# Default session
session_root "~/Workspace/karmada/"

if initialize_session "karmada"; then

  window_root "~/Workspace/karmada/"
  new_window "term"
  run_cmd "clear"

  window_root "~/Workspace/karmada/"
  new_window "vim"
  run_cmd "clear"

  window_root "~/Workspace/karmada/"
  new_window "vim-2"
  run_cmd "clear"

  window_root "~/Workspace/karmada/"
  new_window "server"
  run_cmd "clear"

  select_window "vim"

fi

finalize_and_go_to_session
