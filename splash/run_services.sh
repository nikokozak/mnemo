#!/usr/bin/env sh

live-server --no-css-inject .
tailwindcss -i ./src/styles.css -o ./dist/styles.css --watch
