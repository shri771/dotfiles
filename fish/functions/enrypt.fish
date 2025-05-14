function en
    # If only one argument, encrypt the file.
    if test (count $argv) -eq 1
        set file $argv[1]
        echo "Encrypting file: $file"
        
        # Determine the output filename:
        if test (string match -r '.*\.txt$' $file)
            set outfile (string replace -r '\.txt$' '.gpg' $file)
        else
            set outfile "$file.gpg"
        end

        echo "Output file: $outfile"
        gpg --symmetric --cipher-algo AES256 -o "$outfile" "$file"

        # Clear cached passphrase
        gpgconf --kill gpg-agent
        gpgconf --launch gpg-agent

    else if test (count $argv) -eq 2
        set encfile $argv[1]
        set dest $argv[2]

        # If second argument is ".", derive output filename by stripping .gpg
        if test "$dest" = "."
            set dest (string replace -r '\.gpg$' '' $encfile)
        end

        echo "Decrypting file: $encfile to $dest"
        gpg -o "$dest" -d "$encfile"

        # Clear cached passphrase
        gpgconf --kill gpg-agent
        gpgconf --launch gpg-agent

    else
        echo "Usage:"
        echo "  en <file>                  # Encrypts <file> and appends .gpg"
        echo "  en <encrypted_file> <dest> # Decrypts <encrypted_file> to <dest>"
        echo "     If <dest> is '.' then the original filename is restored"
        return 1
    end
end
