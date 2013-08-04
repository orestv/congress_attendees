class Index
	constructor: () ->
		@searching = false
		@nextSearch = null
		@table = document.getElementById('searchResultsTable')
		@tableBody = document.getElementById('searchResultsBody')
		searchBoxInput = document.getElementById('searchBox')
		searchBoxInput.focus()
		searchbox = new window.SearchBox(searchBoxInput, @searchRequested)
		if localStorage.selectedAttendeeJSON?
			attendee = JSON.parse(localStorage.selectedAttendeeJSON)
			@editAttendee attendee
		if localStorage.searchQuery?
			searchBoxInput.value = localStorage.searchQuery
			@searchRequested localStorage.searchQuery

	searchRequested: (searchQuery) =>		
		if searchQuery == ''
			localStorage.removeItem('searchQuery')
			@nextSearch = null
			@searchRequest.abort()
			@searching = false
			document.getElementById('imgSearchLoader').style.visibility = 'hidden'
			@clearSearchResults()
			return
		localStorage.searchQuery = searchQuery
		document.getElementById('imgSearchLoader').style.visibility = 'visible'
		if @searching
			# @searching = false
			@searchRequest.abort()
			# term = searchQuery
			# @nextSearch = () =>
			# 	@searchRequested term
			# return
		@searching = true
		@searchRequest = new XMLHttpRequest()
		@searchRequest.onreadystatechange = @processSearchRequest
		@searchRequest.open('GET', "/attendees?s=#{searchQuery}", true)
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
		city = if attendee.city? then attendee.city else 'N/A'
		@appendCell(tr, city)
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
			@editAttendeeClicked attendee
			@selectedAttendeeRow = tr
		td.appendChild button
		tr.appendChild td
		return tr

	editAttendeeClicked: (attendee) =>
		if not attendee.registered or confirm('Цей учасник вже зареєстрований. Ви справді бажаєте змінити його дані?')
			localStorage.selectedAttendeeJSON = JSON.stringify(attendee)
			@editAttendee attendee

	editAttendee: (attendee) =>
		@editor = new AttendeeEditor(attendee)
		@editor.show()

	updateEditedAttendee: (attendeeId) =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				attendee = JSON.parse(request.responseText).attendee
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
		'txtPhone': 'personal_phone',
		'txtPosition': 'position',
		'txtOrganization': 'organization'
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
				response = JSON.parse(@request.responseText)
				@attendee = response.attendee
				@events = response.events
				@fill()
		@request.open('GET', "/attendees?id=#{@attendee._id.$oid}", true)
		@request.send(null)

	fill: () =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if input?
				input.value = @attendee[objectKey]
				input.onkeyup = @infoInputKeyPressed
		for evt in @attendee['attended_events']
			document.getElementById(evt['id']).checked = true
		for evt in @events
			if evt.limit?
				document.getElementById("dvLimit_#{evt._id.$oid}").style.display = 'block'
				document.getElementById("spLimit_#{evt._id.$oid}").textContent = evt.limit
				document.getElementById("spAttendees_#{evt._id.$oid}").textContent = evt.attendees
			else
				document.getElementById("dvLimit_#{evt._id.$oid}").style.display = 'none'
	clear: () =>
		for inputId, objectKey of @fields
			input = document.getElementById inputId
			input.value = ''
			input.style.backgroundColor = 'white'
		for checkbox in document.getElementsByName('events')
			checkbox.checked = false

	hide: () =>
		document.getElementById('searchListContainer').style.display = 'block'
		@editorContainer.style.display = 'none'
		localStorage.removeItem('selectedAttendeeJSON')

	infoInputKeyPressed: (event) =>
		input = event.currentTarget
		fieldId = @fields[input.id]
		fieldValue = @attendee[fieldId]
		if fieldValue != input.value
			input.style.backgroundColor = '#E0FFE0'
		else
			input.style.backgroundColor = 'white'

	getEventsData: () =>
		eventCheckboxes = document.getElementsByName('events')
		result = [cb.id for cb in eventCheckboxes when cb.checked]
		return result.join(',')

	getAttendeeData: () =>
		resultArray = []
		for inputId, objectKey of @fields
			input = document.getElementById inputId
			if input.value == @attendee[objectKey]
				continue
			resultArray.push "#{objectKey}=#{input.value}"
		return resultArray.join('&')

	register: () =>
		selectedEvents = @getEventsData()
		attendeeData = @getAttendeeData()
		saveRequest = new XMLHttpRequest()
		saveRequest.open('PUT', "/attendees?id=#{@attendee._id.$oid}&registered=1", false)
		saveRequest.setRequestHeader("Content-type","application/x-www-form-urlencoded");
		data = "events=#{selectedEvents}"
		if attendeeData
			data += '&' + attendeeData
		console.log data
		saveRequest.send(data)

	registerAttendee: () =>
		@register()
		Page.updateEditedAttendee(@attendee._id.$oid)
		@hide()

	backToList: () =>
		@hide()


window.bodyLoaded = () ->
	window.Page = new Index()

search = (text) ->
	console.log text