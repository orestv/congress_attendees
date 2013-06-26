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
		if searchTerm == ''# and @searching
			@nextSearch = null
			@searchRequest.abort()
			@searching = false
			document.getElementById('imgSearchLoader').style.visibility = 'hidden'
			@clearSearchResults()
			return
		document.getElementById('imgSearchLoader').style.visibility = 'visible'
		if @searching
			term = searchTerm
			@nextSearch = () =>
				@searchRequested term
			return
		@searching = true
		@searchRequest = new XMLHttpRequest()
		@searchRequest.onreadystatechange = @processSearchRequest
		@searchRequest.open('GET', "/attendees?s=#{searchTerm}", true)
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
		attendees = results['attendees']
		attendee_count = results['count']
		if attendee_count > 0
			for attendee in attendees then do (attendee) =>
				frag.appendChild @createAttendeeRow attendee
		@tableBody.appendChild(frag)
		if attendee_count > 0
			document.getElementById('dvNoneFound').style.display = 'none'
			document.getElementById('dvFoundCount').style.display = 'block'
			document.getElementById('spFoundCount').textContent = attendee_count
		else
			document.getElementById('dvNoneFound').style.display = 'block'
			document.getElementById('dvFoundCount').style.display = 'none'
		@table.style.visibility = 'visible'

	createAttendeeRow: (attendee) =>
		tr = document.createElement 'tr'
		@appendCell(tr, attendee.city)
		attendeeName = "#{attendee.lastname} #{attendee.firstname} #{attendee.middlename}"
		@appendCell(tr, attendeeName)
		if attendee.registered? and attendee.registered
			tr.className = 'registered'
		td = document.createElement 'td'
		button = document.createElement 'input'
		button.type = 'button'
		if not attendee.registered?
			button.value = 'Зареєструвати'
		else
			button.value = 'Змінити інформацію'
		button.onclick = =>
			@editAttendee attendee
			@selectedAttendeeRow = tr
		td.appendChild button
		tr.appendChild td
		return tr

	editAttendee: (attendee) =>
		if not attendee.registered or confirm('Цей учасник вже зареєстрований. Ви справді бажаєте змінити його дані?')
			new AttendeeEditor(attendee).show()

	updateEditedAttendee: (attendeeId) =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				attendee = JSON.parse(request.responseText)
				newRow = @createAttendeeRow(attendee)
				@tableBody.replaceChild(newRow, @selectedAttendeeRow)
		request.open('GET', "/attendees?id=#{attendeeId}", true)
		request.send(null)

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
		'txtCity': 'city',
		'txtPhone': 'phone',
		'txtField': 'field'
	}

	constructor: (@attendee) ->
		@editorContainer = document.getElementById 'attendeeEditorContainer'
		document.getElementById('btnRegisterAttendee').onclick = @registerAttendee
		document.getElementById('btnBackToList').onclick = @backToList

	show: () =>
		document.getElementById('searchListContainer').style.display = 'none'
		@editorContainer.style.display = 'block'
		@clear()
		@fetch()

	fetch: () =>
		@request = new XMLHttpRequest()
		@request.onreadystatechange = () =>
			if @request.readyState == 4
				@attendee = JSON.parse(@request.responseText)
				@fill()
		@request.open('GET', "/attendees?id=#{@attendee._id}", true)
		@request.send(null)

	fill: () =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if input?
				input.value = @attendee[objectKey]
		for eventId in @attendee['attended_events']
			document.getElementById(eventId).checked = true
	clear: () =>
		for inputId, objectKey of @fields
			document.getElementById(inputId).value = ''
		for checkbox in document.getElementsByName('events')
			checkbox.checked = false

	hide: () =>
		document.getElementById('searchListContainer').style.display = 'block'
		@editorContainer.style.display = 'none'

	getEventsData: () =>
		eventCheckboxes = document.getElementsByName('events')
		result = [cb.id for cb in eventCheckboxes when cb.checked]
		console.log result
		return result

	saveEvents: () =>
		selectedEvents = @getEventsData()
		saveRequest = new XMLHttpRequest()
		saveRequest.open('PUT', "/attendees?id=#{@attendee._id}&events=#{selectedEvents}&registered=1", false)
		saveRequest.send(null)

	registerAttendee: () =>
		@saveEvents()
		Page.updateEditedAttendee(@attendee._id)
		@hide()

	backToList: () =>
		@hide()


window.bodyLoaded = () ->
	window.Page = new Index()

search = (text) ->
	console.log text