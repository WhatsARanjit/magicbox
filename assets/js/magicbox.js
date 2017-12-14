function makeHTMLfriendly(input) {
  formatted = Array();

  // Split multiline outputs to array elements for easy formatting
  for (line in input) {
    if (typeof input[line] == 'string') {
      formatted = formatted.concat(input[line].split("\n"))
    } else {
      formatted = formatted.push(input[line])
    };
  };
  return formatted;
}

function resultSuccess(res) {
  console.log(res);
  formatted = makeHTMLfriendly(res['message']);

  // Optional munging
  if ( typeof munge_success == 'function' ) {
    console.log('munge_success triggered');
    formatted = munge_success(formatted);
  }

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
  setTimeout(function() { $('#successModal').modal('hide') }, 2000);
}

function resultError(xhr) {
  res = JSON.parse(xhr.responseText);
  console.log(res);
  formatted = makeHTMLfriendly(res['message']);

  // Optional munging
  if ( typeof munge_error == 'function' ) {
    console.log('munge_error triggered');
    formatted = munge_error(formatted);
  }

  // Do status box
  $('#output').attr('rows', formatted.length+2);
  $('#output').val(formatted.join("\n"));

  // Fail colors
  $('#status').removeClass('text-success');
  $('#status').removeClass('text-warning');
  $('#status').addClass('text-danger');
  $('#status').html('Something didn\'t work...check the error message below for more details');
}

function resultComplete(xhr) {
  res = JSON.parse(xhr.responseText);
  if (!res['message'].length > 0) {
    $('#samp_output').hide('fast');
  } else {
    $('#samp_output').show('fast');
  }
}

function resultWorking() {
  // Reset box
  $('#status').removeClass('text-success');
  $('#status').removeClass('text-danger');
  $('#status').addClass('text-warning');
  $('#status_output').show('fast');
  $('#samp_output').hide('fast');
  $('#status').html('working...');
}

function fakeFail(msg) {
  resultWorking();

  stuff = '{ "message": ["' + msg  + '"] }';
  xhr = new Object;
  xhr.responseText = stuff;

  resultError(xhr);
  resultComplete(xhr);
}

function submitcode(endpoint, data)
  {
    resultWorking();

    // Make it pretty for logging/debugging
    console.log(data.replace(/ {2,}/g, ' '));
    console.log($('#magic-box').val());

    // Submit API request
    $.ajax({ 
      type:'post',
      url:'/api/1.0/' + endpoint,
      data: data,
      dataType:'json',
      success: function(res) { resultSuccess(res) },
      error: function(xhr) { resultError(xhr) },
      complete: function(xhr) { resultComplete(xhr) }
  });
}

function formFooter() {
  output_html = "\
  <p><button onclick='test();' class='btn btn-warning'>Test</button></p>\
<form id='status_output' hidden>\
  <div class='form-inline'>\
    <label for='output'>Status:</label> <span id='status'>success</span>\
  </div>\
  <div class='form-group' id='samp_output'>\
    <samp><textarea class='form-control' id='output' rows='5' readonly></textarea></samp>\
  </div>\
</form>";
  document.write(output_html);
}

function catchEnter(box = '#magic-box') {
  $(box).keypress(function(e) {
    if (e.which == '13') {
      e.preventDefault();
      test();
      return false
    }
  });
}

function inputCheck(check, box = '#magic-box') {
  $('button').attr('disabled', 'disabled');
  $(box).keyup(function(e) {
    check_regex = new RegExp(check);
    if (check_regex.exec($(box).val())) {
      $('button').removeAttr('disabled');
    }
    else {
      $('button').attr('disabled', 'disabled');
    }
  });
}
