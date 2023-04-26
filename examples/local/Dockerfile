FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /app

COPY Gemfile .
RUN bundle install

COPY . /app


EXPOSE 3000

CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb"]