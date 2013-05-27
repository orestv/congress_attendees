class Index
	constructor: () ->
		@searching = false
		@nextSearch = null
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
		while (@tableBody.firstChild)
			@tableBody.removeChild(@tableBody.firstChild)

	populateSearchResults: (results) =>		
		@tableBody = document.getElementById('searchResultsBody')
		frag = document.createDocumentFragment()
		for attendee in results then do (attendee) =>
			frag.appendChild @createAttendeeRow attendee
		@tableBody.appendChild(frag)

	createAttendeeRow: (attendee) =>
		tr = document.createElement 'tr'
		
		td = document.createElement 'td'
		td.appendChild document.createTextNode(attendee.city)
		tr.appendChild td

		td = document.createElement 'td'
		td.appendChild document.createTextNode("#{attendee.lastname} #{attendee.firstname} #{attendee.middlename}")
		tr.appendChild td

		tr.onclick = () =>
			@attendeeRowClicked attendee.id

		return tr

	attendeeRowClicked: (id) =>
		alert id 

window.bodyLoaded = () ->
	window.Page = new Index()

search = (text) ->
	console.log text