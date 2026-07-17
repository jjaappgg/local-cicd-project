FROM jenkins/jenkins:lts-jdk21

USER root

ARG TERRAFORM_VERSION=1.14.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl git gnupg lsb-release python3 unzip \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin \
    && curl -fsSLo /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_$(dpkg --print-architecture | sed 's/amd64/amd64/;s/arm64/arm64/').zip" \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && terraform version \
    && docker --version \
    && rm -rf /var/lib/apt/lists/* /tmp/terraform.zip

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER root
