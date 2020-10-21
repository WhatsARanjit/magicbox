var workspaces_cache = '';
var ws_attributes = '';

function fetch_workspaces() {
  check_array = [
    {
      "check": "[a-zA-z0-9\.\-/]",
      "box": "#source_tfe_org"
    },
    {
      "check": "[a-zA-z0-9\.\-/]",
      "box": "#source_tfe_token"
    }
  ];
  if (!formValidation(check_array, 'Form field validation failed!')) {
    return;
  }
  tfe_workingMessage('Retrieving workspaces...');
  data = '{ \
    "tfe_server": "' + $('#source_tfe_server').val() + '", \
    "tfe_token": "' + $('#source_tfe_token').val() + '", \
    "endpoint": "organizations/' + $('#source_tfe_org').val() + '/workspaces" \
  }'
  console.log(data.replace(/ {2,}/g, ' '));
  $.ajax({
    type: 'post',
    url: '/api/1.0/tfe_call',
    data: data,
    dataType:'json',
    success: function(xhr) {
      console.log(xhr)
      $('#workspaces')
        .find('option')
        .remove()
        .end()
      workspaces_cache = xhr['message'];
      $.each(xhr['message'], function(index, value){
        console.log(value);
        $('#workspaces')
          .append($("<option></option>")
            .attr('value', value['attributes']['name'])
            .attr('workspace_id', value['id'])
            .text(value['attributes']['name']));
      });
      $(document).ready(function() {
        $('#form-select-workspaces').slideDown();
      });
    },
    error: function(xhr) {
      resultWorking();
      resultError(xhr);
      resultComplete(xhr);
    },
    complete: function(xhr) {
      workingDone();
    }
  });
}

function fetch_variables() {
  tfe_workingMessage('Retrieving variables...');
  args = encodeURIComponent('filter[organization][name]=' + $('#source_tfe_org').val() + '&filter[workspace][name]=' + $('#workspaces').val());
  data = '{ \
    "tfe_server": "' + $('#source_tfe_server').val() + '", \
    "tfe_token": "' + $('#source_tfe_token').val() + '", \
    "endpoint": "vars?' + args + '" \
  }'
  console.log(data.replace(/ {2,}/g, ' '));
  $.ajax({
    type: 'post',
    url: '/api/1.0/tfe_call',
    data: data,
    dataType:'json',
    success: function(xhr) {
      console.log(xhr)
      $('#form-set-tf-variables')
        .find('div')
        .remove()
        .end()
      $('#form-set-env-variables')
        .find('div')
        .remove()
        .end()
      $.each(xhr['message'], function(index, v){
        console.log(v);
        // Grab variable attributes
        name      = v['attributes']['key'];
        value     = v['attributes']['value'];
        sensitive = v['attributes']['sensitive'];
        hcl       = v['attributes']['hcl'];
        category  = v['attributes']['category'];

        variable_html = "\
          <div class='form-group' var=" + name + " sensitive=" + sensitive + " hcl=" + hcl + " category=" + category + ">\
            <label for='var-" + name + "' class='col-md-2 control-label'>" + name + ":</label>\
            <div class='col-md-4'>\
              <input type='" + (sensitive ? 'password' : 'text') + "' id='var-" + name + "' class='form-control' value='" + (value == null ? '' : value) + "' placeholder='" + (sensitive ? 'sensitive' : '') + "'>\
            </div>\
            <div class='checkbox-inline'>\
              <label class='col-md-1 control-label'>\
                <input type='checkbox' id='sensitive-" + name + "' "+ (sensitive ? 'checked' : '') + ">\
                Sensitive\
              </label>\
            </div>\
            <div class='checkbox-inline'>\
              <label class='col-md-1 control-label'>\
                <input type='checkbox' id='hcl-" + name + "' " + (hcl ? 'checked' : '') + ">\
                HCL\
              </label>\
            </div>\
            <div class='checkbox-inline'>\
              <label class='col-md-1 control-label'>\
                <input type='checkbox' id='ignore-" + name + "'>\
                Ignore\
              </label>\
            </div>\
          </div>\
        ";
        type = category == 'terraform' ? '#form-set-tf-variables' : '#form-set-env-variables';
        $(type)
          .append($(variable_html));
      });
      ws_attributes = $.grep(workspaces_cache, function(ws) { return ws['id'] == $('#workspaces option:selected').attr('workspace_id') })[0]['attributes'];
      delete ws_attributes.name;
      delete ws_attributes.operations;
      console.log(ws_attributes);
      $(document).ready(function() {
        $('#target_tfe_org').val($('#source_tfe_org').val());
        $('#target_tfe_token').val($('#source_tfe_token').val());
        $('#target_workspace').val($('#workspaces').val());
        $('#ws-attributes').val(JSON.stringify(ws_attributes, null, 2));
        $('#form-set-tf-variables').slideDown();
        $('#form-set-env-variables').slideDown();
        $('#form-set-advanced').slideDown();
        $('#create-workspace').slideDown();

        // Toggle sensitive inputs to password type
        $('input[type=checkbox][id^=sensitive').click(function() {
          raw_id = $(this).attr('id');
          id = raw_id.replace(/sensitive-/, '');
          mask = ( $(this).is(':checked') ? 'password' : 'text' );
          $('input#var-' + id).attr('type', mask);
        })
      });
    },
    error: function(xhr) {
      resultWorking();
      resultError(xhr);
      resultComplete(xhr);
    },
    complete: function(xhr) {
      workingDone();
    }
  });
}

