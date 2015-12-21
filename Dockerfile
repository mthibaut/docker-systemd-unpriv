FROM centos:7
MAINTAINER Maarten Thibaut "mthibaut@cisco.com"
ENV container docker

RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7 ; rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 ; rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 ; yum install -y http://dl.fedoraproject.org/pub/epel/7/x86\_64/e/epel-release-7-5.noarch.rpm

RUN yum -y update; yum clean all

RUN yum -y swap -- remove systemd-container systemd-container-libs -- install systemd systemd-libs dbus

RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
    systemd-remount-fs.service sys-kernel-config.mount \
    sys-kernel-debug.mount sys-fs-fuse-connections.mount \
    display-manager.service graphical.target systemd-logind.service

ADD dbus.service /etc/systemd/system/dbus.service
RUN systemctl enable dbus.service

#RUN yum -y install passwd; yum clean all
#RUN echo root | passwd --stdin root

#RUN yum -y install openssh-server initscripts; yum clean all
#RUN echo "UseDNS no" >> /etc/ssh/sshd_config
#RUN sed -i 's/UsePrivilegeSeparation sandbox/UsePrivilegeSeparation no/' /etc/ssh/sshd_config

VOLUME ["/sys/fs/cgroup"]
VOLUME ["/run"]

RUN yum install -y deltarpm ; \
    yum --disableplugin=fastestmirror install -y \
    bash setup gcc gcc-c++ findutils glibc-devel gmp-devel libdb-devel \
    sudo hostname make \
    libffi-devel openssl-devel readline-devel sqlite-devel libyaml-devel \
    openssh openssh-server openssh-clients shadow-utils \
    git-core rpm-build rubygems ruby-devel \
    python-devel python-setuptools  python-pip python-virtualenv
RUN gem install -n /usr/bin fpm --no-rdoc --no-ri
# Disable cache dir to ensure docker cache is used
RUN pip install --no-cache-dir pyyaml pycrypto jinja2
# Host configuration
RUN ssh-keygen -A

CMD  ["/usr/lib/systemd/systemd"]
