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

if [[ "$HOST" == "polylan" ]]; then
    HOST="polylansrv0.polylan-infra.ch"
    GESTION_HOST=1
    POLYLAN_GESTION=1
fi

nc -z -w 3 "$HOST" 22 2>&1 >/dev/null || { echo "Error: Cannot reach $HOST on port 22"; exit 1; }

tmux send-keys -t "$TMUX_PANE" " ssh $HOST" Enter
tmux send-keys -t "$TMUX_PANE" "sudo su -" Enter

if [[ "$POLYLAN_GESTION" -eq 1 ]]; then
    tmux send-keys -t "$TMUX_PANE" "pct enter 102" Enter
fi

if [[ "$ENTER_GESTION_SHELL" -eq 1  && "$GESTION_HOST" -eq 1 ]]; then
    tmux send-keys -t "$TMUX_PANE" "activate_venv_gestion && python manage.py shell" Enter
fi