function test() {
  tfe_workingMessage('Creating workspace...');

  attributes         = JSON.parse($('#ws-attributes').val());
  attributes['name'] = $('#target_workspace').val();

  data = '{ \
    "tfe_server": "' + $('#target_tfe_server').val() + '", \
    "tfe_token": "' + $('#target_tfe_token').val() + '", \
    "endpoint": "organizations/' + $('#target_tfe_org').val() + '/workspaces", \
    "method" : "POST", \
    "e_codes": [201], \
    "keys": { \
      "data": { \
        "attributes": ' + JSON.stringify(attributes) + ', \
        "type": "workspaces" \
      } \
    } \
  }'
  console.log(data.replace(/ {2,}/g, ' '));
  $.ajax({
    type: 'post',
    timeout: 30000,
    url: '/api/1.0/tfe_call',
    data: data,
    dataType:'json',
    success: function(xhr) {
      console.log(xhr);
      aggregate_msg = xhr;
      workspace_id = aggregate_msg['message']['id'];
      create_variables(workspace_id);
      workingDone();
      ret = JSON.stringify(aggregate_msg['message']).replace(/"/g, '&quot;');
      console.log(ret);
      fakeSuccess(ret);
    },
    error: function(xhr) {
      resultWorking();
      resultError(xhr);
      resultComplete(xhr);
    }
  });
}

function create_variables(workspace_id) {
  tfe_workingMessage('Creating variables...');

  $('div[id*=variables]').children('div').each(function() {
    //Skip ignored variables
    if ($(this).find('input[id*=ignore]').is(':checked')) { return }
    console.log($(this));
    variable  = $(this).attr('var');
    value     = $(this).find('input[id*=var]').val();
    sensitive = $(this).find('input[id*=sensitive]').is(':checked');
    hcl       = $(this).find('input[id*=hcl]').is(':checked');
    category  = $(this).attr('category');

    // Escape double-quotes in HCL
    if (hcl) {
      value = value.replace(/"/g, '\\"')
    }

    data = '{ \
      "tfe_server": "' + $('#target_tfe_server').val() + '", \
      "tfe_token": "' + $('#target_tfe_token').val() + '", \
      "endpoint": "vars", \
      "method" : "POST", \
      "e_codes": [201], \
      "keys": { \
        "data": { \
          "type":"vars", \
          "attributes": { \
            "key":"' + variable + '", \
            "value":"' + value + '", \
            "category":"' + category + '", \
            "hcl": ' + hcl + ', \
            "sensitive": ' + sensitive + ' \
          }, \
          "relationships": { \
            "workspace": { \
              "data": { \
                "id": "' + workspace_id + '", \
                "type": "workspaces" \
              } \
            } \
          } \
        } \
      } \
    }'
    console.log(data.replace(/ {2,}/g, ' '));
    $.ajax({
      type: 'post',
      timeout: 30000,
      url: '/api/1.0/tfe_call',
      data: data,
      dataType:'json',
      success: function(xhr) {
        console.log(xhr);
        //aggregate_msg = aggregate_msg.push(xhr['message']);
      },
      error: function(xhr) {
        resultWorking();
        resultError(xhr);
        resultComplete(xhr);
      }
    });
  });
}

var tfe_load = `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="40px" height="45px" viewBox="0 0 40 45" version="1.1" id="terraform-loading">
	<style>
		#terraform-loading polygon {
			animation: terraform-loading-animation 1.5s infinite ease-in-out;
			transform-origin: 50% 50%;
			fill: #D5D2F7;
		}
		#terraform-loading .terraform-loading-order-2 {
			animation-delay: .1s;
		}
		#terraform-loading .terraform-loading-order-3 {
			animation-delay: .2s;
		}
		#terraform-loading .terraform-loading-order-4 {
			animation-delay: .3s;
		}
		#terraform-loading .terraform-loading-order-5 {
			animation-delay: .4s;
		}
		@keyframes terraform-loading-animation {
			0%,
			70% {
				transform: scale3D(1, 1, 1);
			}
			35% {
				transform: scale3D(0, 0, 1);
			}
		}
	</style>
	<g id="terraform-loading-y-1">
		<polygon class="terraform-loading-order-4" points="0,0 12,4 12,14 0,10" style="transform-origin: 6px 7px" />
		<polygon class="terraform-loading-order-5" points="14,5 26,9 26,19 14,15" style="transform-origin: 20px 12px" />
		<polygon class="terraform-loading-order-4" points="28,9 40,5 40,15 28,19" style="transform-origin: 34px 12px" />
	</g>
	<g id="terraform-loading-y-2">
		<polygon class="terraform-loading-order-2" points="0,13 12,17 12,27 0,23" style="transform-origin: 6px 20px" />
		<polygon class="terraform-loading-order-4" points="14,18 26,22 26,32 14,28" style="transform-origin: 20px 25px" />
		<polygon class="terraform-loading-order-2" points="28,22 40,18 40,28 28,32" style="transform-origin: 34px 25px" />
	</g>
	<g id="terraform-loading-y-3">
		<polygon class="terraform-loading-order-1" points="0,25 12,30 12,40 0,36" style="transform-origin: 6px 33px" />
		<polygon class="terraform-loading-order-2" points="14,31 26,35 26,45 14,41" style="transform-origin: 20px 38px" />
		<polygon class="terraform-loading-order-1" points="28,35 40,31 40,41 28,45" style="transform-origin: 34px 38px" />
	</g>
</svg>`

function tfe_workingMessage(message) {
  console.log('Working message: ' + message);
  workingMessage('<h3>' + tfe_load + '<br>' + message + '</h3>');
}

function toggle_advanced() {
  status = ( $("#ws-attributes").is(':visible') ? 'up' : 'down' );
  $("#ws-attributes").toggle("slow");
  $('#advanced_options').html('Advanced Options <span class="glyphicon glyphicon-menu-' + status + '"></span>');
}
