# Puppeteer [![Build Status](https://travis-ci.org/WhatsARanjit/puppet-puppeteer.svg?branch=master)](https://travis-ci.org/WhatsARanjit/puppet-puppeteer)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Startup](#startup)
1. [API](#api)

## Overview

Submit code for validation over HTTP.

## Requirements

* sinatra gem (>= 2.0.0)


## Startup

```shell
# ruby magic.rb
```

An example interface will be available at `http://<IP ADDRESS>:4567/`.

## API

### `/scripts/validate.rb`

__Parameters:__

```json
{
  "lang": {
    "description": "Which language to test parsing.",
    "type": "Enum[puppet, ruby, json, yaml]"
  },
  "code": {
    "description": "The code to parse.",
    "type": "String[1]"
  }
}
```

__cURL example__

```shell
# curl -X POST -d '{ "lang": "puppet", "code": "notice%28%24ipaddress%29" }' 'http://10.32.160.187:4567/scripts/validate.rb'
=> {"exitcode":0,"message":[]}
# curl -X POST -d '{ "lang": "puppet", "code": "notice%28%24ipaddress%29%29" }' 'http://10.32.160.187:4567/scripts/validate.rb'
=> {"exitcode":1,"message":["Error: Could not parse for environment production: Syntax error at ')' at /tmp/pp20171031-30174-15v4dm8:1:19"]}
```

NOTE: `code` should be supplied as a URL-encoded string
