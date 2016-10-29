FROM ubuntu:14.04.4
MAINTAINER Dmitry Mozzherin
ENV LAST_FULL_REBUILD 2016-03-06

RUN apt-get update && \ 
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.2 ruby2.2-dev ruby-switch \
    zlib1g-dev liblzma-dev libxml2-dev libpq-dev git \
    libxslt-dev supervisor build-essential nodejs supervisor && \
    apt-get -y install graphicsmagick poppler-utils poppler-data \
    ghostscript tesseract-ocr pdftk libreoffice libmagic-dev && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get install -qq -y nginx && \
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
    chown -R www-data:www-data /var/lib/nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV RACK_ENV development
ENV RESQUE_WORKERS 1
ENV QUEUE NameFinder
ENV PUMA_WORKERS 2

RUN ruby-switch --set ruby2.2
RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'

RUN gem install bundler && \
    mkdir /app

WORKDIR /app

COPY config/docker/nginx-sites.conf /etc/nginx/sites-enabled/default
COPY Gemfile /app
COPY Gemfile.lock /app
RUN bundle install

COPY . /app

CMD ["/app/exe/docker.sh"]
