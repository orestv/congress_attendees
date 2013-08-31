class Dashboard
	constructor: () ->
		document.getElementById('btnEventAttendeesHide').onclick = @clearEventAttendees
		@btnShowAttendeeEditor = document.getElementById('btnShowAttendeeEditor')
		@btnHideAttendeeEditor = document.getElementById('btnHideAttendeeEditor')
		@btnAddAttendee = document.getElementById('btnAddAttendee')
		@btnShowAttendeeEditor.onclick = @showAttendeeEditor
		@btnHideAttendeeEditor.onclick = @hideAttendeeEditor
		@btnAddAttendee.onclick = @addAttendee

	showEventAttendees: (eventId, eventCaption) =>
		@clearEventAttendees()
		document.getElementById('spEventName').textContent = eventCaption
		eventAttendeesRequest = new XMLHttpRequest()
		eventAttendeesRequest.open 'GET', "/attendees?eventId=#{eventId}", false
		eventAttendeesRequest.onreadystatechange = () =>
			if eventAttendeesRequest.readyState == 4
				attendees = JSON.parse(eventAttendeesRequest.responseText)
				@fillEventAttendees attendees
		eventAttendeesRequest.send(null)

	clearEventAttendees: () =>
		tbody = document.getElementById('eventAttendeesTbody')
		while tbody.firstChild
			tbody.removeChild tbody.firstChild
		document.getElementById('dvEventAttendees').style.display = 'none'

	fillEventAttendees: (eventAttendees) =>
		tbody = document.getElementById('eventAttendeesTbody')
		for attendee in eventAttendees
			tbody.appendChild @createEventAttendeeRow attendee
		document.getElementById('dvEventAttendees').style.display = 'block'

	createEventAttendeeRow: (attendee) ->
		tr = document.createElement 'tr'
		details = "#{attendee.lastname} #{attendee.firstname} #{attendee.middlename}, #{attendee.city}"
		tdDetails = document.createElement 'td'
		tdDetails.appendChild document.createTextNode(details)
		if attendee.queue
			tr.className = 'queuedAttendee'
		tr.appendChild tdDetails
		return tr

	showAttendeeEditor: () =>
		@btnShowAttendeeEditor.style.display = 'none'
		@attendeeEditor = new AttendeeEditor({})
		@attendeeEditor.show()

	hideAttendeeEditor: () =>
		@btnShowAttendeeEditor.style.display = 'block'
		@attendeeEditor.clear()
		@attendeeEditor.hide()

	addAttendee: () =>
		attendeeData = @attendeeEditor.getAttendeeData()
		console.log attendeeData
		request = new XMLHttpRequest()
		request.open('PUT', '/attendees', false)
		request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
		request.send(attendeeData)
		@hideAttendeeEditor()


window.onload = () ->
	window.Page = new Dashboard()