FROM mcr.microsoft.com/dotnet/aspnet:10.0-noble

ARG TOFU_VERSION=1.12.0
ARG TOFU_SHA256=8d7650fd42b6d790f9f747604393ccd0a9035376bccc4f1688b905d7c5bb1137
ARG TERRAFORM_VERSION=1.5.7
ARG TERRAFORM_SHA256=c0ed7bc32ee52ae255af9982c8c88a7a4c610485cf1d55feeb037eab75fa082c

RUN apt-get update && \
    apt-get install -y --no-install-recommends git openssh-client wget curl unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/tofu.zip "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_amd64.zip" && \
    echo "${TOFU_SHA256}  /tmp/tofu.zip" | sha256sum -c - && \
    unzip /tmp/tofu.zip tofu -d /usr/local/bin && \
    chmod +x /usr/local/bin/tofu && \
    rm /tmp/tofu.zip

RUN curl -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    echo "${TERRAFORM_SHA256}  /tmp/terraform.zip" | sha256sum -c - && \
    unzip /tmp/terraform.zip terraform -d /usr/local/bin && \
    chmod +x /usr/local/bin/terraform && \
    rm /tmp/terraform.zip
