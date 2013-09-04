class Index
	constructor: () ->
		@admin = window.admin
		@searching = false
		@nextSearch = null
		@table = document.getElementById('searchResultsTable')
		@tableBody = document.getElementById('searchResultsBody')
		searchBoxInput = document.getElementById('searchBox')
		searchBoxInput.focus()
		searchbox = new window.SearchBox(searchBoxInput, @searchRequested, @editFirstAttendee)

		document.getElementById('btnRegisterAttendee').onclick = @registerAttendee
		document.getElementById('btnBackToList').onclick = @backToList

	searchRequested: (searchQuery) =>		
		if searchQuery == ''
			@nextSearch = null
			if @searchRequest?
				@searchRequest.abort()
			@searching = false
			document.getElementById('imgSearchLoader').style.visibility = 'hidden'
			@clearSearchResults()
			return
		document.getElementById('imgSearchLoader').style.visibility = 'visible'
		if @searching
			@searchRequest.abort()
		@searchRequest = new XMLHttpRequest()
		@searchRequest.onreadystatechange = @processSearchRequest
		@searchRequest.open('GET', "/attendees?s=#{searchQuery}", true)
		@searchRequest.setRequestHeader("Content-type","application/x-www-form-urlencoded");
		@searchRequest.send(null)
		@searching = true

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
		@first_attendee = null
		while (@tableBody.firstChild)
			@tableBody.removeChild(@tableBody.firstChild)

	populateSearchResults: (results) =>
		@tableBody = document.getElementById('searchResultsBody')
		frag = document.createDocumentFragment()
		attendees = results['attendees']
		attendee_count = results['count']
		if attendee_count > 0
			@first_attendee = attendees[0]
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
		if @admin or not attendee.registered
			button = document.createElement 'input'
			button.type = 'button'
			if attendee.registered
				button.value = 'Змінити інформацію'
			else
				button.value = 'Зареєструвати'
			button.onclick = =>
				@editAttendeeClicked attendee
				@selectedAttendeeRow = tr
			td.appendChild button
		tr.appendChild td
		return tr

	editAttendeeClicked: (attendee) =>
		@editAttendee attendee

	editFirstAttendee: () =>
		if @first_attendee? and (@admin or not @first_attendee.registered)
			@editAttendee @first_attendee

	editAttendee: (attendee) =>
		if attendee.registered and not confirm('Цей учасник вже зареєстрований. Ви справді бажаєте змінити його дані?')
			return
		window.location.href = "/attendee_edit?id=#{attendee._id}"
		return
		@editor = new AttendeeEditor(attendee)
		document.getElementById('searchListContainer').style.display = 'none'
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

	registerAttendee: () =>
		request = new XMLHttpRequest()
		eventsData = @editor.getEventsData()
		attendeeData = @editor.getAttendeeData()
		data = "events=#{eventsData}"
		if attendeeData
			data += '&' + attendeeData
		request.open('PUT', "/attendees?id=#{@editor.attendee._id}&registered=1", false)
		request.setRequestHeader("Content-type","application/x-www-form-urlencoded");
		request.send(data)		
		@updateEditedAttendee(@editor.attendee._id)
		@backToList()

	backToList: () =>
		@editor.hide()
		document.getElementById('searchListContainer').style.display = 'block'

	appendCell: (tr, text) ->
		td = document.createElement 'td'
		td.appendChild document.createTextNode(text)
		tr.appendChild td
		return td


window.onload = () ->
	window.Page = new Index()

search = (text) ->
	console.log text