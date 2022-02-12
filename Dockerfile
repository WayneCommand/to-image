FROM centos:8

LABEL org.opencontainers.image.authors="waynecommand.com"

# ENVs
# so libvips picks up our new libwebp
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig
# so your app can open shared object file of libvips.so.42
ENV LD_LIBRARY_PATH /usr/local/lib

# ARGs
ARG VIPS_VERSION=8.12.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download


WORKDIR /usr/local/to-image
COPY ./ /usr/local/to-image

# general build stuff
RUN yum groupinstall -y "Development Tools" \
    && yum install -y wget tar cmake

# openslide is in epel
RUN yum install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y \
    openslide-devel

# stuff we need to build our own libvips ... this is a pretty basic selection
# of dependencies, you'll want to adjust these
RUN yum install -y \
    # gtk-doc \
    glib2-devel \
    orc-devel \
    expat-devel \
    zlib-devel \
    libjpeg-devel \
    libpng-devel \
    libtiff-devel \
    libexif-devel \
    libgsf-devel \
    libgif-devel

# install libwebp
ARG WEBP_VERSION=1.1.0
ARG WEBP_URL=https://storage.googleapis.com/downloads.webmproject.org/releases/webp
RUN wget ${WEBP_URL}/libwebp-${WEBP_VERSION}.tar.gz \
    && tar xzf libwebp-${WEBP_VERSION}.tar.gz \
    && cd libwebp-${WEBP_VERSION} \
    && ./configure --enable-libwebpmux --enable-libwebpdemux \
    && make V=0 \
    && make install


# add AVIF and HEIC support (libde265 & libheif)
# install libheif
RUN yum install -y https://download1.rpmfusion.org/free/el/updates/7/x86_64/l/libde265-1.0.2-6.el7.x86_64.rpm \
    && yum install -y https://download1.rpmfusion.org/free/el/updates/7/x86_64/x/x265-libs-2.9-3.el7.x86_64.rpm \
    && yum install -y https://download1.rpmfusion.org/free/el/updates/7/x86_64/l/libheif-1.3.2-2.el7.x86_64.rpm \
    && yum install -y https://download1.rpmfusion.org/free/el/updates/7/x86_64/l/libheif-devel-1.3.2-2.el7.x86_64.rpm



RUN wget -O libde265-1.0.8.zip https://github.com/strukturag/libde265/archive/refs/tags/v1.0.8.zip \
 	 && unzip libde265-1.0.8.zip \
 	 && cd libde265-1.0.8 \
     && ./autogen.sh \
     && ./configure \
     && mkdir build \
     && cd build \
     && cmake .. \
     && make \
     && make install

RUN wget -O libheif-1.12.0.zip https://github.com/strukturag/libheif/archive/refs/tags/v1.12.0.zip \
     && unzip libheif-1.12.0.zip \
     && cd libheif-1.12.0 \
     && ./autogen.sh \
     && ./configure \
     && make \
     && make install

# compile libvips
RUN wget ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
  && tar xf vips-${VIPS_VERSION}.tar.gz \
  && cd vips-${VIPS_VERSION} \
  && ./configure \
  && make -j V=0 \
  && make install

RUN pkg-config libheif --print-variables
RUN vips -l | grep _target

# install Node runtime
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
# RUN apt-get install -y nodejs

# install app runtime
# RUN npm install

# EXPOSE 8081
# ENTRYPOINT ["npm", "run", "sharp"]

