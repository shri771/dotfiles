# Function to Show Status of systemd se or tim
function syss
    if test (count $argv) -eq 0
        printf "Usage: scs <service-or-timer> [more...]\n" >&2
        return 1
    end

    for unit in $argv
        if not string match -q -- "*.service" "$unit" && not string match -q -- "*.timer" "$unit"
            printf "Error: '%s' is not a valid .service or .timer\n" "$unit" >&2
            continue
        end

        printf "\n--- Status of %s ---\n" "$unit"
        systemctl status "$unit" --no-pager
    end
end
