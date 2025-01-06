function gph
    # Check if at least one file path is provided
    if test (count $argv) -lt 2
        echo "Usage: gph <file_path1> [<file_path2> ... <file_pathN>] <commit_message>"
        return 1
    end

    # Get the commit message from the last argument
    set commit_message $argv[-1]

    # Remove the commit message from the list of files
    set files $argv[1..(count $argv) - 1]

    # Stage the specified files
    git add $files

    # Commit the changes with the provided message
    git commit -m "$commit_message"

    # Push the changes to the remote repository
    git push

    # Display the current Git status
    git status
end
