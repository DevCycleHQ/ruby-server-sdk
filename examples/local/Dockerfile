FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /app

COPY Gemfile .
COPY . /app

RUN bundle install

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]