# Copyright (c) 2020 Gitpod GmbH, 2021-present Andrei Jiroh Halili. All rights reserved.
# Licensed under the GNU Affero General Public License (AGPL).
# See License-AGPL.txt in the project root for license information.

FROM quay.io/gitpodified-workspace-images/full:latest

ENV TRIGGER_REBUILD 16

USER root

# golangci-lint
RUN cd /usr/local && curl -fsSL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s v1.42.0

# gokart
RUN cd /usr/bin && curl -L https://github.com/praetorian-inc/gokart/releases/download/v0.3.0/gokart_0.3.0_linux_x86_64.tar.gz | tar xzv gokart

# leeway
ENV LEEWAY_NESTED_WORKSPACE=true
RUN cd /usr/local/bin && curl -fsSL https://github.com/gitpod-io/leeway/releases/download/v0.2.9/leeway_0.2.9_Linux_x86_64.tar.gz | tar xz

# dazzle
RUN cd /usr/local/bin && curl -fsSL https://github.com/gitpod-io/dazzle/releases/download/v0.1.4/dazzle_0.1.4_Darwin_x86_64.tar.gz| tar xz

# werft CLI
ENV WERFT_K8S_NAMESPACE=werft
ENV WERFT_DIAL_MODE=kubernetes
RUN cd /usr/bin && curl -fsSL https://github.com/csweichel/werft/releases/download/v0.1.4/werft-client-linux-amd64.tar.gz | tar xz && mv werft-client-linux-amd64 werft

# yq - jq for YAML files
# Note: we rely on version 3.x.x in various places, 4.x breaks this!
RUN cd /usr/bin && curl -fsSL https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64 > yq && chmod +x yq

### Protobuf
RUN set -ex \
    && tmpdir=$(mktemp -d) \
    && curl -fsSL -o $tmpdir/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.19.1/protoc-3.19.1-linux-x86_64.zip \
    && mkdir -p /usr/lib/protoc && cd /usr/lib/protoc && unzip $tmpdir/protoc.zip \
    && chmod -R o+r+x /usr/lib/protoc/include \
    && chmod -R +x /usr/lib/protoc/bin \
    && ln -s /usr/lib/protoc/bin/* /usr/bin \
    && rm -rf $tmpdir

### Telepresence ###
RUN curl -fsSL https://packagecloud.io/datawireio/telepresence/gpgkey | apt-key add - \
    # 'cosmic' not supported
    && add-apt-repository -yu "deb https://packagecloud.io/datawireio/telepresence/ubuntu/ bionic main" \
    # 0.95 (current at the time of this commit) is broken
    && install-packages \
    iproute2 \
    iptables \
    net-tools \
    socat \
    telepresence=0.109

### Toxiproxy CLI
RUN curl -fsSL -o /usr/bin/toxiproxy https://github.com/Shopify/toxiproxy/releases/download/v2.1.4/toxiproxy-cli-linux-amd64 \
    && chmod +x /usr/bin/toxiproxy

### libseccomp > 2.5.2
RUN install-packages gperf \
    && cd $(mktemp -d) \
    && curl -fsSL https://github.com/seccomp/libseccomp/releases/download/v2.5.2/libseccomp-2.5.2.tar.gz | tar xz \
    && cd libseccomp-2.5.2 && ./configure && make && make install

USER gitpod

# Fix node version we develop against
ARG GITPOD_NODE_VERSION=16.13.0
RUN bash -c ". .nvm/nvm.sh \
    && nvm install $GITPOD_NODE_VERSION \
    && npm install -g typescript yarn"
ENV PATH=/home/gitpod/.nvm/versions/node/v${GITPOD_NODE_VERSION}/bin:$PATH

# Go
ENV GOFLAGS="-mod=readonly"

## Register leeway autocompletion in bashrc
RUN bash -c "echo . \<\(leeway bash-completion\) >> ~/.bashrc"

# Install Terraform
ARG RELEASE_URL="https://releases.hashicorp.com/terraform/0.15.4/terraform_0.15.4_linux_amd64.zip"
RUN mkdir -p ~/.terraform \
    && cd ~/.terraform \
    && curl -fsSL -o terraform_linux_amd64.zip ${RELEASE_URL} \
    && unzip *.zip \
    && rm -f *.zip \
    && printf "terraform -install-autocomplete 2> /dev/null\n" >>~/.bashrc

# Install GraphViz to help debug terraform scripts
RUN sudo install-packages graphviz

# Install codecov uploader
# https://about.codecov.io/blog/introducing-codecovs-new-uploader
RUN sudo curl -fsSL https://uploader.codecov.io/latest/codecov-linux -o /usr/local/bin/codecov \
    && sudo chmod +x /usr/local/bin/codecov

# Install pre-commit https://pre-commit.com/#install
RUN sudo install-packages shellcheck \
    && sudo pip3 install pre-commit

# Install observability-related binaries
ARG PROM_VERSION="2.30.0"
RUN curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz && \
    tar -xzvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz && \
    sudo mv prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/promtool && \
    rm -rf prometheus-${PROM_VERSION}.linux-amd64/

ARG JSONNET_BUNDLER_VERSION="0.4.0"
RUN curl -L -o jb https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v${JSONNET_BUNDLER_VERSION}/jb-linux-amd64 && \
    chmod +x jb && sudo mv jb /usr/local/bin

ARG JSONNET_VERSION="0.17.0"
RUN curl -LO https://github.com/google/go-jsonnet/releases/download/v${JSONNET_VERSION}/go-jsonnet_${JSONNET_VERSION}_Linux_x86_64.tar.gz && \
    tar -xzvf go-jsonnet_${JSONNET_VERSION}_Linux_x86_64.tar.gz && \
    sudo mv jsonnet /usr/local/bin/jsonnet && \
    sudo mv jsonnetfmt /usr/local/bin/jsonnetfmt

ARG GOJSONTOYAML_VERSION="0.1.0"
RUN curl -LO https://github.com/brancz/gojsontoyaml/releases/download/v${GOJSONTOYAML_VERSION}/gojsontoyaml_${GOJSONTOYAML_VERSION}_linux_amd64.tar.gz && \
    tar -xzvf gojsontoyaml_${GOJSONTOYAML_VERSION}_linux_amd64.tar.gz && \
    sudo mv gojsontoyaml /usr/local/bin/gojsontoyaml
