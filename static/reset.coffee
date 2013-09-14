btnShowResetButton_clicked = () ->
	document.getElementById('dvResetContainer').style.display = 'block'

chkEnableReset_changed = (event) ->
	chk = event.target
	if chk.checked
		document.getElementById('btnReset').removeAttribute('disabled')
	else
		document.getElementById('btnReset').setAttribute('disabled', 'disabled')

resetForm_onsubmit = () ->
	return confirm('Ви впевнені, що хочете очистити базу?')

window.onload = () ->
	document.getElementById('btnShowResetButton').onclick = btnShowResetButton_clicked
	document.getElementById('chkEnableReset').onchange = chkEnableReset_changed
	document.getElementById('resetForm').onsubmit = resetForm_onsubmit