#!/bin/bash

cd /home/docker/actions-runner

# Hàm cleanup sẽ remove runner hiện tại ra khỏi Github self hosted runner
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token $ACTIONS_RUNNER_INPUT_TOKEN
}

./config.sh

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!