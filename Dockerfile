FROM centos:centos7

# Base install up-to-date and epel is required for many packages
RUN yum update -y \
    && yum install -y epel-release \
    && yum clean all

# Software development tools, RPM build requirements
RUN yum install -y auto{conf,make} ctags elfutils gcc{,-c++} gettext intltool libtool make patch{,utils} \
    && yum install -y redhat-rpm-config rpm-{build,sign} spectool \
    && yum install -y libusbx-devel \
    && yum install -y git yum-utils \
    && yum install -y which \
    && yum install -y python3-pip python3-setuptools \
    && yum install -y centos-release-scl \
    && yum install -y devtoolset-7-gcc* \
    # && yum install -y openssh openssh-server openssh-clients \
    && yum clean all

# SSH
# RUN mkdir -p /var/run/sshd \
#     && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
#     && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
#     && /bin/echo 'root:root' |chpasswd

# RUN /bin/sed -i 's/.*session.*required.*pam_loginuid.so.*/session optional pam_loginuid.so/g' /etc/pam.d/sshd
# RUN /bin/echo -e "LANG=\"en_US.UTF-8\"" > /etc/default/local
# EXPOSE 22
# RUN systemctl enable sshd

# Update libtool
RUN cd ~ \
    && yum remove -y libtool \
    && curl -O http://mirrors.ustc.edu.cn/gnu/libtool/libtool-2.4.6.tar.gz \
    && tar zxvf libtool-2.4.6.tar.gz \
    && cd libtool-2.4.6 \
    && ./configure --prefix=/usr \
    && make \
    && make install

RUN mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SRPMS,SPECS}

# Compile SANE Backend.
RUN cd ~ \
    && git clone https://gitlab.com/sane-project/backends.git sane-backends \
    && cd sane-backends \
    && git checkout RELEASE_1_0_27 \
    && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var  --enable-avahi BACKENDS="kodakaio test" \
    && make

# Create a symbolic link for backend develop.
RUN cd /root/sane-backends/backend \
	&& mkdir project \
	&& ln -s /root/sane-backends/backend/project /root/project

# Support Conan package
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir conan

# scl enable devtoolset-7 bash
RUN echo "source /opt/rh/devtoolset-7/enable" >> /etc/bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root
