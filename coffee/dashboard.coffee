class Dashboard
	constructor: () ->
		document.getElementById('btnEventAttendeesHide').onclick = @clearEventAttendees

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
		tr.appendChild tdDetails
		return tr


window.onload = () ->
	window.Page = new Dashboard()