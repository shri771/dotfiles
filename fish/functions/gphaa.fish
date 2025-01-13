function gphaa
    # 🌟 Stage all changes
    echo "\033[1;33mStaging all changes...\033[0m"
    git add .

    # 📋 Use the provided commit message or prompt if none is provided
    if test (count $argv) -gt 0
        set commit_message $argv[1]
    else
        echo "\033[1;34mEnter commit message:\033[0m"
        read commit_message
    end

    # ✅ Commit the changes with the provided message
    echo "\033[1;32mCommitting changes...\033[0m"
    git commit -m "$commit_message"

    # 🚀 Push the changes to the remote repository
    echo "\033[1;36mPushing to remote repository...\033[0m"
    git push

    # 🔍 Display the current Git status
    echo "\033[1;35mDisplaying Git status:\033[0m"
    git status
end

