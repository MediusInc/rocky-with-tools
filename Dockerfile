FROM rockylinux/rockylinux
MAINTAINER jakob.malezic@medius.si

ARG YQ_RELEASE="4.25.2"
RUN yum update -y \
  && yum install -y \
    findutils \
    jq \
    git \
    wget \
    unzip \
    xz \
    epel-release \
  && yum install -y jsonnet \
  && wget -c "https://github.com/mikefarah/yq/releases/download/v${YQ_RELEASE}/yq_linux_amd64" -O "/usr/local/bin/yq" \
  && chmod +x "/usr/local/bin/yq" \
  && yum clean all \
  && yum autoremove -y \
  && rm -rf /var/cache/yum

# oc & kubectl
ARG OC_RELEASE="4.10.0-0.okd-2022-06-10-131327"
ENV OC_URL=https://github.com/openshift/okd/releases/download/${OC_RELEASE}/openshift-client-linux-${OC_RELEASE}.tar.gz
RUN cd \
  && curl -L -sS -O "$OC_URL" \
  && TAR_FILE=$(find . -name "openshift-client*") \
  && tar xzf ${TAR_FILE} \
  && mv kubectl oc /usr/local/bin/ \
  && rm *.tar.gz README.md
