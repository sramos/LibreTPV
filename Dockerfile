FROM ruby:2.7
MAINTAINER Santiago Ramos, sramos@sitiodistinto.net

# Set the base directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN apt-get update -qq && \
    apt-get install -qq -y build-essential nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /railsapp
WORKDIR /railsapp

# Copy dependencies into the container
COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler:1.17.3 && bundle _1.17.3_ install --jobs 20 --retry 5 --without development test

# Set the Rails environment to production
ENV RAILS_ENV production 
ENV RAILS_SERVE_STATIC_FILES true

# Copy the main application into the container
COPY . ./

# Copy database config file
COPY config/database.yml.example ./config/database.yml

# Precompile the Rails assets (with fake connection data)
RUN bundle _1.17.3_ exec rake RAILS_ENV=production DB_HOST=127.0.0.1 DB_NAME=dbname DB_USER=dbuser DB_PASS=dbpass SECRET_KEY_BASE=blahblahblah assets:clobber
RUN bundle _1.17.3_ exec rake RAILS_ENV=production DB_HOST=127.0.0.1 DB_NAME=dbname DB_USER=dbuser DB_PASS=dbpass SECRET_KEY_BASE=blahblahblah assets:precompile

# Expose a volume so that nginx will be able to read in assets in production.
# (now is defined in docker-compose file)
#VOLUME ["/railsapp/public"]

# Start the application with Puma
EXPOSE 3000

# Run migrations and start the application with Puma
ENTRYPOINT ["/railsapp/script/entrypoint"]
CMD bundle _1.17.3_ exec puma -C config/puma.rb
