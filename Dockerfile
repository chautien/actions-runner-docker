FROM ubuntu:20.04

ARG RUNNER_VERSION="2.305.0"
# Set env để bypass require prompting khi apt install dependency khiến block việc creation image
ARG DEBIAN_FRONTEND=noninteractive

# Cài các essential packages
RUN apt update && apt upgrade -y \
    apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip 

RUN useradd -m docker && cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Set owner của folder /home/docker qua user docker 
# và thực thi installdependencies để cài các dependencies cần thiết cho Action Runner
RUN chown -R docker /home/docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh

# Vì config và run script của Action Runner không cho phép chạy dưới quyền admin
# nên ta set user thành docker để khi chạy các command thì sẽ thực thi dưới quyền của docker user
USER docker

ENTRYPOINT ["./start.sh"]