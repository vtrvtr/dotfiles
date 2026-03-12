#!/bin/bash

if [ $# -eq 0 ]; then
    exit 1
fi

target="$1"

if [ ! -e "$target" ]; then
    exit 1
fi

if [ -d "$target" ]; then
    cd "$target" || exit 1
elif [ -f "$target" ]; then
    cd "$(dirname "$target")" || exit 1
else
    exit 1
fi
