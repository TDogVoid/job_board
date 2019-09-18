
FROM elixir:1.7.3

RUN mix local.hex --force \
 && mix archive.install hex phx_new 1.4.0 \
 && apt-get update \ 
 && curl -sL https://deb.nodesource.com/setup_8.x | bash \
 && apt-get install -y apt-utils \
 && apt-get install -y nodejs \
 && apt-get install -y build-essential \
 && apt-get install -y inotify-tools \
 && mix local.rebar --force

RUN npm install -g sass
RUN npm install -g brunch

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

CMD ["mix", "phx.server"]