FROM ubuntu:20.04

LABEL org.opencontainers.image.authors="waynecommand.com"

# ENVs
ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH /usr/local/lib
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig

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
RUN apt-get install -y \
	glib-2.0-dev \
	libexpat-dev \
	librsvg2-dev \
	libpng-dev \
	libgif-dev \
	libjpeg-dev \
	libtiff-dev \
	libexif-dev \
	liblcms2-dev \
	liborc-dev \
	libffi-dev \
    x265 \
    libx265-179 \
    libx265-dev

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

RUN wget -O libheif-1.11.0.zip https://github.com/strukturag/libheif/archive/refs/tags/v1.11.0.zip \
    && unzip libheif-1.11.0.zip \
    && cd libheif-1.11.0 \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

# build libvips
RUN wget ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
	&& tar xzf vips-${VIPS_VERSION}.tar.gz \
	&& cd vips-${VIPS_VERSION} \
	&& ./configure \
	&& make V=0 \
	&& make install \
	&& ldconfig

# install Node runtime
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# install app runtime
RUN npm install

EXPOSE 8081
ENTRYPOINT ["npm", "run", "sharp"]

