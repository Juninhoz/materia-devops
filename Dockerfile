# Imagem de desenvolvimento (simplificada)
FROM ruby:3.4.5-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libpq-dev libyaml-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bin/rails db:prepare && bin/rails server -b 0.0.0.0"]
