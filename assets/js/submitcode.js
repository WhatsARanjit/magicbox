function submitcode(endpoint, data)
  {
    $('#status').removeClass('text-success');
    $('#status').removeClass('text-danger');
    $('#status').addClass('text-warning');
    $('#status_output').show('fast');
    $('#samp_output').hide('fast');
    $('#status').html('working...');
    console.log(data);
    console.log($('#magic-box').val());
    $.ajax({ 
      type:'post',
      url:'api/1.0/' + endpoint,
      data: data,
      dataType:'json',
      success: function(res) {
        console.log(res)
        formatted = Array();
        for (line in res['message']) {
          if (typeof res['message']['line'] == 'string') {
            formatted.push(res['message'][line].replace(/\n/g, "<br />"))
          } else {
            formatted.push(res['message'][line])
          };
        };
        $('#output').attr('rows', formatted.length+2);
        $('#output').val(formatted.join("\n"));
        if (res['exitcode'] == 0) {
          $('#status').removeClass('text-danger');
          $('#status').removeClass('text-warning');
          $('#status').addClass('text-success');
          $('#status').html('success');
        } else {
          $('#status').removeClass('text-success');
          $('#status').removeClass('text-warning');
          $('#status').addClass('text-danger');
          $('#status').html('failure');
        }
        if (!res['message'].length > 0) {
          $('#samp_output').hide('fast');
        } else {
          $('#samp_output').show('fast');
        }
      }
  });
}
