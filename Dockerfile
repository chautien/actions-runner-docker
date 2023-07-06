FROM ubuntu:20.04

ARG RUNNER_VERSION="2.305.0"
# Set env để bypass require prompting khi apt install dependency khiến block việc creation image
ARG DEBIAN_FRONTEND=noninteractive

# Cài các essential packages
RUN apt-get update && apt-get upgrade -y && useradd -m docker && \
    apt-get install -y --no-install-recommends \
    curl \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    git \
    openssh-client

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm -rf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Set owner của folder /home/docker qua user docker 
# và thực thi installdependencies để cài các dependencies cần thiết cho Action Runner
RUN chown -R docker:docker /home/docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

# Vì config và run script của Action Runner không cho phép chạy dưới quyền root
# nên ta set user thành docker để khi chạy các command thì sẽ thực thi dưới quyền của docker user
USER docker

# Generate SSH key để pull private repository
RUN ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa \
    && git config --global advice.detachedHead false

ENTRYPOINT ["./entrypoint.sh"]