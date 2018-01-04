FROM ruby:2.4.1

ARG port
ENV port=${port:-8443}
ARG protocol
ENV protocol=${protocol:-http}

RUN  mkdir -p /opt/magicbox
COPY . /opt/magicbox

RUN gem install bundler --without development --no-ri --no-rdoc

WORKDIR /opt/magicbox
RUN bundle install --without development

EXPOSE $port

HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -sk -I -f ${protocol}://localhost:${port}/?healthcheck=1 || exit 1

CMD ["bundle", "exec", "ruby", "magic.rb"]
