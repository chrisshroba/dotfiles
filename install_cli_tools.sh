#!/usr/bin/env bash

# Exit on error.
set -e

brew update

which -s fzf || brew install fzf

INSTALLED_BREW_PACKAGES="$(brew list | sort)"
DESIRED_BREW_PACKAGES="$(sort brew-packages.txt | cut -d',' -f1)"
# comm <(brew list | sort) <(sort brew-packages.txt | cut -d',' -f1)

# Compute the set difference of (desired packages) - (installed packages), and
# display that set to the user to prompt for which to install.
BREW_PACKAGES_TO_POSSIBLY_INSTALL=$(
  comm -13 <(echo "$INSTALLED_BREW_PACKAGES") <(echo "$DESIRED_BREW_PACKAGES")
)

echo "$BREW_PACKAGES_TO_POSSIBLY_INSTALL" | \
  fzf \
    --multi \
    --layout=reverse-list \
    --header='Use Tab to select packages to install, and enter when done.' | \
  xargs brew install
