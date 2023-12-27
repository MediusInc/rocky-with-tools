ARG ROCKYLINUX_VERSION=""
FROM rockylinux${ROCKYLINUX_VERSION:+":$ROCKYLINUX_VERSION"} AS download-oc
# oc & kubectl
ARG OC_RELEASE="4.10.0-0.okd-2022-06-10-131327"
ENV OC_URL=https://github.com/openshift/okd/releases/download/${OC_RELEASE}/openshift-client-linux-${OC_RELEASE}.tar.gz
ADD ${OC_URL} /tmp/oc.tar.gz
RUN cd /tmp \
  && tar xzf oc.tar.gz

ARG ROCKYLINUX_VERSION=""
FROM rockylinux${ROCKYLINUX_VERSION:+":$ROCKYLINUX_VERSION"}
LABEL maintainer="jakob.malezic@medius.si"
# https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file?learn=dependency_version_updates&learnProduct=code-security#docker
LABEL org.opencontainers.image.source="https://github.com/MediusInc/rocky-with-tools"

ARG YQ_RELEASE="v4.25.2"
ARG CRANE_RELEASE="v0.13.0"

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
  && dnf install -y jsonnet \
  && wget -c "https://github.com/mikefarah/yq/releases/download/${YQ_RELEASE}/yq_linux_amd64" -O "/usr/local/bin/yq" \
  && wget -c "https://github.com/google/go-containerregistry/releases/download/${CRANE_RELEASE}/go-containerregistry_Linux_x86_64.tar.gz" -O "go-containerregistry.tar.gz" \
  && tar -zxvf go-containerregistry.tar.gz -C /usr/local/bin/ crane \
  && rm go-containerregistry.tar.gz \
  && chmod +x "/usr/local/bin/yq" \
  && chmod +x "/usr/local/bin/crane" \
  && dnf clean all \
  && dnf autoremove -y \
  && rm -rf /var/cache/dnf

COPY --from=download-oc /tmp/kubectl /tmp/oc /usr/local/bin/
