FROM mcr.microsoft.com/devcontainers/ruby:2.7
WORKDIR /myapp
COPY ./src/Gemfile /myapp/Gemfile
COPY ./src/Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY .devcontainer/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]