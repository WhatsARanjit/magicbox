function makeHTMLfriendly(input) {
  formatted = Array();

  // Change \n into <br /> for HTML viewing
  for (line in input) {
    if (typeof input['line'] == 'string') {
      formatted.push(input[line].replace(/\n/g, "<br />"))
    } else {
      formatted.push(input[line])
    };
  };
  return formatted;
}

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
        console.log(res);
        formatted = makeHTMLfriendly(res['message']);

        // Do status box
        $('#output').attr('rows', formatted.length+2);
        $('#output').val(formatted.join("\n"));

        // Success colors
        $('#status').removeClass('text-danger');
        $('#status').removeClass('text-warning');
        $('#status').addClass('text-success');
        $('#status').html('success');

        // Success modal
        $('#successModal').modal('show');
      },
      error: function(xhr) {
        res = JSON.parse(xhr.responseText);
        console.log(res);
        formatted = makeHTMLfriendly(res['message']);

        // Do status box
        $('#output').attr('rows', formatted.length+2);
        $('#output').val(formatted.join("\n"));

        // Fail colors
        $('#status').removeClass('text-success');
        $('#status').removeClass('text-warning');
        $('#status').addClass('text-danger');
        $('#status').html('failure');
      },
      complete: function(xhr) {
        res = JSON.parse(xhr.responseText);
        if (!res['message'].length > 0) {
          $('#samp_output').hide('fast');
        } else {
          $('#samp_output').show('fast');
        }
      }
  });
}
