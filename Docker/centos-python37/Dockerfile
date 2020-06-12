
FROM centos

RUN yum -y update

RUN yum -y install gcc openssl-devel bzip2-devel libffi-devel wget make

WORKDIR cd /usr/src

RUN wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz && tar xzf Python-3.7.4.tgz


WORKDIR Python-3.7.4

RUN ./configure --enable-optimizations
RUN make altinstall

RUN ln -s /usr/local/bin/python3.7 /usr/local/bin/python3 && \
    ln -s /usr/local/bin/pip3.7 /usr/local/bin/pip3 && \
    ln -s /usr/local/bin/pyvenv-3.7 /usr/local/bin/pyvenv && \
    ln -s /usr/local/bin/easy_install-3.7 /usr/local/bin/easy_install 

RUN pip3 install pip --upgrade
RUN pip3 install gnureadline
RUN yum -y install git

RUN yum clean all
