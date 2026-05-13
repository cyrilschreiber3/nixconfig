#!/usr/bin/env nix-shell
#! nix-shell -i bash -p netcat

set -e

GESTION_HOST=0
ENTER_GESTION_SHELL=0

while getopts "s" opt; do
    case $opt in
        s) ENTER_GESTION_SHELL=1 ;;
    esac
done
shift $((OPTIND - 1))
HOST="$1"

if [[ -z "$TMUX" ]]; then
    echo "Error: This script must be run inside a tmux session."
    exit 1
fi

if [[ "$HOST" =~ ^[0-9]{1,4}$ ]]; then
    if [[ "${#HOST}" -le 3 ]]; then
        HOST="abacus$(printf "%04d" "$HOST")-ch.abacus.abahost.arcanite-infra.ch"
    else
        HOST="abacus$HOST-ch.abacus.abahost.arcanite-infra.ch"
    fi
fi

if [[ "$HOST" =~ ^srv([0-9]{1,3})$ ]]; then
    SRV_HOST="${BASH_REMATCH[1]}"
    if [[ "${#SRV_HOST}" -le 2 ]]; then
        HOST="srv$(printf "%03d" "$SRV_HOST")-ch.arcanite-infra.ch"
    else
        HOST="srv$SRV_HOST-ch.arcanite-infra.ch"
    fi
fi

if [[ "$HOST" == "abahost" ]]; then
    HOST="www01.abahost.arcanite-infra.ch"
fi

if [[ "$HOST" == "abahost-test" ]]; then
    HOST="www01.abahost.test-infra.ch"
fi

if [[ "$HOST" == "abasalary" ]]; then
    HOST="abahost01.abasalary.services-infra.ch"
fi

if [[ "$HOST" == "main" ]]; then
    HOST="gestion01.main.arcanite-infra.ch"
    GESTION_HOST=1
fi

if [[ "$HOST" == "polylan" ]]; then
    HOST="gestion01.gestion.arcanite-infra.ch"
    GESTION_HOST=1
    POLYLAN_GESTION=1
fi

if [[ "$HOST" =~ ^[a-z]{1,10}$ ]]; then
    HOST="controller01.$HOST-infra.ch"
    GESTION_HOST=1
fi

nc -z -w 3 "$HOST" 22 2>&1 >/dev/null || { echo "Error: Cannot reach $HOST on port 22"; exit 1; }

tmux send-keys -t "$TMUX_PANE" " ssh $HOST" Enter
tmux send-keys -t "$TMUX_PANE" "sudo su -" Enter

if [[ "$ENTER_GESTION_SHELL" -eq 1  && "$GESTION_HOST" -eq 1 ]]; then
    tmux send-keys -t "$TMUX_PANE" "activate_venv_gestion && python manage.py shell" Enter
fi