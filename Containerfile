ARG FROM
ARG VERSION
FROM ${FROM}

ARG VERSION
ARG KERNEL_VERSION=''
COPY voyager.repo  /etc/yum.repos.d/

RUN if [ -n "$VERSION" ]; then \
        OLD_VERSION=$(grep "^OSTREE_VERSION=" /usr/lib/os-release | cut -d"'" -f2); \
        [ -n "$OLD_VERSION" ] || { echo "Error: Could not extract version from os-release"; exit 1; }; \
        sed -i "s|$OLD_VERSION|$VERSION|g" /usr/lib/os-release; \
    fi; \
    cat /usr/lib/os-release; \
    echo $VERSION; \
    arch="$(uname -m)"; \
    dnf remove kernel-core --assumeyes; \
    kernel_name="kernel-core${KERNEL_VERSION:+-}${KERNEL_VERSION} kernel-modules-extra${KERNEL_VERSION:+-}${KERNEL_VERSION}"; \
    [ "$arch" = 'aarch64' ] && kernel_name="kernel-64k-core${KERNEL_VERSION:+-}${KERNEL_VERSION} kernel-64k-modules-extra${KERNEL_VERSION:+-}${KERNEL_VERSION}"; \
    dnf install --assumeyes --disablerepo=* --enablerepo=voyager $kernel_name; \
    kver=$(ls /usr/lib/modules); \
    DRACUT_NO_XATTR=1 dracut -vf /usr/lib/modules/$kver/initramfs.img "$kver"

LABEL org.opencontainers.image.version=$VERSION