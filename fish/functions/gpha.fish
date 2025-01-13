function gpha
    # Stage all changes
    git add .

    # Use the provided commit message or prompt if none is provided
    if test (count $argv) -gt 0
        set commit_message $argv[1]
    else
        echo "Enter commit message:"
        read commit_message
    end

    # Commit the changes with the provided message
    git commit -m "$commit_message"
    
    echo "====================================================="
    # Push the changes to the remote repository
    git push
    echo "====================================================="
    # Display the current Git status
    git status
end
