class Index
	constructor: () ->
		@searching = false
		@nextSearch = null
		@table = document.getElementById('searchResultsTable')
		@tableBody = document.getElementById('searchResultsBody')
		searchBoxInput = document.getElementById('searchBox')
		searchBoxInput.focus()
		searchbox = new window.SearchBox(searchBoxInput, @searchRequested)

	searchRequested: (searchTerm) =>
		if searchTerm == '' and @searching
			@nextSearch = null
			@searchRequest.abort()
			@searching = false
			document.getElementById('imgSearchLoader').style.visibility = 'hidden'
			return
		document.getElementById('imgSearchLoader').style.visibility = 'visible'
		if @searching
			# @searchRequest.abort()
			term = searchTerm
			@nextSearch = () =>
				@searchRequested term
			return
		@searching = true
		@searchRequest = new XMLHttpRequest()
		@searchRequest.onreadystatechange = @processSearchRequest
		@searchRequest.open('GET', "/find_attendee?s=#{searchTerm}", true)
		@searchRequest.setRequestHeader("Content-type","application/x-www-form-urlencoded");
		@searchRequest.send(null)

	processSearchRequest: () =>
		if @searchRequest.readyState == 4 && @searchRequest.status == 200
			result = JSON.parse(@searchRequest.responseText)
			@clearSearchResults()
			@populateSearchResults(result)
			@searching = false
			document.getElementById('imgSearchLoader').style.visibility = 'hidden'
			if @nextSearch?
				@nextSearch()
				@nextSearch = null

	clearSearchResults: () =>
		@table.style.visibility = 'hidden'
		while (@tableBody.firstChild)
			@tableBody.removeChild(@tableBody.firstChild)	

	populateSearchResults: (results) =>		
		@tableBody = document.getElementById('searchResultsBody')
		frag = document.createDocumentFragment()
		for attendee in results then do (attendee) =>
			frag.appendChild @createAttendeeRow attendee
		@tableBody.appendChild(frag)
		if results.length > 0
			@table.style.visibility = 'visible'

	createAttendeeRow: (attendee) =>
		tr = document.createElement 'tr'
		tr.onclick = () =>
			@attendeeRowClicked attendee
		@appendCell(tr, attendee.city)
		attendeeName = "#{attendee.lastname} #{attendee.firstname} #{attendee.middlename}"
		@appendCell(tr, attendeeName)
		return tr

	attendeeRowClicked: (attendee) =>
		new AttendeeEditor(attendee).show()

	appendCell: (tr, text) ->
		td = document.createElement 'td'
		td.appendChild document.createTextNode(text)
		tr.appendChild td
		return td

class AttendeeEditor

	fields: {
		'txtFirstname': 'firstname',
		'txtLastname': 'lastname',
		'txtMiddlename': 'middlename',
		'txtCity': 'city'
	}

	constructor: (@attendee) ->
		@editorContainer = document.getElementById 'attendeeEditorContainer'
		document.getElementById('btnRegisterAttendee').onclick = @registerAttendee
		document.getElementById('btnBackToList').onclick = @backToList
		document.getElementById('btnUpdateInfo').onclick = @updateInfo
		document.getElementById('btnSaveInfoUpdate').onclick = @saveInfoUpdate
		document.getElementById('btnCancelInfoUpdate').onclick = @cancelInfoUpdate

	show: () =>
		document.getElementById('searchListContainer').style.display = 'none'
		@editorContainer.style.display = 'block'
		@setEditorsEnabled false
		@fill()

	fill: () =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if input?
				input.value = @attendee[objectKey]

	hide: () =>
		document.getElementById('searchListContainer').style.display = 'block'
		@editorContainer.style.display = 'none'

	setEditorsEnabled: (enabled) ->
		for inputId of @fields
			input = document.getElementById(inputId)
			if input?
				input.disabled = not enabled

	updateInfo: () =>
		@setEditorsEnabled true
		document.getElementById('dvUpdateInfo').style.display = 'none'
		document.getElementById('dvUpdateInfoSaveCancel').style.display = 'block'

	cancelInfoUpdate: () =>
		@setEditorsEnabled false
		document.getElementById('dvUpdateInfo').style.display = 'block'
		document.getElementById('dvUpdateInfoSaveCancel').style.display = 'none'

	saveInfoUpdate: () =>
		@setEditorsEnabled false
		document.getElementById('dvUpdateInfo').style.display = 'block'
		document.getElementById('dvUpdateInfoSaveCancel').style.display = 'none'

	registerAttendee: () =>
		@hide()

	backToList: () =>
		@hide()


window.bodyLoaded = () ->
	window.Page = new Index()

search = (text) ->
	console.log text