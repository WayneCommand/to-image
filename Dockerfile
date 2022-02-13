# it works, but heic is broken.
FROM ubuntu:bionic

LABEL org.opencontainers.image.authors="waynecommand.com"

# ENVs
# so libvips picks up our new libwebp
ENV VIPSHOME /usr/local/vips
ENV PKG_CONFIG_PATH $VIPSHOME/lib/pkgconfig

# ARGs
ARG VIPS_VERSION=8.11.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download

ARG WEBP_VERSION=1.1.0
ARG WEBP_URL=https://storage.googleapis.com/downloads.webmproject.org/releases/webp

ARG HEIF_VERSION=1.9.1
ARG HEIF_URL=https://github.com/strukturag/libheif/releases/download


WORKDIR /usr/local/to-image
COPY ./ /usr/local/to-image

RUN apt-get update
RUN apt-get install -y \
	software-properties-common \
	build-essential \
	unzip \
	wget

# add the libheif PPA -- it includes AVIF and HEIC support
RUN add-apt-repository ppa:strukturag/libde265 \
	&& add-apt-repository ppa:strukturag/libheif \
	&& apt-get update

# stuff we need to build our own libvips ... this is a pretty random selection
# of dependencies, you'll want to adjust these
# the libheif-dev in ubuntu 18.04 is too old, you'd need to build that from
# source
RUN apt-get install -y \
	glib-2.0-dev \
	libheif-dev \
	libexpat-dev \
	librsvg2-dev \
	libpng-dev \
	libgif-dev \
	libjpeg-dev \
	libtiff-dev \
	libexif-dev \
	liblcms2-dev \
	liborc-dev \
	libffi-dev

RUN wget ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
	&& tar xzf vips-${VIPS_VERSION}.tar.gz \
	&& cd vips-${VIPS_VERSION} \
	&& ./configure \
	&& make V=0 \
	&& make install \
	&& ldconfig


## install check.
RUN pkg-config libheif --print-variables
RUN vips -l | grep _target

# install Node runtime
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# install app runtime
RUN npm install

EXPOSE 8081
ENTRYPOINT ["npm", "run", "sharp"]

