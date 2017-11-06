FROM ruby:2.4.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /phone-gateway
WORKDIR /phone-gateway
ADD Gemfile /phone-gateway/Gemfile
ADD Gemfile.lock /phone-gateway/Gemfile.lock

RUN bundle install
ADD . /phone-gateway

# Precompile assets
RUN RAILS_ENV=production bundle exec rake assets:precompile --trace

EXPOSE 3000
# Begin

CMD 'scripts/startup.sh'
