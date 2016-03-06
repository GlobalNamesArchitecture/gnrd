FROM ubuntu:14.04.3
MAINTAINER Dmitry Mozzherin
ENV LAST_FULL_REBUILD 2016-02-19

RUN apt-get install -y software-properties-common && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.2 ruby2.2-dev ruby-switch \
    zlib1g-dev liblzma-dev libxml2-dev \
    libxslt-dev supervisor build-essential nodejs
    # apt-get clean && \
    # rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get -y install graphicsmagick poppler-utils poppler-data \
    ghostscript tesseract-ocr pdftk libreoffice libmagic-dev

RUN ruby-switch --set ruby2.2
RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'

RUN gem install bundler && \
    mkdir /app

WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app

COPY . /app

RUN bundle install

CMD ["rackup"]

