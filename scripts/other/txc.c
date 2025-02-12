#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define SESSION_NAME "cn"

int main() {
    // Check if the tmux session exists
    if (system("tmux has-session -t " SESSION_NAME " &>/dev/null") == 0) {
        // Attach to the existing session
        execlp("tmux", "tmux", "attach-session", "-t", SESSION_NAME, (char *)NULL);
        perror("Failed to attach to tmux session");
        return 1;
    }

    // Start Neovim and immediately quit
    if (system("nvim +q") != 0) {
        fprintf(stderr, "Failed to launch Neovim\n");
        return 1;
    }

    // Check if Tmuxifier is installed
    if (system("command -v tmuxifier &>/dev/null") != 0) {
        fprintf(stderr, "Tmuxifier is not installed or not in your PATH\n");
        return 1;
    }

    // Try to load the Tmuxifier session
    if (system("tmuxifier load-session " SESSION_NAME) != 0) {
        fprintf(stderr, "Failed to load Tmuxifier session '%s'\n", SESSION_NAME);
        return 1;
    }

    return 0;
}

