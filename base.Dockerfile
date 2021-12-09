# This Dockerfile sets up our Rocky8 image, which we then use as a base for
# the deploy.Dockerfile. We do this because this allows us to clear the cache
# of the deploy.Dockerfile without having to rebuild the base every time.

FROM rockylinux/rockylinux as build
SHELL ["/bin/bash", "-c"]
ENV MIX_ENV prod
ENV LANG en_US.UTF-8

# Versions
ENV ERLANG_VERSION latest
ENV ELIXIR_VERSION latest

# System deps
RUN dnf update -y && \
    dnf group install "Development tools" -y && \
    dnf install -y git openssl-devel ncurses-devel && \
    dnf install -y nodejs && \
    dnf clean all

# Install ASDF
RUN git clone https://github.com/asdf-vm/asdf.git /root/.asdf --branch v0.8.1 && \
  echo "source /root/.asdf/asdf.sh" >> /root/.bashrc

# Install Erlang/Elixir
RUN source /root/.bashrc && \
    asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git && \
    asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git && \
    asdf install erlang $ERLANG_VERSION && \
    asdf install elixir $ELIXIR_VERSION && \
    asdf global erlang $ERLANG_VERSION && \
    asdf global elixir $ELIXIR_VERSION

# Install ESBuild
RUN npm install --global esbuild

# Install Build Tools
RUN source /root/.bashrc && \
    mix local.rebar --force && \
    mix local.hex -if-missing --force

#   RUN mkdir /lector
#   COPY server /lector
#   WORKDIR /lector
#
#   RUN source /root/.bashrc && \
#       mix deps.get --only prod && \
#       mix compile && \
#       mix release --overwrite
#
#   # Make a release archive
#   RUN tar -zcf /lector/release.tar.gz -C /lector/_build/prod/rel/lector .
#
#   # Copy out
#   FROM scratch as export
#   COPY --from=build /lector/release.tar.gz .
