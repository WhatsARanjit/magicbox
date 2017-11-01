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

### `/1.0/validate`

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
# curl -X POST -d '{ "lang": "puppet", "code": "notice%28%24ipaddress%29" }' 'http://10.32.160.187:4567/api/1.0/validate'
=> {"exitcode":0,"message":[]}
# curl -X POST -d '{ "lang": "puppet", "code": "notice%28%24ipaddress%29%29" }' 'http://10.32.160.187:4567/api/.0/validate'
=> {"exitcode":1,"message":["Error: Could not parse for environment production: Syntax error at ')' at /tmp/pp20171031-30174-15v4dm8:1:19"]}
```

NOTE: `code` should be supplied as a URL-encoded string

### `/1.0/fact`

__Parameters:__

```json
{
  "code": {
    "description": "The code to parse.",
    "type": "String[1]"
  },
  "fact": {
    "description": "The name of the fact to check.",
    "type": "String[1]"
  },
  "value": {
    "description": "The expected value of the fact.",
    "type": "Any"
  }
}
```

__cURL example__

```shell
# curl -X POST -d '{ "fact": %0A%20%20%20%20true%0D%0A%20%20end%0D%0Aend" }' 'http://10.32.160.187:4567/api/1.0/fact'de%20do%0D
=> {"exitcode":0,"message":["expected: true","actual: true"]}
# curl -X POST -d '{ "fact": %0A%20%20%20%20false%0D%0A%20%20end%0D%0Aend" }' 'http://10.32.160.187:4567/api/1.0/fact'de%20do%0D
=> {"exitcode":1,"message":["expected: false","actual: true"]}
```

NOTE: `code` should be supplied as a URL-encoded string
