# Dockerfile based on manylinux_2_28_x86_64 (AlmaLinux 8, glibc 2.28)
#
# Build:
#   docker build --pull -t buildworker_x86_64 \
#     --build-arg BUILDWORKER_UID=1001 \
#     -f docker/Dockerfile docker
#
# Run interactively:
#   docker run -it --rm -v$(pwd):/build_dir buildworker_x86_64 /bin/bash

FROM quay.io/pypa/manylinux_2_28_x86_64@sha256:fd3ed4ce9cc68ccd5cd7dcad33a37515021429b7aac756c894fced3964931463
WORKDIR /root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN yum -y update
RUN yum install -y \
    wget patch gdb vim perl texinfo \
    zlib-devel glibc-devel \
    libX11-devel libXt-devel libXft-devel tk-devel gdbm-devel \
    xz-devel bzip2-devel \
    openssl3-devel \
    gc-devel \
    ncurses-devel \
    libunwind-devel \
    perl-IPC-Cmd perl-Digest-SHA

RUN yum clean packages

# prefer our libraries in /usr/local/lib (for sqlite, libexpat, libffi built from source)
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# sqlite: yum provides 3.26.0 which is too old; build 3.47.2 from source
ADD install_sqlite.sh /root/install_sqlite.sh
RUN sh /root/install_sqlite.sh 2>&1 | tee /root/install_sqlite.log

# libexpat and libffi are baked into PyPy; use latest versions
ADD install_libexpat.sh /root/install_libexpat.sh
RUN sh /root/install_libexpat.sh 2>&1 | tee /root/install_libexpat.log

ADD install_libffi.sh /root/install_libffi.sh
RUN sh /root/install_libffi.sh 2>&1 | tee /root/install_libffi.log

# get a pypy for translation and running tests
RUN wget -q https://downloads.python.org/pypy/pypy2.7-v7.3.22-linux64.tar.bz2 -O pypy2.7.tar.bz2
RUN echo "c47a4030542cbd34d0cb673a0de1956c94c1ebe6c6b094f2ae6a167c55375f68  pypy2.7.tar.bz2" | sha256sum -c -
RUN tar -C /opt -xj < pypy2.7.tar.bz2 && rm pypy2.7.tar.bz2
RUN ln -s /opt/pypy2.7-v7.3.22-linux64/bin/pypy /usr/local/bin/pypy
RUN pypy -mensurepip
RUN pypy -mpip install --upgrade pip==20.3.4
RUN pypy -mpip install --upgrade setuptools wheel
ADD requirements.txt /root/requirements.txt
RUN pypy -mpip install --require-hashes -r /root/requirements.txt

# Define a user
ARG BUILDWORKER_UID=1001
ARG PARALLEL_BUILDS=4
RUN adduser buildworker --uid=$BUILDWORKER_UID
RUN echo parallel_runs=$PARALLEL_BUILDS > /home/buildworker/machine_cfg.py
ENV PYPY_LOCALBASE=/usr/local
USER buildworker
