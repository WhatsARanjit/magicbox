# Magic Box [![Build Status](https://travis-ci.org/WhatsARanjit/magicbox.svg?branch=master)](https://travis-ci.org/WhatsARanjit/magicbox)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Startup](#startup)
1. [Example UI](#example-ui)
1. [API](#api)
    * [Schema](#schema)
    * [/api/1.0/validate](#api10validate)
    * [/api/1.0/fact](#api10fact)
    * [/api/1.0/function](#api10function)
    * [/api/1.0/resource](#api10resource)
    * [/api/1.0/compile](#api10compile)
    * [/api/1.0/apply](#api10apply)

## Overview

Magic Box API and sample web UI.

## Requirements

* sinatra gem (>= 2.0.0)


## Startup

```shell
# ruby magic.rb
```

## Example UI

An example interface will be available at `http://<IP ADDRESS>/`.  To enable
Magic Box on any box, here is an example:

__text box__
```html
<textarea id='thebox'></textarea>
<button onclick='submit();' >Submit</button>
```

__javascript__

```javascript
function submit() {
  data = '{ \
    "lang": "puppet", \
    "code": "' + escape($('#thebox').val()) + '" \
  }'
  $.ajax({
    type:'post',
    url:'http://<magicbox host>/api/1.0/validate',
    data: data,
    dataType:'json',
    success: function(res) {
      alert('success');
    },
    error: function(xhr) {
      alert('error');
    },
    complete: function(xhr) {
      console.log(JSON.parse(xhr.responseText))
    }
  });
}
```

The `success`, `error`, and `complete` fields can be used to trigger popups
and/or advance you to the next page (or whatever series of events).

## API

### Schema

All data should be `POST`'d as a JSON blob.  Fields that probably contain special
characters like `code` or `value` will need to be escaped.  The response
format for all endpoints is:

```json
{
  "exitcode": "Enum[0, 1]",
  "message": "Array[String]"
}
```

If the code submission is correct, the API will return a `200` response code.
Incorrect code will receive a `400` and server failures a `500`.

### `/api/1.0/validate`

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

### `/api/1.0/fact`

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

### `/api/1.0/function`

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

### `/api/1.0/resource`

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
  },
  "munge": {
    "description": "Attributes to munge with given values.",
    "type": "Optional[Hash[String, Any, 1]]"
  },
  "filter": {
    "description": "Show only the listed attributes.",
    "type": "Optional[Array[String]]"
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

### `/api/1.0/compile`

Query with `puppet resource` and optionally test the command arguments.

__Parameters:__

```json
{
  "code": {
    "description": "The code to parse.",
    "type": "String[1]"
  },
  "item": {
    "description": "The item to spec test for.",
    "type": "String[1]"
  }
}
```

__cURL example__

```shell
# curl -s -X POST -d \
> '{ "code": "class magic_module { notice%28%27hello%20world%27%29 }", "item": "magic_module" }' \
> http://10.32.160.187/api/1.0/compile
=> {"exitcode":0,"message":["passed"]}
```

NOTE: `code` should be supplied as an escaped string.

### `/api/1.0/apply`

Test a puppet apply and examine the output.

__Parameters:__

```json
{
  "code": {
    "description": "The code to parse.",
    "type": "String[1]"
  },
  "check": {
    "description": "Regex to check the output for.",
    "type": "Optional[String[1]]"
  },
  "error": {
    "description": "A friendly error message to display if check fails.",
    "type": "Optional[String[1]]"
  }
}
```

__cURL example__

```shell
curl -s -X POST -d \
> '{ "code": "notice%28%27hello%20world%27%29", "check": "hello%20world" }' \
> http://10.32.160.187/api/1.0/apply
=> {"exitcode":0,"message":["Notice: Scope(Class[main]): hello world","Notice: Compiled catalog for whatsaranjit in environment production in 0.03 seconds","Notice: Applied catalog in 0.02 seconds"]}
# curl -s -X POST -d \
> '{ "code": "notice%28%27hello%20world%27%29", "check": "bye%20world", "error": "Mistake" }' \
> http://10.32.160.187/api/1.0/apply
=> {"exitcode":1,"message":["Mistake","Notice: Scope(Class[main]): hello world","Notice: Compiled catalog for whatsaranjit in environment production in 0.02 seconds","Notice: Applied catalog in 0.02 seconds"]}
```

NOTE: `code`, and `check` should be supplied as an escaped string.
