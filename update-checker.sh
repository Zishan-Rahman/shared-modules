#!/usr/bin/env bash

# We take just one file as input, and go over it to update the sources.

if [ ! -f "$1" ]; then
  echo "Input file not found!"
  exit 1
fi

# Read the input file line by line
while IFS= read -r line || [[ -n "$line" ]]; do

  # Trim leading and trailing whitespace from the line
  line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Skip lines starting with #
  if [[ $line == \#* ]]; then
    continue
  fi

  echo "Running data checker on: $line"

 # If we're not running in a container, use the Flatpak. Else, assume we're
 # running in a container and call the data checker directly.
  if [[ ! -f /run/.containerenv && ! -f /.dockerenv ]]; then
   flatpak run --filesystem="$(pwd)" org.flathub.flatpak-external-data-checker $line
  else
   /app/flatpak-external-data-checker --update --never-fork $line
  fi

  if [ $? -eq 0 ]; then
    echo "Checker succeeded!"
  else
    echo "No bueno: exit code $?"
    exit 1
  fi
done < "$1"

