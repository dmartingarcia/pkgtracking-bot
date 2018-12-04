FROM elixir:1.7.4

RUN mix local.hex --force
RUN mix local.rebar --force
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN apt-get update && apt-get install postgresql-client -y --no-install-recommends

ENV PATH /root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD . /app
WORKDIR /app

RUN ["mix", "deps.get"]

CMD ["mix"]