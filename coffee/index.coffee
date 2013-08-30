class Index
	constructor: () ->
		@searching = false
		@nextSearch = null
		@table = document.getElementById('searchResultsTable')
		@tableBody = document.getElementById('searchResultsBody')
		searchBoxInput = document.getElementById('searchBox')
		searchBoxInput.focus()
		searchbox = new window.SearchBox(searchBoxInput, @searchRequested, @editFirstAttendee)

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

	editFirstAttendee: () =>
		if @first_attendee?
			@editAttendee @first_attendee

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


window.onload = () ->
	window.Page = new Index()

search = (text) ->
	console.log text