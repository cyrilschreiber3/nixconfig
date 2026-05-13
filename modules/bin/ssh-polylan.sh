#!/usr/bin/env nix-shell
#! nix-shell -i bash -p sshpass

HOST="$1"
HEIGHT="$2"

PASSWD_FILE="$HOME/Documents/Polylan/.switchpasswd"

if [[ "$HOST" == "rack" ]]; then
    HOST="switch-rack-1.polylan-infra.ch"
    PASSWD_FILE="$HOME/Documents/Polylan/.switchrackpasswd"
fi

if [[ "$HOST" =~ ^r([0-9]{1,2})$ ]]; then
    ACCESS_HOST="${BASH_REMATCH[1]}"
    if [[ "$2" = "" ]]; then
        HEIGHT="1"
    fi
    if [[ "${#ACCESS_HOST}" -eq 1 ]]; then
        HOST="access-r$(printf "%02d" "$ACCESS_HOST")-h${HEIGHT}.polylan-infra.ch"
    else
        HOST="access-$HOST-h${HEIGHT}.polylan-infra.ch"
    fi
fi

if [[ "$HOST" =~ ^d([0-9]{1,2})$ ]]; then
    DISTRIB_HOST="${BASH_REMATCH[1]}"
    if [[ "${#DISTRIB_HOST}" -eq 1 ]]; then
        HOST="distrib-r$(printf "%02d" "$DISTRIB_HOST")-h1.polylan-infra.ch"
    else
        HOST="distrib-r$DISTRIB_HOST-h1.polylan-infra.ch"
    fi
fi

if [[ "$HOST" =~ ^[a-z-]+$ ]]; then
    HOST="$HOST.polylan-infra.ch"
fi

echo "Connecting to $HOST..."

sshpass -f "$PASSWD_FILE" ssh admin@$HOST

