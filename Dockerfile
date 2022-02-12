FROM ubuntu:20.04

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
    curl wget


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
	libffi-dev

# add AVIF and HEIC support (libde265 & libheif)


RUN apt-get install -y \
  autoconf \
  libtool \
  gtk-doc-tools \
  gobject-introspection



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

