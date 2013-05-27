class Index
	constructor: () ->
		@searching = false
		@tableBody = document.getElementById('searchResultsBody')
		searchBoxInput = document.getElementById('searchBox')
		searchBoxInput.focus()
		searchbox = new window.SearchBox(searchBoxInput, @searchRequested)

	searchRequested: (searchTerm) =>
		document.getElementById('imgSearchLoader').style.visibility = 'visible'
		if @searching
			@searchRequest.abort()
			# return
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
		return tr

window.bodyLoaded = () ->
	window.Page = new Index()

search = (text) ->
	console.log text