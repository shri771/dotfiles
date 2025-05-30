#!/bin/sh
 for i in 344; do  # Replace with actual snapshot numbers
      sudo /usr/lib/snapper/grub2-entry-helper --snapshot $i
      done
