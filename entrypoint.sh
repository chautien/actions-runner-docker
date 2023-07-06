#!/bin/bash

PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_TOKEN
ORGANIZATION=$GITHUB_ORGANIZATION

# Log SSH key của container
LOG_GREEN="\033[32m"
echo -e "${LOG_GREEN}You may want to set SSH key below to your Github account to pull private repo from container"
cat /home/docker/.ssh/id_rsa.pub

ssh -t -t -o StrictHostKeyChecking=accept-new git@github.com
ssh -t -t -o StrictHostKeyChecking=accept-new admin@host01.dn01-server.gotecq.net
ssh -t -t -o StrictHostKeyChecking=accept-new ubuntu@host02.dn01-server.gotecq.net

echo $'Host develop\nHostName host01.dn01-server.gotecq.net\nUser admin' >> ~/.ssh/config
echo $'Host staging\nHostName host02.dn01-server.gotecq.net\nUser ubuntu' >> ~/.ssh/config

cd /home/docker/actions-runner

# Tạo token cho action runner
# https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization
ACTION_RUNNER_TOKEN=$(curl -sX POST -H "Authorization: token ${PERSONAL_ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)

# Hàm cleanup sẽ remove config của runner hiện tại và xóa runner ra khỏi Github self hosted runner
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${ACTION_RUNNER_TOKEN}
}

# Config runner
./config.sh \
--unattended \
--url https://github.com/${ORGANIZATION} \
--token ${ACTION_RUNNER_TOKEN} \
--no-default-labels \
--labels 'fe-runner,self-hosted,Linux,X64'

# Chạy hàm cleanup để xóa runner khi stop container
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Starting runner
./run.sh & wait $!
