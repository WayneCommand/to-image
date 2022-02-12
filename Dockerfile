FROM debian:buster

LABEL org.opencontainers.image.authors="waynecommand.com"

# ENVs
ENV LD_LIBRARY_PATH /lib:/usr/lib:/usr/local/lib

# ARGs
ARG VIPS_VERSION=8.12.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download


WORKDIR /usr/local/to-image
COPY ./ /usr/local/to-image

RUN apt-get update \
  && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl wget \
    pkg-config \
    automake

# stuff we need to build our own libvips ... this is a pretty random selection
# of dependencies, you'll want to adjust these
RUN apt-get -y install \
  glib2.0-dev \
  libexif-dev \
  libexpat1-dev \
  libfftw3-dev \
  libgif-dev \
  libgsf-1-dev \
  libimagequant-dev \
  liblcms2-dev \
  libmagickcore-dev \
  libopenjp2-7-dev \
  liborc-0.4-dev \
  libpng-dev \
  librsvg2-dev \
  libtiff5-dev

# add AVIF and HEIC support (libde265 & libheif)
RUN apt-get install -y \
  autoconf \
  libtool \
  gtk-doc-tools \
  gobject-introspection \
  zip unzip

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

# RUN pkg-config libheif --print-variables
RUN vips -l | grep _target

# install Node runtime
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
# RUN apt-get install -y nodejs

# install app runtime
# RUN npm install

# EXPOSE 8081
# ENTRYPOINT ["npm", "run", "sharp"]

