function submitcode(endpoint, data)
  {
    // Reset box
    $('#status').removeClass('text-success');
    $('#status').removeClass('text-danger');
    $('#status').addClass('text-warning');
    $('#status_output').show('fast');
    $('#samp_output').hide('fast');
    $('#status').html('working...');

    // Make it pretty for logging/debugging
    console.log(data.replace(/ {2,}/g, ' '));
    console.log($('#magic-box').val());

    // Submit API request
    $.ajax({ 
      type:'post',
      url:'api/1.0/' + endpoint,
      data: data,
      dataType:'json',
      success: function(res) {
        console.log(res)
        formatted = Array();

        // Change \n into <br /> for HTML viewing
        for (line in res['message']) {
          if (typeof res['message']['line'] == 'string') {
            formatted.push(res['message'][line].replace(/\n/g, "<br />"))
          } else {
            formatted.push(res['message'][line])
          };
        };

        // Do status box
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
        if ( res['exitcode'] == 0 ) {
          $('#successModal').modal('show');
        }
      }
  });
}
