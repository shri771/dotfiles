#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define TERM_SESSION "term"
#define CN_SESSION "cn"

int main() {
  // Step 1: Check if the 'term' session exists
  if (system("tmux has-session -t " TERM_SESSION " &>/dev/null") == 0) {
    // Attach to the existing session using tmuxifier
    execlp("tmux", "tmux", "attach-session", "-t", TERM_SESSION, (char *)NULL);
    perror("Failed to attach to tmux session");
    return 1;
  }

  // Step 2: If 'term' session does not exist, proceed with setup

  // Run Neovim and immediately quit
  if (system("nvim +q") != 0) {
    fprintf(stderr, "Failed to launch Neovim\n");
    return 1;
  }

  // Step 3: Check if Tmuxifier is installed
  if (system("command -v tmuxifier &>/dev/null") != 0) {
    fprintf(stderr, "Tmuxifier is not installed or not in your PATH\n");
    return 1;
  }

  // Step 4: Load the 'term' session using Tmuxifier
  if (system("tmuxifier load-session " TERM_SESSION) != 0) {
    fprintf(stderr, "Failed to load Tmuxifier session '%s'\n", TERM_SESSION);
    return 1;
  }

  return 0;
}
