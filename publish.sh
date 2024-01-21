#!/usr/bin/env bash

build_dir="build"
steam_acc="$1"
shift

test $steam_acc || { echo "No steam account given"; exit 1; }

test -d "$build_dir" || { echo "No build; run ./create_build.sh"; exit 1; }
test -f "$build_dir/workshopitem.vdf" || { echo "Not a steamcmd build; aborting"; exit 1; }

steamcmd +login "$steam_acc" +workshop_build_item $(pwd)/build/workshopitem.vdf +quit || {
    echo "Workshop publish failed";
    exit 1;
}

rm -rf "$build_dir"

echo
echo "Publish successful"
