FROM ruby:2.2.7

RUN  mkdir -p /opt/magicbox
COPY . /opt/magicbox

RUN gem install bundler --no-ri --no-rdoc

WORKDIR /opt/magicbox
RUN bundle install

EXPOSE 8443

CMD ["bundle", "exec", "ruby", "magic.rb"]
