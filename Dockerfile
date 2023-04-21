ARG ROCKYLINUX_VERSION=""
FROM rockylinux${ROCKYLINUX_VERSION:+":$ROCKYLINUX_VERSION"}
LABEL maintainer="jakob.malezic@medius.si"

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

# oc & kubectl
ARG OC_RELEASE="4.10.0-0.okd-2022-06-10-131327"
ENV OC_URL=https://github.com/openshift/okd/releases/download/${OC_RELEASE}/openshift-client-linux-${OC_RELEASE}.tar.gz
ADD ${OC_URL} /tmp/oc.tar.gz
RUN cd /tmp \
  && tar xzf oc.tar.gz \
  && mv kubectl oc /usr/local/bin/ \
  && rm *.tar.gz README.md

ONBUILD ARG DNF_REPOS_PATH="dnf.repo"
# This is a conditional copy, at least one file must exist, that's why we use README.md
ONBUILD COPY "README.md" "$DNF_REPOS_PATH"* /
# Check if DNF_REPOS exists and set them as dnf repositories
ONBUILD RUN if [ -f "$DNF_REPOS_PATH" ]; then \
     dnf clean all \
     && rm -rf /var/cache/dnf \
     && rm /etc/yum.repos.d/*.repo \
     && cp "$DNF_REPOS_PATH" /etc/yum.repos.d/dnf.repo \
     && rm "README.md" \
 ; fi