#!/bin/bash

search_and_install_package() {
    local selection install_cmd repo pkg_name

    # Ensure fzf is installed
    if ! command -v fzf &>/dev/null; then
        printf "Error: fzf is not installed. Please install it first.\n" >&2
        exit 1
    fi

    # Check available package managers once to avoid redundant checks
    local has_zypper has_snap has_flatpak
    has_zypper=$(command -v zypper &>/dev/null && echo 1 || echo 0)
    has_snap=$(command -v snap &>/dev/null && echo 1 || echo 0)
    has_flatpak=$(command -v flatpak &>/dev/null && echo 1 || echo 0)

    # Exit if no package manager is available
    if [[ $has_zypper -eq 0 && $has_snap -eq 0 && $has_flatpak -eq 0 ]]; then
        printf "Error: No supported package managers found (zypper, snap, flatpak).\n" >&2
        exit 1
    fi

    # Live search using fzf
    selection=$(
        fzf --height=40% --border --reverse --prompt="Search package: " \
            --header "Type to search for packages" --preview-window=hidden \
            --bind "change:reload(
                bash -c '
                    q=\"{q}\"
                    [[ -z \"\$q\" ]] && exit 0
                    if [[ $has_zypper -eq 1 ]]; then
                        zypper se -s \"\$q\" 2>/dev/null | awk -F \"|\" '\''NR>2 {gsub(/^[ \\t]+|[ \\t]+$/, \"\", \$2); print \"Zypper: \" \$2 \" - \" \$3}'\'';
                    fi;
                    if [[ $has_snap -eq 1 ]]; then
                        snap find \"\$q\" 2>/dev/null | awk '\''NR>1 {print \"Snap: \" \$1 \" - \" \$2}'\'';
                    fi;
                    if [[ $has_flatpak -eq 1 ]]; then
                        flatpak search \"\$q\" 2>/dev/null | awk -F \"\\t\" '\''NR>1 {print \"Flatpak: \" \$2 \" - \" \$1}'\'';
                    fi
                '
            )"
    )

    # Validate selection
    if [[ -z "$selection" ]]; then
        printf "No package selected.\n"
        exit 0
    fi

    # Extract repository and package name
    read -r repo pkg_name _ <<<"$selection"

    # Determine installation command
    case "$repo" in
        "Zypper:")
            install_cmd="sudo zypper install -y $pkg_name"
            ;;
        "Snap:")
            install_cmd="sudo snap install $pkg_name"
            ;;
        "Flatpak:")
            install_cmd="sudo flatpak install -y $pkg_name"
            ;;
        *)
            printf "Unknown repository selected.\n" >&2
            exit 1
            ;;
    esac

    # Execute installation
    if ! eval "$install_cmd"; then
        printf "Error installing package: %s\n" "$pkg_name" >&2
        exit 1
    fi

    printf "\nInstallation completed for %s %s.\n" "$repo" "$pkg_name"
}

search_and_install_package
