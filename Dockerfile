FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/local/to-image
COPY ./ /usr/local/to-image

RUN apt-get update \
  && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    software-properties-common \
    wget

# add the libheif PPA -- it includes AVIF and HEIC support
RUN add-apt-repository ppa:strukturag/libde265 \
	&& add-apt-repository ppa:strukturag/libheif \
	&& apt-get update


ENV LD_LIBRARY_PATH /usr/local/lib
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig


# stuff we need to build our own libvips ... this is a pretty random selection
# of dependencies, you'll want to adjust these
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


RUN apt-get install -y \
  autoconf \
  libtool \
  gtk-doc-tools \
  gobject-introspection


ARG VIPS_VERSION=8.12.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download

RUN wget ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
	&& tar xzf vips-${VIPS_VERSION}.tar.gz \
	&& cd vips-${VIPS_VERSION} \
	&& ./configure \
	&& make V=0 \
	&& make install \
	&& ldconfig

# install Node runtime
RUN apt-get install -y node npm

# install app runtime
RUN npm install

EXPOSE 8081
ENTRYPOINT ["npm", "run", "sharp"]

