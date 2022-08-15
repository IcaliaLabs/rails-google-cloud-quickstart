# Stage 1: Runtime =============================================================
# The minimal package dependencies required to run the app in the release image:

# Use the official Ruby 3.1.2 Slim Bullseye image as base:
FROM ruby:3.1.2-slim-bullseye AS runtime

# We'll set MALLOC_ARENA_MAX for optimization purposes & prevent memory bloat
# https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html
ENV MALLOC_ARENA_MAX="2"

# We'll install curl for later dependency package installation steps
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libpq5 \
    openssl \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# Update the RubyGems system software, which will update bundler, to avoid the
# "uninitialized constant Gem::Source (NameError)" error when running bundler
# commands:
RUN gem update --system && gem cleanup

# Stage 2: development-base ====================================================
# This stage will contain the minimal dependencies for the rest of the images
# used to build the project:

# Use the "runtime" stage as base:
FROM runtime AS development-base

# Install the app build system dependency packages - we won't remove the apt
# lists from this point onward:

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev

# Receive the developer user's UID and USER:
ARG DEVELOPER_UID=1000
ARG DEVELOPER_USERNAME=you

# Replicate the developer user in the development image:
RUN addgroup --gid ${DEVELOPER_UID} ${DEVELOPER_USERNAME} \
 ;  useradd -r -m -u ${DEVELOPER_UID} --gid ${DEVELOPER_UID} \
    --shell /bin/bash -c "Developer User,,," ${DEVELOPER_USERNAME}

