ARG ROCKYLINUX_VERSION=""

ARG OC_RELEASE="4.15.0-0.okd-2024-02-10-035534"
ARG HELM_RELEASE="v3.13.3"
ARG HELM_SECRETS_RELEASE="v4.6.2"
ARG SOPS_RELEASE="v3.9.3"
ARG YQ_RELEASE="v4.25.2"
ARG CRANE_RELEASE="v0.13.0"
ARG JUST_RELEASE="1.39.0"
ARG TELEPRESENCE_RELEASE="v2.22.3"

#     _    ____  __  __
#    / \  |  _ \|  \/  |
#   / _ \ | |_) | |\/| |
#  / ___ \|  _ <| |  | |
# /_/   \_\_| \_\_|  |_|

FROM --platform=arm64 rockylinux/rockylinux${ROCKYLINUX_VERSION:+":$ROCKYLINUX_VERSION"} AS base-arm64
ARG OC_RELEASE
ARG HELM_RELEASE
ARG SOPS_RELEASE
ARG YQ_RELEASE
ARG CRANE_RELEASE
ARG JUST_RELEASE
ARG TELEPRESENCE_RELEASE

ENV HELM_URL=https://get.helm.sh/helm-${HELM_RELEASE}-linux-arm64.tar.gz
ENV OC_URL=https://github.com/openshift/okd/releases/download/${OC_RELEASE}/openshift-client-linux-arm64-${OC_RELEASE}.tar.gz
ENV YQ_URL=https://github.com/mikefarah/yq/releases/download/${YQ_RELEASE}/yq_linux_arm64.tar.gz
ENV CRANE_URL=https://github.com/google/go-containerregistry/releases/download/${CRANE_RELEASE}/go-containerregistry_Linux_arm64.tar.gz
ENV SOPS_URL=https://github.com/getsops/sops/releases/download/${SOPS_RELEASE}/sops-${SOPS_RELEASE}.linux.arm64
ENV JUST_URL=https://github.com/casey/just/releases/download/${JUST_RELEASE}/just-${JUST_RELEASE}-aarch64-apple-darwin.tar.gz
ENV TELEPRESENCE_URL=https://github.com/telepresenceio/telepresence/releases/download/${TELEPRESENCE_RELEASE}/telepresence-linux-arm64

#     _    __  __ ____
#    / \  |  \/  |  _ \
#   / _ \ | |\/| | | | |
#  / ___ \| |  | | |_| |
# /_/   \_\_|  |_|____/

FROM --platform=amd64 rockylinux/rockylinux${ROCKYLINUX_VERSION:+":$ROCKYLINUX_VERSION"} AS base-amd64
ARG OC_RELEASE
ARG HELM_RELEASE
ARG SOPS_RELEASE
ARG YQ_RELEASE
ARG CRANE_RELEASE
ARG JUST_RELEASE
ARG TELEPRESENCE_RELEASE

ENV HELM_URL=https://get.helm.sh/helm-${HELM_RELEASE}-linux-amd64.tar.gz
ENV OC_URL=https://github.com/openshift/okd/releases/download/${OC_RELEASE}/openshift-client-linux-${OC_RELEASE}.tar.gz
ENV YQ_URL=https://github.com/mikefarah/yq/releases/download/${YQ_RELEASE}/yq_linux_amd64.tar.gz
ENV CRANE_URL=https://github.com/google/go-containerregistry/releases/download/${CRANE_RELEASE}/go-containerregistry_Linux_x86_64.tar.gz
ENV SOPS_URL=https://github.com/getsops/sops/releases/download/${SOPS_RELEASE}/sops-${SOPS_RELEASE}.linux.amd64
ENV JUST_URL=https://github.com/casey/just/releases/download/${JUST_RELEASE}/just-${JUST_RELEASE}-x86_64-unknown-linux-musl.tar.gz
ENV TELEPRESENCE_URL=https://github.com/telepresenceio/telepresence/releases/download/${TELEPRESENCE_RELEASE}/telepresence-linux-amd64

