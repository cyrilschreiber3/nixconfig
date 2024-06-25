# A rebuild script that commits on a successfull build

# get parameters
force=false
while getopts "f" flag; do
    case $flag in
        f) force=true;;
    esac
done

set -e

# cd in the config dir
pushd ~/nixconfig

# return if no changes exept if forced
if git diff --quiet "*.nix" && test "$force" != "true"; then
    echo "No changes detected, exiting..."
    popd
    exit 0
fi

# Autoformat nix file
alejandra . &>/dev/null \
|| (alejandra .; echo "Formating failed" && exit 1)

# Show the changes
git diff -U0 "*.nix"

# Stage everything so that nixos-rebuild can see new files
git add .

echo "NixOS Rebuilding..."

# Rebuild and output simplified errors
sudo nixos-rebuild switch --flake ./#default &>nixos-switch.log || (
git restore --staged ./**/*.nix;
cat nixos-switch.log | grep --color error && exit 1
)

# Create commit message
genMetadata=$(nixos-rebuild list-generations | grep current)
read generation current buildDate buildTime flakeVersion kernelVersion configRev specialisation <<< "$genMetadata"
commitMessage="Host: $(hostname), Generation: $generation, NixOS version: $flakeVersion, Kernel: $kernelVersion"

# Commit all changes with generation metadata
echo "Commiting change..."
git commit -am "$commitMessage"

echo "Pushing to remote..."
git push

# Go back to the initial dir
popd


# Send notification
notify-send -e "NixOS Rebuild successful!" --icon=software-update-available