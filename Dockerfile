FROM ruby:2.4.1

RUN  mkdir -p /opt/magicbox
COPY . /opt/magicbox

RUN gem install bundler --no-ri --no-rdoc

WORKDIR /opt/magicbox
RUN bundle install

EXPOSE 8443

HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -s -I -f http://localhost:8443/?healthcheck=1 || exit 1

CMD ["bundle", "exec", "ruby", "magic.rb"]
