#!/bin/bash
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export PKCS11_MODULES
