FROM centos:centos7

# Overwrite CentOS-Base.repo with Vault repositories
RUN tee /etc/yum.repos.d/CentOS-Base.repo <<EOF
[base]
name=CentOS-7 - Base
baseurl=http://vault.centos.org/7.9.2009/os/\$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-7 - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/\$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-7 - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/\$basearch/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

# Clean YUM cache and regenerate
RUN yum clean all && yum makecache

# Install centos-release-scl to enable SCL repositories
RUN yum install -y centos-release-scl

# Disable all existing SCL repositories that use mirrorlist.centos.org
RUN yum-config-manager --disable centos-sclo-rh centos-sclo-sclo

# Overwrite the SCL repositories to point to the Vault
RUN tee /etc/yum.repos.d/CentOS-SCLo-scl.repo <<EOF
[centos-sclo-rh]
name=CentOS-7 - SCLo rh from Vault
baseurl=http://vault.centos.org/7.9.2009/sclo/x86_64/rh/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centos-sclo-sclo]
name=CentOS-7 - SCLo sclo from Vault
baseurl=http://vault.centos.org/7.9.2009/sclo/x86_64/sclo/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

# Clean up duplicate repo info and get keys
RUN rm -f /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    curl -O https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-SCLo && \
    rpm --import RPM-GPG-KEY-CentOS-SIG-SCLo

# Clean YUM cache again and install devtoolset-7 and git
RUN yum clean all && yum makecache && \
    yum install -y devtoolset-11 git

# Enable devtoolset-7 globally
RUN echo 'source /opt/rh/devtoolset-11/enable' >> /etc/profile && \
    echo 'source /opt/rh/devtoolset-11/enable' >> /etc/bashrc

ENV CMAKE_VERSION=3.31.5

RUN curl -OL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    chmod +x cmake-${CMAKE_VERSION}-linux-x86_64.sh && \
    ./cmake-${CMAKE_VERSION}-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm -f cmake-${CMAKE_VERSION}-linux-x86_64.sh

# Default to an interactive shell
CMD ["/bin/bash"]

