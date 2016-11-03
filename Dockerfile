FROM alpine:3.4

RUN apk -U add ca-certificates libssh2 libssh2-dev ruby ruby-bundler ruby-dev ruby-json

# Setup bundle user and directory
RUN adduser -h /home/bundle -D bundle && \
    mkdir -p /home/bundle && \
    chown -R bundle /home/bundle

# Copy the bundle source to the image
WORKDIR /home/bundle
COPY Gemfile Gemfile.lock /home/bundle/

# Install Git and packages to build libgit2, run Bundler, and uninstall
# packages recover space
RUN apk add git make cmake g++ && \
    su bundle -c 'bundle install --path .bundle' && \
    apk del git make cmake g++ && \
    rm -f /var/cache/apk/*

# Copy rest of code
COPY . /home/bundle

# Drop privileges
USER bundle
