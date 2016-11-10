FROM alpine:3.4

RUN apk -U add ca-certificates libssh2 ruby ruby-json && \
    rm -f /var/cache/apk/*

# Setup bundle user and directory
RUN adduser -h /home/bundle -D bundle && \
    mkdir -p /home/bundle && \
    chown -R bundle /home/bundle

# Copy the bundle source to the image
WORKDIR /home/bundle
COPY Gemfile Gemfile.lock /home/bundle/

# Install Git and packages to build libgit2, run Bundler, and uninstall
# packages recover space
RUN apk -U add ruby-bundler ruby-dev make cmake g++ libssh2-dev && \
    su bundle -c 'bundle install --standalone --without="development test"' && \
    apk del ruby-bundler ruby-dev make cmake g++ libssh2-dev && \
    rm -f /var/cache/apk/*

# Copy rest of code
COPY . /home/bundle

# Drop privileges
USER bundle
