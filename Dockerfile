ARG ROCKYLINUX_VERSION=""
FROM rockylinux/rockylinux${ROCKYLINUX_VERSION:+":$ROCKYLINUX_VERSION"}
LABEL maintainer="jakob.malezic@medius.si"

ARG YQ_RELEASE="v4.25.2"
ARG ENVSUBST_RELEASE="v1.2.0"

RUN dnf upgrade -y \
  && dnf install -y \
    findutils \
    jq \
    git \
    wget \
    unzip \
    xz \
    epel-release \
  && dnf install -y jsonnet \
  && wget -c "https://github.com/mikefarah/yq/releases/download/${YQ_RELEASE}/yq_linux_amd64" -O "/usr/local/bin/yq" \
  && wget -c "https://github.com/a8m/envsubst/releases/download/${ENVSUBST_RELEASE}/envsubst-Linux-x86_64" -O "/usr/local/bin/envsubst" \
  && chmod +x "/usr/local/bin/yq" \
  && chmod +x "/usr/local/bin/envsubst" \
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
