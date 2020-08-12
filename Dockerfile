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
    && yum clean all

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
	&& ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var  --enable-avahi BACKENDS="kodakaio test" \
	&& make

# Create a symbolic link for backend develop.
RUN cd /root/sane-backends/backend \
	&& mkdir project \
	&& ln -s /root/sane-backends/backend/project /root/project

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

CMD ["bash"]
