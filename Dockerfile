
FROM elixir:1.7.3

ENV MIX_ENV prod
ENV NODE_ENV = "production"

RUN mix local.hex --force \
 && mix archive.install hex phx_new 1.4.0 \
 && apt-get update \ 
 && curl -sL https://deb.nodesource.com/setup_8.x | bash \
 && apt-get install -y apt-utils \
 && apt-get install -y nodejs \
 && apt-get install -y build-essential \
 && apt-get install -y inotify-tools \
 && mix local.hex --force \
 && mix local.rebar --force

COPY . .

RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile
RUN npm install -g sass
RUN cd assets && npm install \ 
&& node node_modules/webpack/bin/webpack.js --mode=production
RUN cd ..

RUN mix phx.digest


CMD mix do ecto.migrate, phx.server