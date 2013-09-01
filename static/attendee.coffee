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

	firstInputId = 'txtLastname'
	@attendeeFetched = false
	@eventsFetched = false

	constructor: (@attendeeId) ->
		@tbEvents = Sizzle('#tbEvents')[0]
		@fetchEventFreePlaces()
		if @attendeeId?
			@fetchAttendee()
		else
			@attendeeFetched = true		
		@fetchEvents()

	fetchAttendee: () =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				response = JSON.parse(request.responseText)
				@attendee = response.attendee
				@attendeeFetched = true
				setTimeout @fillEventsActions, 1
				setTimeout (() => 
					@fillAttendeeDetails @attendee
					, 1)
		request.open('GET', "/attendees?id=#{@attendeeId}", true)
		request.send(null)

	fetchEventFreePlaces: () =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				response = JSON.parse(request.responseText)
				events = response.events
				@fillEventsFreePlaces(events)
		request.open('GET', '/events?type=free_places', true)
		request.send(null)

	fetchEvents: () =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				response = JSON.parse(request.responseText)
				@events = response.events
				@eventsFetched = true
				setTimeout @fillEventsActions, 1
		request.open('GET', '/events', true)
		request.send(null)

	fillAttendeeDetails: (attendee) ->
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if input? and @attendee[objectKey]?
				input.value = @attendee[objectKey]

	fillEventsFreePlaces: (events) ->
		for evt in events
			@fillEventFreePlaces evt

	fillEventFreePlaces: (evt) ->
		@getEventElement('spNoLimit', evt).style.display = 'none'
		@getEventElement('spFreePlaces', evt).style.display = 'none'
		@getEventElement('spNoFreePlaces', evt).style.display = 'none'
		if not evt.free_places?
			span = @getEventElement 'spNoLimit', evt
		else
			if evt.free_places > 0
				span = @getEventElement 'spFreePlaces', evt
				span.textContent = evt.free_places
			else
				span = @getEventElement 'spNoFreePlaces', evt
		span.style.display = 'block'

	fillEventsActions: () =>
		if not @attendeeFetched or not @eventsFetched
			console.log 'Attendee fetched: #{@attendeeFetched}, events fetched: #{@eventsFetched}'
			return
		@joinEventData()
		console.log 'Filling event actions'
		for evt in @events
			console.log evt
			@fillEventActions evt

	fillEventActions: (evt) =>
		if evt.limit?
			btnCancel = @getEventElement 'btnCancel', evt
			btnBook = @getEventElement 'btnBook', evt
			spBooked = @getEventElement 'spBooked', evt
			spPaid = @getEventElement 'spPaid', evt
			btnBook.onclick = @btnBook_clicked
			btnCancel.onclick = @btnCancel_clicked
			for item in [btnCancel, btnBook, spBooked, spPaid]
				item.style.display = 'none'		
			if evt['booked'] or evt['paid']
				@getEventElement('btnCancel').style.display = 'inline'
				if evt['booked']
					@getEventElement('spBooked').style.display = 'inline'
			else
				btnBook.style.display = 'inline'

	btnBook_clicked: (event) =>
		btnBook = event.target		
		eventId = @getEventIdFromEvent event
		evt = null
		for e in events when e['_id'] == eventId
			evt = e

	btnCancel_clicked: (event) =>
		btnCancel = event.target
		eventId = @getEventIdFromEvent event
		for e in events when e['_id'] == eventId
			evt = e
		if not confirm('Ви впевнені, що бажаєте відмінити реєстрацію на "#{evt.caption}"?')
			return

	joinEventData: () =>
		#todo
		for a_evt in @attendee['attended_events']
			for evt in @events when evt['_id'] == a_evt['_id']
				for attr in a_evt
					console.log attr

	getEventElement: (name, evt) ->
		return Sizzle("[eventId=#{evt._id}][name=#{name}]", @tbEvents)[0]

	getEventIdFromEvent: (event) ->
		target = event.target
		return target.getAttribute('eventId')

window.onload = () ->
	editorData = JSON.parse(sessionStorage.attendeeEditorData)
	window.editor = new AttendeeEditor(editorData.id)