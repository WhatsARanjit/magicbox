function submitcode(endpoint, data)
  {
    console.log($('#magic-box').val());
    $.ajax({ 
      type:'post',
      url:'api/1.0/' + endpoint,
      data: data,
      dataType:'json',
      success: function(res) {
        console.log(res)
        $('#output').attr('rows', res['message'].length+2);
        $('#output').val(res['message'].join("\n"));
        if (res['exitcode'] == 0) {
          $('#status').removeClass('text-danger');
          $('#status').addClass('text-success');
          $('#status').html('success');
        } else {
          $('#status').removeClass('text-success');
          $('#status').addClass('text-danger');
          $('#status').html('failure');
        }
        $('#status_output').show('fast');
        if (!res['message'].length > 0) {
          $('#samp_output').hide('fast');
        } else {
          $('#samp_output').show('fast');
        }
      }
  });
}