# Ensure that the home directory, the app path and bundler directories are owned
# by the developer user:
# (A workaround to a side effect of setting WORKDIR before creating the user)
RUN userhome=$(eval echo ~${DEVELOPER_USERNAME}) \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} $userhome \
 && mkdir -p /workspaces/rails-google-cloud-quickstart \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} /workspaces/rails-google-cloud-quickstart \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} /usr/local/bundle/*

# Add the app's "bin/" directory to PATH:
ENV PATH=/workspaces/rails-google-cloud-quickstart/bin:$PATH

# Set the app path as the working directory:
WORKDIR /workspaces/rails-google-cloud-quickstart

# Change to the developer user:
USER ${DEVELOPER_USERNAME}

# Configure bundler to retry downloads 3 times:
RUN bundle config set --local retry 3

# Configure bundler to use 2 threads to download, build and install:
RUN bundle config set --local jobs 2

# Stage 3: Testing =============================================================
# In this stage we'll complete an image with the minimal dependencies required
# to run the tests in a continuous integration environment.
FROM development-base AS testing

# Copy the project's Gemfile and Gemfile.lock files:
COPY --chown=${DEVELOPER_USERNAME} Gemfile* /workspaces/rails-google-cloud-quickstart/

# Configure bundler to exclude the gems from the "development" group when
# installing, so we get the leanest Docker image possible to run tests:
RUN bundle config set --local without development

# Install the project gems, excluding the "development" group:
RUN bundle install

# Stage 4: Development =========================================================
# In this stage we'll add the packages, libraries and tools required in our
# day-to-day development process.

# Use the "development-base" stage as base:
FROM development-base AS development

# Change to root user to install the development packages:
USER root

# Install sudo, along with any other tool required at development phase:
RUN apt-get install -y --no-install-recommends \
  # Adding bash autocompletion as git without autocomplete is a pain...
  bash-completion \
  # gpg & gpgconf is used to get Git Commit GPG Signatures working inside the
  # VSCode devcontainer:
  gpg \
  openssh-client \
  # Para esperar a que el servicio de minio (u otros) esté disponible:
  netcat \
  # Cliente de postgres:
  postgresql-client \
  # /proc file system utilities: (watch, ps):
  procps \
  # Vim will be used to edit files when inside the container (git, etc):
  vim \
  # Sudo will be used to install/configure system stuff if needed during dev:
  sudo

# Receive the developer username argument again, as ARGS won't persist between
# stages on non-buildkit builds:
ARG DEVELOPER_USERNAME=you

# Add the developer user to the sudoers list:
RUN echo "${DEVELOPER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | tee "/etc/sudoers.d/${DEVELOPER_USERNAME}"

# Persist the bash history between runs
# - See https://code.visualstudio.com/docs/remote/containers-advanced#_persist-bash-history-between-runs
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/command-history/.bash_history" \
 && mkdir /command-history \
 && touch /command-history/.bash_history \
 && chown -R ${DEVELOPER_USERNAME} /command-history \
 && echo $SNIPPET >> "/home/${DEVELOPER_USERNAME}/.bashrc"

# Create the extensions directories:
RUN mkdir -p \
  /home/${DEVELOPER_USERNAME}/.vscode-server/extensions \
  /home/${DEVELOPER_USERNAME}/.vscode-server-insiders/extensions \
 && chown -R ${DEVELOPER_USERNAME} \
  /home/${DEVELOPER_USERNAME}/.vscode-server \
  /home/${DEVELOPER_USERNAME}/.vscode-server-insiders

# Change back to the developer user:
USER ${DEVELOPER_USERNAME}

# Copy the gems installed in the "testing" stage:
COPY --from=testing /usr/local/bundle /usr/local/bundle
COPY --from=testing /workspaces/rails-google-cloud-quickstart/ /workspaces/rails-google-cloud-quickstart/

# Configure bundler to not exclude any gem group, so we now get all the gems
# specified in the Gemfile:
RUN bundle config unset --local without

# Install the full gem list:
RUN bundle install

# Stage 5: Builder =============================================================
# In this stage we'll add the rest of the code, compile assets, and perform a
# cleanup for the releasable image.
FROM testing AS builder

# Receive the developer username argument again, as ARGS won't persist between
# stages on non-buildkit builds:
ARG DEVELOPER_USERNAME=you

# Receive the developer username argument again, as ARGS won't persist between
# stages on non-buildkit builds:
ARG DEVELOPER_USERNAME=you

# Copy the full contents of the project:
COPY --chown=${DEVELOPER_USERNAME} . /workspaces/rails-google-cloud-quickstart/

# Compile the assets:
RUN RAILS_ENV=production SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece rails assets:precompile

# Configure bundler to exclude the gems from the "development" and "test" groups
# from the installed gemset, which should set them out to remove on cleanup:
RUN bundle config set --local without development test

# Cleanup the gems excluded from the current configuration. We'll copy the
# remaining gemset into the deployable image on the next stage:
RUN bundle clean --force

# Change to root, before performing the final cleanup:
USER root

# Remove unneeded gem cache files (cached *.gem, *.o, *.c):
RUN rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

# Remove project files not used on release image - be aware that files on git
# might still be copied to the image, regardless of rules in the .dockerignore
# file, whenever the image is being built on a Git context.
# - See https://docs.docker.com/engine/reference/commandline/build/#git-repositories
RUN rm -rf \
    .codeclimate.yml \
    .devcontainer \
    .dockerignore \
    .gitattributes \
    .github \
    .gitignore \
    .reek.yml \
    .rspec \
    .rubocop.yml \
    .simplecov \
    .vscode \
    Guardfile \
    bin/rspec \
    bin/checkdb \
    bin/dumpdb \
    bin/restoredb \
    bin/setup \
    bin/dev-entrypoint \
    db/dumps \
    db/seeds/development.rb \
    doc \
    docker-compose.yml \
    Dockerfile \
    log/production.log \
    spec

# Stage 6: Release =============================================================
# In this stage, we build the final, releasable, deployable Docker image, which
# should be smaller than the images generated on previous stages:

# Use the "runtime" stage as base:
FROM runtime AS release

# Copy the remaining installed gems from the "builder" stage:
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy the app code and compiled assets from the "builder" stage to the
# final destination at /workspaces/rails-google-cloud-quickstart:
COPY --from=builder --chown=nobody:nogroup /workspaces/rails-google-cloud-quickstart /workspaces/rails-google-cloud-quickstart

# Set the container user to 'nobody':
USER nobody

# Set the RAILS and PORT default values:
ENV HOME=/workspaces/rails-google-cloud-quickstart \
    RAILS_ENV=production \
    RAILS_FORCE_SSL=yes \
    RAILS_LOG_TO_STDOUT=yes \
    RAILS_SERVE_STATIC_FILES=yes \
    PORT=3000

# Test if the rails app loads:
RUN SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece rails secret > /dev/null

# Set the installed app directory as the working directory:
WORKDIR /workspaces/rails-google-cloud-quickstart

# Set the entrypoint script:
ENTRYPOINT [ "/workspaces/rails-google-cloud-quickstart/bin/entrypoint" ]

# Set the default command:
CMD [ "puma" ]
