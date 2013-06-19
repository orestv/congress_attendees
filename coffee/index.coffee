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
		td = document.createElement 'td'
		button = document.createElement 'input'
		button.type = 'button'
		button.value = 'Зареєструвати'
		button.onclick = =>
			@attendeeRowClicked attendee
		td.appendChild button
		tr.appendChild td
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

	hide: () =>
		document.getElementById('searchListContainer').style.display = 'block'
		@editorContainer.style.display = 'none'

	registerAttendee: () =>
		@hide()

	backToList: () =>
		@hide()


window.bodyLoaded = () ->
	window.Page = new Index()

search = (text) ->
	console.log text