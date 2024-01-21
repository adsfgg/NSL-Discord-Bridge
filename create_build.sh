#!/usr/bin/env bash

build_dir="build"

function main() {
    # Check for outstanding commits
    test -d .git && test -n "$(git status --porcelain)" && { echo "ERROR: You have outstanding commits, please commit before creating a build"; exit 1; }

    # Create build_dir (removing old directories if needed)
    test -d "$build_dir" && { 
        echo "Removing old build directory";
        rm -rf "$build_dir";
    }
    mkdir "$build_dir"

    # Load config
    local publish_id="$(jq -r .publish_id launchpad/config.json)"
    local name="$(jq -r .name launchpad/config.json)"
    local description="$(jq -r .description launchpad/config.json | jq -r '.[]')"
    local content_dir="content"

    mkdir "$build_dir/$content_dir"
    cp -r src/* "$build_dir/$content_dir/"
    cp "launchpad/$build_target/preview.jpg" "$build_dir/"

    for file in LICENSE README.md; do
        test -f "$file" && cp "$file" "$build_dir/$content_dir/"
    done

    cat  > "$build_dir/workshopitem.vdf" <<EOF
"workshopitem"
{
	"appid"		"4920"
	"publishedfileid"		"$publish_id"
	"contentfolder"		"$(pwd)/$build_dir/content"
	"previewfile"		"$(pwd)/$build_dir/preview.jpg"
	"visibility"		"0"
	"title"		"$name"
	"description"		"$description"
	"changenote"		""
}

EOF

    echo "Build created in $build_dir"
}

main
