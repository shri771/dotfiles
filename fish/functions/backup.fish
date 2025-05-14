function ba -d "Copy files to a backup directory"
    # Define backup directory
    set -l backup_dir "$HOME/backup"
    
    # Ensure at least one argument is provided
    if test (count $argv) -eq 0
        echo "Usage: ba <file1> [file2 ...]"
        return 1
    end

    # Create backup directory if it doesn't exist
    if not test -d $backup_dir
        mkdir -p $backup_dir
        or begin
            echo "Error: Could not create $backup_dir" >&2
            return 1
        end
    end

    # Process each file
    for file in $argv
        if test -f $file
            cp -a $file $backup_dir/
            echo "Backup of $file completed to $backup_dir"
        else
            echo "Error: $file does not exist or is not a file" >&2
        end
    end
endnd
