function gph
    # Check if at least two arguments are provided
    if test (count $argv) -lt 2
        echo "Usage: gph <file1> [file2 ...] <commit message>"
        return 1
    end

    # Calculate the index of the last argument
    set last_index (math (count $argv))

    # Extract the commit message (last argument)
    set commit_message $argv[$last_index]

    # Extract the list of files (all but the last argument)
    set files $argv[1..(math $last_index - 1)]

    # Add the specified files
    git add $files

    # Commit with the provided message
    git commit -m "$commit_message"
    echo "============================================================"

    # Push the changes
    git push
    echo "============================================================"

    # Show the git status
    git status
end
