# Rocky Linux with tools

This is an alternative container image for [Rocky Linux](https://rockylinux.org/),
extended with some basic utility tools.

Installed tools:
- wget
- git
- unzip
- xz
- jq
- yq
- gettext
- jsonnet
- kubectl
- oc
- crane
- which
- git-lfs
- helm
- helm-secrets
- xmlstarlet
- podman
- just
- rsync
- httpie
- telepresence

This container image is generated automatically every night at 3AM and can be pulled from [Dockerhub]( 
https://hub.docker.com/r/mediussi/rocky-with-tools/tags):

```bash
docker pull mediussi/rocky-with-tools
```
