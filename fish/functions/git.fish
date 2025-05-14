# Pushes git with a arugument
function gph
    # Ensure at least two arguments are provided
    if test (count $argv) -lt 2
        echo "Usage: gph <file1> [file2 ...] <commit message>"
        return 1
    end

    # Extract the commit message (last argument) and files (all but last)
    set commit_message $argv[-1]
    set files $argv[1..-2]

    # Add files, commit, push, and display status
    git add $files
    if not git commit -m "$commit_message"
        echo "Failed to commit changes" >&2
        return 1
    end

    echo "============================================================"
    if not git push
        echo "Failed to push changes" >&2
        return 1
    end
    echo "============================================================"
    git status
end
