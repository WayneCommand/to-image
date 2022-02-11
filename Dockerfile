FROM ubuntu:21.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/local/to-image
COPY ./ /usr/local/to-image

RUN apt-get update \
  && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl

# add the libheif PPA -- it includes AVIF and HEIC support
RUN add-apt-repository ppa:strukturag/libde265 \
	&& add-apt-repository ppa:strukturag/libheif \
	&& apt-get update


ENV LD_LIBRARY_PATH /usr/local/lib
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig

# install the system brotli
RUN apt-get install -y \
  libbrotli-dev

RUN git clone --depth 1 --recursive https://gitlab.com/wg1/jpeg-xl.git \
  && cd jpeg-xl \
  && mkdir build \
  && cd build \
  && cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DBUILD_TESTING=0 \
    -DJPEGXL_ENABLE_FUZZERS=0 \
    -DJPEGXL_ENABLE_MANPAGES=0 \
    -DJPEGXL_ENABLE_BENCHMARK=0 \
    -DJPEGXL_ENABLE_EXAMPLES=0 \
    -DJPEGXL_ENABLE_SKCMS=0 \
    .. \
  && make -j$(nproc) \
  && make install


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


ARG VIPS_VERSION=8.11.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download

RUN wget ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
	&& tar xzf vips-${VIPS_VERSION}.tar.gz \
	&& cd vips-${VIPS_VERSION} \
	&& ./configure \
	&& make V=0 \
	&& make install \
	&& ldconfig

# install Node LTS runtime
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update && apt-get install -y nodejs

RUN npm install

EXPOSE 8081
ENTRYPOINT ["npm", "run", "sharp"]