#  ____   _____        ___   _ _     ___    _    ____
# |  _ \ / _ \ \      / / \ | | |   / _ \  / \  |  _ \
# | | | | | | \ \ /\ / /|  \| | |  | | | |/ _ \ | | | |
# | |_| | |_| |\ V  V / | |\  | |__| |_| / ___ \| |_| |
# |____/ \___/  \_/\_/  |_| \_|_____\___/_/   \_\____/

FROM base-${TARGETARCH} AS download-oc
# oc & kubectl
ADD ${OC_URL} /tmp/oc.tar.gz
RUN tar xzf /tmp/oc.tar.gz -C /tmp

FROM base-${TARGETARCH} AS download-helm
# helm
ADD ${HELM_URL} /tmp/helm.tar.gz
# helm is wrapped in 1 folder inside the tar => use --strip-components=1
RUN tar xzf /tmp/helm.tar.gz -C /tmp --strip-components=1

FROM base-${TARGETARCH} AS download-yq
# yq
ADD ${YQ_URL} /tmp/yq.tar.gz
RUN tar xzf /tmp/yq.tar.gz -C /tmp

FROM base-${TARGETARCH} AS download-crane
# crane
ADD ${CRANE_URL} /tmp/crane.tar.gz
RUN tar xzf /tmp/crane.tar.gz -C /tmp

FROM base-${TARGETARCH} AS download-sops
# sops
ADD ${SOPS_URL} /tmp/sops
RUN chmod +x /tmp/sops

FROM base-${TARGETARCH} AS download-just
# just
ADD ${JUST_URL} /tmp/just.tar.gz
RUN tar xzf /tmp/just.tar.gz -C /tmp

FROM base-${TARGETARCH} AS download-telepresence
# telepresence
ADD ${TELEPRESENCE_URL} /tmp/telepresence
RUN chmod +x /tmp/telepresence

#  _____ ___ _   _    _    _
# |  ___|_ _| \ | |  / \  | |
# | |_   | ||  \| | / _ \ | |
# |  _|  | || |\  |/ ___ \| |___
# |_|   |___|_| \_/_/   \_\_____|

FROM base-${TARGETARCH}
ARG TARGETARCH
LABEL maintainer="jakob.malezic@medius.si"
# https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file?learn=dependency_version_updates&learnProduct=code-security#docker
LABEL org.opencontainers.image.source="https://github.com/MediusInc/rocky-with-tools"

COPY --from=download-oc /tmp/kubectl /tmp/oc /usr/local/bin/
COPY --from=download-helm /tmp/helm /usr/local/bin/
COPY --from=download-yq /tmp/yq_linux_${TARGETARCH} /usr/local/bin/yq
COPY --from=download-crane /tmp/crane /usr/local/bin/
COPY --from=download-sops /tmp/sops /usr/local/bin/
COPY --from=download-just /tmp/just /usr/local/bin/
COPY --from=download-telepresence /tmp/telepresence /usr/local/bin/telepresence

# Remarks: jsonnet must be in its own install command as epel-release HAS to be installed beforehand
# `--enablerepo=crb` - CodeReady Builder (CRB) repository is needed for httpie
ARG ROCKYLINUX_VERSION
RUN dnf upgrade -y \
  && dnf install -y \
    findutils \
    jq \
    git \
    wget \
    unzip \
    xz \
    gettext \
    epel-release \
    which \
    git-lfs \
    xmlstarlet \
    podman \
    rsync \
  && if [[ $ROCKYLINUX_VERSION == 9.* ]]; then dnf install --enablerepo=crb -y httpie; elif [[ $ROCKYLINUX_VERSION == 10.* ]]; then dnf install -y pip && pip install httpie; else dnf install -y httpie; fi;  \
  && dnf install -y jsonnet \
  && dnf clean all \
  && dnf autoremove -y \
  && rm -rf /var/cache/dnf \
  && helm plugin install https://github.com/jkroepke/helm-secrets --version "$HELM_SECRETS_RELEASE"
