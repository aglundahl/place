FROM elixir:1.17.3
RUN apt-get update
RUN apt-get install -y inotify-tools
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mkdir -p /elixir
WORKDIR /elixir
COPY . /elixir
