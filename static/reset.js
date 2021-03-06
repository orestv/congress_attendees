// Generated by CoffeeScript 1.6.1
(function() {
  var btnShowResetButton_clicked, chkEnableReset_changed, resetForm_onsubmit;

  btnShowResetButton_clicked = function() {
    return document.getElementById('dvResetContainer').style.display = 'block';
  };

  chkEnableReset_changed = function(event) {
    var chk;
    chk = event.target;
    if (chk.checked) {
      return document.getElementById('btnReset').removeAttribute('disabled');
    } else {
      return document.getElementById('btnReset').setAttribute('disabled', 'disabled');
    }
  };

  resetForm_onsubmit = function() {
    return confirm('Ви впевнені, що хочете очистити базу?');
  };

  window.onload = function() {
    document.getElementById('btnShowResetButton').onclick = btnShowResetButton_clicked;
    document.getElementById('chkEnableReset').onchange = chkEnableReset_changed;
    return document.getElementById('resetForm').onsubmit = resetForm_onsubmit;
  };

}).call(this);
