#!/bin/bash
BUILD_PID=0

terminate_build() {
    if [ $BUILD_PID -ne 0 ]; then
        kill $BUILD_PID 2> /dev/null
        wait $BUILD_PID 2> /dev/null
    fi
}

start_build() {
    clear
    zig build run &
    BUILD_PID=$!
}

trap terminate_build INT

start_build

fswatch -o ./src | while read -r event; do
    terminate_build
    start_build
done

