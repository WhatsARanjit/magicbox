var workspaces_cache = '';
var ws_attributes = '';

function fetch_workspaces() {
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
    }
  });
}

function fetch_variables() {
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
              <input type='text' id='var-" + name + "' class='form-control' value='" + (value == null ? '' : value) + "' placeholder='" + (sensitive ? 'sensitive' : '') + "'>\
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
          </div>\
        ";
        type = category == 'terraform' ? '#form-set-tf-variables' : '#form-set-env-variables';
        $(type)
          .append($(variable_html));
      });
      ws_attributes = $.grep(workspaces_cache, function(ws) { return ws['id'] == $('#workspaces option:selected').attr('workspace_id') })[0]['attributes'];
      delete ws_attributes.name;
      console.log(ws_attributes);
      $(document).ready(function() {
        $('#target_tfe_org').val($('#source_tfe_org').val());
        $('#target_tfe_token').val($('#source_tfe_token').val());
        $('#ws-attributes').val(JSON.stringify(ws_attributes, null, 2));
        $('#form-set-tf-variables').slideDown();
        $('#form-set-env-variables').slideDown();
        $('#form-set-advanced').slideDown();
        $('#create-workspace').slideDown();
      });
    },
    error: function(xhr) {
      resultWorking();
      resultError(xhr);
      resultComplete(xhr);
    }
  });
}

function test() {
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
    async: false,
    timeout: 30000,
    url: '/api/1.0/tfe_call',
    data: data,
    dataType:'json',
    success: function(xhr) {
      console.log(xhr);
      aggregate_msg = xhr;
    },
    error: function(xhr) {
      resultWorking();
      resultError(xhr);
      resultComplete(xhr);
    }
  });
  console.log(aggregate_msg);
  workspace_id = aggregate_msg['message']['id'];
  $('div[id*=variables]').children('div').each(function() {
    console.log($(this));
    variable  = $(this).attr('var');
    value     = $(this).find('input').val();
    sensitive = $(this).attr('sensitive');
    hcl       = $(this).attr('hcl');
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
      async: false,
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
  //ret = JSON.stringify(aggregate_msg['message']).replace(/"/g, '\\"');
  ret = JSON.stringify(aggregate_msg['message']).replace(/"/g, '&quot;');
  console.log(ret);
  fakeSuccess(ret);
}
