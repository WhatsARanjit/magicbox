# Puppeteer [![Build Status](https://travis-ci.org/WhatsARanjit/puppet-puppeteer.svg?branch=master)](https://travis-ci.org/WhatsARanjit/puppet-puppeteer)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Startup](#startup)
1. [API](#api)
  1. [/1.0/validate](#10validate)
  1. [/1.0/fact](#10fact)
  1. [/1.0/function](#10function)
  1. [/1.0/resource](#10resource)

## Overview

Magic Box API and sample web UI.

## Requirements

* sinatra gem (>= 2.0.0)


## Startup

```shell
# ruby magic.rb
```

An example interface will be available at `http://<IP ADDRESS>:4567/`.

## API

### `/1.0/validate`

Submit code for syntax validation.

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
# curl -s -X POST -d \
> '{ "lang": "puppet", "code": "notice%28%24ipaddress%29" }' \
> http://10.32.160.187:4567/api/1.0/validate
=> {"exitcode":0,"message":[]}

# curl -s -X POST -d \
> '{ "lang": "puppet", "code": "notice%28%24ipaddress%29%29" }' \
> http://10.32.160.187:4567/api/1.0/validate
=> {"exitcode":1,"message":["Error: Could not parse for environment production: Syntax error at ')' at /tmp/pp20171103-10522-1bocvzq:1:19"]}
```

NOTE: `code` should be supplied as an escape string

### `/1.0/fact`

Test that Facter code produces an expected value.

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
# curl -s -X POST -d \
> '{ "fact": "ranjit", "value": true, "code": "Facter.add%28%27ranjit%27%29%20do%0A%20%20setcode%20do%0A%20%20%20%20true%0A%20%20end%0Aend" }' \
> http://10.32.160.187:4567/api/1.0/fact
=> {"exitcode":0,"message":["expected: true","actual: true"]}

# curl -s -X POST -d \
> '{ "fact": "ranjit", "value": true, "code": "Facter.add%28%27ranjit%27%29%20do%0A%20%20setcode%20do%0A%20%20%20%20false%0A%20%20end%0Aend" }' \
> http://10.32.160.187:4567/api/1.0/fact
=> {"exitcode":0,"message":["expected: true","actual: false"]}
```

NOTE: `code` and `value` should be supplied as an escaped string.

### `/1.0/function`

Test that a function produces an expected value or error.

__Parameters:__

```json
{
  "code": {
    "description": "The code to parse.",
    "type": "String[1]"
  },
  "function": {
    "description": "The name of the function to check.",
    "type": "String[1]"
  },
  "value": {
    "description": "The expected value of the function.",
    "type": "Any"
  },
  "args": {
    "description": "Arguments to be passed into function.",
    "type": "Any"
  },
  "spec": {
    "description": "Pre-configured spec test template to use.",
    "type": "Optional[Enum[raise_error]]"
  }
}
```

__cURL example__

```shell
# curl -s -X POST -d \
> '{ "function": "sum", "args": "10%2C25", "value": 35, "code": "Puppet%3A%3AFunctions.create_function%28%3Asum%29%20do%0A%20%20dispatch%20%3Asum%20do%0A%20%20%20%20required_param%20%27Integer%27%2C%20%3Aa%0A%20%20%20%20required_param%20%27Integer%27%2C%20%3Ab%0A%20%20end%0A%0A%20%20def%20sum%28a%2Cb%29%0A%20%20%20%20a+b%0A%20%20end%0Aend" }' \
> http://10.32.160.187:4567/api/1.0/function
=> {"exitcode":0,"message":["passed"]}

# curl -s -X POST -d \
> '{ "function": "sum", "args": "10%2C25", "value": 35, "code": "Puppet%3A%3AFunctions.create_function%28%3Asum%29%20do%0A%20%20dispatch%20%3Asum%20do%0A%20%20%20%20required_param%20%27Integer%27%2C%20%3Aa%0A%20%20%20%20required_param%20%27Integer%27%2C%20%3Ab%0A%20%20end%0A%0A%20%20def%20sum%28a%2Cb%29%0A%20%20%20%20a-b%0A%20%20end%0Aend" }' \
> http://10.32.160.187:4567/api/1.0/function
=> {"exitcode":1,"message":["expected sum(10, 25) to have returned 35 instead of -15"]}

# curl -s -X POST -d \
> '{ "function": "number", "args": "%27this%20is%20a%20String%27", "code": "Puppet%3A%3AFunctions.create_function%28%3Anumber%29%20do%0A%20%20dispatch%20%3Anumber%20do%0A%20%20%20%20required_param%20%27Any%27%2C%20%3Aa%0A%20%20end%0A%0A%20%20def%20number%28a%29%0A%20%20%20%20a%0A%20%20end%0Aend", "spec": "raise_error", "value": "ArgumentError%2C/expects%20an%20Integer%20value/" }' \
> http://10.32.160.187:4567/api/1.0/function
=> {"exitcode":1,"message":["expected number(\"this is a String\") to have raised ArgumentError matching /expects an Integer value/ instead of returning \"this is a String\""]}
```

NOTE: `code`, `args`, and `value` should be supplied as an escaped string.

### `/1.0/resource`

Query with `puppet resource` and optionally test the command arguments.

__Parameters:__

```json
{
  "code": {
    "description": "The code to parse.",
    "type": "String[1]"
  },
  "type": {
    "description": "The resource type expected to be queried.",
    "type": "Optional[String[1]]"
  },
  "title": {
    "description": "The resource title expected to be queried.",
    "type": "Optional[String[1]]"
  }
}
```

__cURL example__

```shell
# curl -s -X POST -d \
> '{ "code": "puppet%20resource%20host" }' \
> http://10.32.160.187:4567/api/1.0/resource
=> {"exitcode":0,"message":["host { 'localhost':\n  ensure       => 'present',\n  comment      => '',\n  host_aliases => ['localhost.localdomain', 'localhost4', 'localhost4.localdomain4', 'whatsaranjit'],\n  ip           => '127.0.0.1',\n  loglevel     => 'notice',\n  provider     => 'parsed',\n  target       => '/etc/hosts',\n}"]}

# curl -s -X POST -d \
> '{ "code": "puppet%20resource%20user%20ranjit", "type": "package", "title": "puppet" }' \
> http://10.32.160.187:4567/api/1.0/resource
=> {"exitcode":1,"message":["Supplied type 'user' does not match 'package'","Supplied title 'ranjit' does not match 'puppet'"]}
```

NOTE: `code`, and `title` should be supplied as an escaped string.
