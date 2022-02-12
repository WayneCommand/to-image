FROM amazonlinux:2

LABEL org.opencontainers.image.authors="waynecommand.com"

# ENVs
# so libvips picks up our new libwebp
ENV VIPSHOME /usr/local/vips
ENV PKG_CONFIG_PATH $VIPSHOME/lib/pkgconfig

# ARGs
ARG VIPS_VERSION=8.12.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download

ARG WEBP_VERSION=1.1.0
ARG WEBP_URL=https://storage.googleapis.com/downloads.webmproject.org/releases/webp

ARG HEIF_VERSION=1.9.1
ARG HEIF_URL=https://github.com/strukturag/libheif/releases/download


WORKDIR /usr/local/to-image
COPY ./ /usr/local/to-image

# general build stuff
RUN yum update -y \
	&& yum groupinstall -y "Development Tools" \
	&& yum install -y wget tar

# libvips needs libwebp 0.5 or later and the one on amazonlinux2 is 0.3.0, so
# we have to build it ourselves

# packages needed by libwebp
RUN yum install -y \
	libjpeg-devel \
	libpng-devel \
	libtiff-devel \
	libgif-devel


# stuff we need to build our own libvips ... this is a pretty basic selection
# of dependencies, you'll want to adjust these
# dzsave needs libgsf
RUN yum install -y \
	libpng-devel \
	poppler-glib-devel \
	glib2-devel \
	libjpeg-devel \
	expat-devel \
	zlib-devel \
	orc-devel \
	lcms2-devel \
	libexif-devel \
	libgsf-devel

# openslide is in epel -- extra packages for enterprise linux
RUN yum install -y \
	https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y \
	openslide-devel

# non-standard stuff we build from source goes here
RUN cd /usr/local/src \
	&& wget ${WEBP_URL}/libwebp-${WEBP_VERSION}.tar.gz \
	&& tar xzf libwebp-${WEBP_VERSION}.tar.gz \
	&& cd libwebp-${WEBP_VERSION} \
	&& ./configure --enable-libwebpmux --enable-libwebpdemux \
		--prefix=$VIPSHOME \
	&& make V=0 \
	&& make install


# install libheif
RUN wget -N ${HEIF_URL}/v${HEIF_VERSION}/libheif-${HEIF_VERSION}.tar.gz \
    && tar xzf libheif-${HEIF_VERSION}.tar.gz \
    && cd libheif-${HEIF_VERSION} \
    && ./autogen.sh \
    && ./configure \
    && make install-strip

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

