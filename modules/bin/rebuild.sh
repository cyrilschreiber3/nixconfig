#! /usr/bin/env nix-shell
#! nix-shell -i bash -p git alejandra ondir libnotify nix-output-monitor
# A rebuild script that commits on a successfull build

# get parameters
force=false
update=false
while getopts "fu" flag; do
    case $flag in
    f) force=true ;;
    u) update=true ;;
    esac
done

set -e

function handleExit() {
    notify-send -e "NixOS Rebuild failed!" --icon=dialog-error

    git restore --staged ./**/*.nix

    popd >/dev/null
    exit 1
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# cd in the config dir
pushd ~/nixconfig >/dev/null

# Update the flake if needed
if test "$update" == "true"; then
    echo "Updating flake..."
    nix-channel --update
    sudo nix flake update
fi

# return if no changes exept if forced
if git diff --quiet "*.nix" && test "$force" != "true"; then
    echo "No changes detected, exiting..."
    popd >/dev/null
    exit 0
fi

# Autoformat nix file
alejandra . &>/dev/null ||
    (
        alejandra .
        echo "Formating failed" && exit 1
    )

# Handle exit signals
trap handleExit SIGINT

# Stage everything so that nixos-rebuild can see new files
git add .

echo "NixOS Rebuilding..."
rebuildStart=$(date +%s)

currentGeneration=$(nixos-rebuild list-generations | grep current | cut -d ' ' -f 1)

# Clear log file
echo "" >nixos-switch.log

# Rebuild and output simplified errors
sudo nixos-rebuild switch --flake ./#default --accept-flake-config --log-format internal-json -v 2>&1 |& tee nixos-switch.log |& nom --json || (
    echo "Rebuild failed..."
    handleExit
)

# Check if the generation has changed
newGeneration=$(nixos-rebuild list-generations | grep current | cut -d ' ' -f 1)
if [ "$currentGeneration" == "$newGeneration" ]; then
    echo "No new generation created, exiting..."
    handleExit
fi

# Create commit message
genMetadata=$(nixos-rebuild list-generations | grep current)
read generation current buildDate buildTime flakeVersion kernelVersion configRev specialisation <<<"$genMetadata"
commitMessage="Host: $(hostname), Generation: $generation, NixOS version: $flakeVersion, Kernel: $kernelVersion"

# Commit all changes with generation metadata
printf "Commiting change..."
git commit -am "$commitMessage" --quiet
echo " Done"
git log -1 --pretty='[%h] %s'

printf "Pushing to remote..."
push_output=$(git push 2>&1)
echo " Done"
echo "$push_output" | tail -n 3

# Delete older generations
printf "Deleting old generations..." |& tee nixos-gc.log
maxGenCount=20
(nix-env --delete-generations +$maxGenCount && sudo nix-env --delete-generations +$maxGenCount -p /nix/var/nix/profiles/system >nixos-gc.log 2>&1) &
pid=!$
spinner $pid
wait $pid
echo " Done"

printf "Deleting unused store references..." |& tee nixos-gc.log
(sudo nix-collect-garbage >nixos-gc.log 2>&1) &
pid=!$
spinner $pid
wait $pid
echo " Done"

# Go back to the initial dir
popd >/dev/null

# Send notification
notify-send -e "NixOS Rebuild successful!" --icon=software-update-available

# Print time taken
rebuildEnd=$(date +%s)
rebuildTime=$((rebuildEnd - rebuildStart))
echo "Rebuild took $rebuildTime seconds in total."
