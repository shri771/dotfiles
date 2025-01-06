function expand_tilde
    # Replace occurrences of '::' with '~/'
    set result (string replace '::' '~/')
    echo -n $result
end
