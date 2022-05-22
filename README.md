# Magic Box [![Build Status](https://app.travis-ci.com/WhatsARanjit/magicbox.svg?branch=master)](https://app.travis-ci.com/WhatsARanjit/magicbox)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Startup](#startup)
1. [Example UI](#example-ui)
1. [API](#api)
    * [Schema](#schema)
    * [/api/1.0/tfc_activity](#api10tfc_activity)
    * [/api/1.0/json2hcl](#api10json2hcl)
    * [/api/1.0/resourcecounter](#api10resourcecounter)
    * [/api/1.0/validate](#api10validate)
    * [/api/1.0/fact](#api10fact)
    * [/api/1.0/function](#api10function)
    * [/api/1.0/resource](#api10resource)
    * [/api/1.0/compile](#api10compile)
    * [/api/1.0/apply](#api10apply)
    * [/api/1.0/facts](#api10facts)

## Overview

Magic Box API and sample web UI.

Docker Usage
```shell
docker run --rm -d -p 8443:8443 WhatsARanjit/magicbox:latest
```
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

### `/api/1.0/tfc_activity`

Count the number of plans/applies/policy checks/etc per workspace or organization 
for a given period of time.

__Parameters:__

```json
{
  "tfe_server": {
    "description": "DNS name of Terraform Enterprise server",
    "type": "String[1]"
  },
  "tfe_token": {
    "description": "Terraform Enterprise token to inspect organizations and workspace states",
    "type": "String[1]"
  },
  "workspace_id": {
    "description": "Single workspace ID or a comma-separated list of IDs to query",
    "type": "String[1]"
  },
  "filter": {
    "description": "Single metric filter or a comma-separated list of metric filters to query",
    "type": "Variant[Enum['applied-at', 'apply-queued-at', 'applying-at', 'confirmed-at', 'cost-estimated-at', 'cost-estimating-at', 'discarded-at', 'errored-at', 'plan-queueable-at', 'plan-queued-at', 'planned-and-finished-at', 'planned-at', 'planning-at', 'policy-checked-at', 'policy-soft-failed-at'], String[1]]"
  },
  "start_date": {
    "description": "The day/time to start counting runs"
    "type": "DateTime"
  },
  "end_date": {
    "description": "The day/time to end counting runs"
    "type": "DateTime"
  }
}
```

NOTE: `start_date` and `end_date` should follow Ruby's [Date::parse](https://ruby-doc.org/stdlib-2.4.1/libdoc/date/rdoc/Date.html#method-c-parse) format

__cURL example__

```shell
# curl -s -X POST -d \
"{ \"tfe_token\": \"$TFE_TOKEN\", \"workspace_id\": \"ws-12345abcd\", \"start_date\": \"2020-02-18\", \"end_date\": \"2020-03-07\", \"filter\": \"planned-at,applied-at\"}" \
https://whatsaranjit.herokuapp.com/api/1.0/tfc_activity
{"exitcode":0,"message":[{"workspaces":{"ws-12345abcd\":{"planned-at":24,"applied-at":11}}}]}
```

### `/api/1.0/json2hcl`

Convert code between HCL and JSON.

__Parameters:__

```json
{
  "lang": {
    "description": "Which language to convert to.",
    "type": "Enum[hcl, json]"
  },
  "code": {
    "description": "The code to convert.",
    "type": "String[1]"
  }
}
```

__cURL example__

```shell
# curl -s -X POST -d \
> '{ "lang": "json", "code": "resource%20%22mytype%22%20%22myname%22%20%7B%0A%20%20foo%20%3D%20%22bar%22%0A%7D" }' \
> https://whatsaranjit.herokuapp.com/api/1.0/json2hcl
=> {"exitcode":0,"message":["{","  \"resource\": {","    \"mytype\": {","      \"myname\": {","        \"foo\": \"bar\"","      }","    }","  }","}"]}
```

NOTE: `code` should be supplied as an escape string

### `/api/1.0/resourcecounter`

Count the number of a resource type in a Terraform Enterprise organization.

__Parameters:__

```json
{
  "tfe_server": {
    "description": "DNS name of Terraform Enterprise server",
    "type": "String[1]"
  },
  "tfe_token": {
    "description": "Terraform Enterprise token to inspect organizations and workspace states",
    "type": "String[1]"
  },
  "workspace_id": {
    "description": "Single workspace ID or a comma-separated list of IDs to query",
    "type": "String[1]"
  },
  "filter": {
    "description": "Single metric filter or a comma-separated list of metric filters to query",
    "type": "Variant[Enum['applied-at', 'apply-queued-at', 'applying-at', 'confirmed-at', 'cost-estimated-at', 'cost-estimating-at', 'discarded-at', 'errored-at', 'plan-queueable-at', 'plan-queued-at', 'planned-and-finished-at', 'planned-at', 'planning-at', 'policy-checked-at', 'policy-soft-failed-at'], String[1]"
  },
  "start_date": {
    "description": "The day/time to start counting runs"
    "type": "DateTime"
  },
  "end_date": {
    "description": "The day/time to end counting runs"
    "type": "DateTime"
  }
}
```

NOTE: `start_date` and `end_date` should follow Ruby's [Date::parse](https://ruby-doc.org/stdlib-2.4.1/libdoc/date/rdoc/Date.html#method-c-parse) format

__cURL example__

```shell
# curl -s -X POST -d \
> "{\"tfe_token\": \"$TFE_TOKEN\", \"tfe_org\": \"WhatsARanjit\", \"type\": \"null_resource\"}" \
> https://whatsaranjit.herokuapp.com/api/1.0/resourcecounter
=> {"exitcode":0,"message":["[{\"ws-zyYr86jQMdnKegtI\":{\"name\":\"WhatsARanjit-test-prod\",\"state_url\":\"https://archivist.terraform.io/v1/object/state_guid\",\"targets\":[\"null_resource.test.0\",\"null_resource.test.1\",\"null_resource.test.2\"],\"count\":3}},{\"ws-4muVUIMemmrOmXU3\":{\"name\":\"WhatsARanjit-test-dev\",\"state_url\":\"null\",\"count\":0}},{\"timestamp\":\"2019-04-30 23:00:15 -0400\",\"organization\":\"WhatsARanjit\",\"type\":\"null_resource\",\"total\":3}]"]}
```

### `/api/1.0/validate`

Submit Puppet code for syntax validation.

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
> https://whatsaranjit.herokuapp.com/api/1.0/validate
=> {"exitcode":0,"message":[]}

# curl -s -X POST -d \
> '{ "lang": "puppet", "code": "notice%28%24ipaddress%29%29" }' \
> https://whatsaranjit.herokuapp.com/api/1.0/validate
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
> https://whatsaranjit.herokuapp.com/api/1.0/fact
=> {"exitcode":0,"message":["expected: true","actual: true"]}

# curl -s -X POST -d \
> '{ "fact": "ranjit", "value": true, "code": "Facter.add%28%27ranjit%27%29%20do%0A%20%20setcode%20do%0A%20%20%20%20false%0A%20%20end%0Aend" }' \
> https://whatsaranjit.herokuapp.com/api/1.0/fact
=> {"exitcode":0,"message":["expected: true","actual: false"]}
```

NOTE: `code` and `value` should be supplied as an escaped string.

### `/api/1.0/function`

Test that a Puppet function produces an expected value or error.

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
> https://whatsaranjit.herokuapp.com/api/1.0/function
=> {"exitcode":0,"message":["passed"]}

# curl -s -X POST -d \
> '{ "function": "sum", "args": "10%2C25", "value": 35, "code": "Puppet%3A%3AFunctions.create_function%28%3Asum%29%20do%0A%20%20dispatch%20%3Asum%20do%0A%20%20%20%20required_param%20%27Integer%27%2C%20%3Aa%0A%20%20%20%20required_param%20%27Integer%27%2C%20%3Ab%0A%20%20end%0A%0A%20%20def%20sum%28a%2Cb%29%0A%20%20%20%20a-b%0A%20%20end%0Aend" }' \
> https://whatsaranjit.herokuapp.com/api/1.0/function
=> {"exitcode":1,"message":["expected sum(10, 25) to have returned 35 instead of -15"]}

# curl -s -X POST -d \
> '{ "function": "number", "args": "%27this%20is%20a%20String%27", "code": "Puppet%3A%3AFunctions.create_function%28%3Anumber%29%20do%0A%20%20dispatch%20%3Anumber%20do%0A%20%20%20%20required_param%20%27Any%27%2C%20%3Aa%0A%20%20end%0A%0A%20%20def%20number%28a%29%0A%20%20%20%20a%0A%20%20end%0Aend", "spec": "raise_error", "value": "ArgumentError%2C/expects%20an%20Integer%20value/" }' \
> https://whatsaranjit.herokuapp.com/api/1.0/function
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
> https://whatsaranjit.herokuapp.com/api/1.0/resource
=> {"exitcode":0,"message":["host { 'localhost':\n  ensure       => 'present',\n  comment      => '',\n  host_aliases => ['localhost.localdomain', 'localhost4', 'localhost4.localdomain4', 'whatsaranjit'],\n  ip           => '127.0.0.1',\n  loglevel     => 'notice',\n  provider     => 'parsed',\n  target       => '/etc/hosts',\n}"]}

# curl -s -X POST -d \
> '{ "code": "puppet%20resource%20user%20ranjit", "type": "package", "title": "puppet" }' \
> https://whatsaranjit.herokuapp.com/api/1.0/resource
=> {"exitcode":1,"message":["Supplied type 'user' does not match 'package'","Supplied title 'ranjit' does not match 'puppet'"]}
```

NOTE: `code`, and `title` should be supplied as an escaped string.

### `/api/1.0/compile`

Test that a set of Puppet code compiles.

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
> https://whatsaranjit.herokuapp.com/api/1.0/compile
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
> https://whatsaranjit.herokuapp.com/api/1.0/apply
=> {"exitcode":0,"message":["Notice: Scope(Class[main]): hello world","Notice: Compiled catalog for whatsaranjit in environment production in 0.03 seconds","Notice: Applied catalog in 0.02 seconds"]}
# curl -s -X POST -d \
> '{ "code": "notice%28%27hello%20world%27%29", "check": "bye%20world", "error": "Mistake" }' \
> https://whatsaranjit.herokuapp.com/api/1.0/apply
=> {"exitcode":1,"message":["Mistake","Notice: Scope(Class[main]): hello world","Notice: Compiled catalog for whatsaranjit in environment production in 0.02 seconds","Notice: Applied catalog in 0.02 seconds"]}
```

NOTE: `code`, and `check` should be supplied as an escaped string.

### `/api/1.0/facts`

Return a single fact or the complete fact set.

__Parameters:__

```json
{
  "fact": {
    "description": "The fact value to retrieve.",
    "type": "Optional[String[1]]"
  }
}
```

__cURL example__

```shell
# curl -s -X POST -d \
> '{ "fact": "kernel" }' \
> https://whatsaranjit.herokuapp.com/api/1.0/facts
{"exitcode":0,"message":["Linux"]}
```
