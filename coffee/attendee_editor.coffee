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

	constructor: (@attendee) ->
		@editorContainer = document.getElementById 'attendeeEditorContainer'
		@initInputEvents()

	show: () =>
		@editorContainer.style.display = 'block'
		@clear()
		if @attendee._id?
			@fetch()
		document.getElementById(firstInputId).focus()

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

	initInputEvents: () ->
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if input?
				input.onkeyup = @infoInputKeyPressed

	clearInputEvents: () ->
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if input?
				input.onkeyup = null		

	fill: () =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if input?
				input.value = @attendee[objectKey]
		for evt in @attendee['attended_events']
			document.getElementById(evt['id']).checked = true
		for evt in @events
			spLimit = document.getElementById("spLimit_#{evt._id.$oid}")
			spAttendees = document.getElementById("spAttendees_#{evt._id.$oid}")
			spLimit.style.color = '#000'
			spAttendees.style.color = '#000'
			if evt.limit?
				spLimit.textContent = evt.limit
				spAttendees.textContent = evt.attendees
				if evt.attendees >= evt.limit
					spAttendees.style.color = '#F00'
					spLimit.style.color = '#F00'
	clear: () =>
		for inputId, objectKey of @fields
			input = document.getElementById inputId
			input.value = ''
			input.style.backgroundColor = 'white'
		for checkbox in document.getElementsByName('events')
			checkbox.checked = false

	hide: () =>
		@editorContainer.style.display = 'none'
		@clearInputEvents()

	infoInputKeyPressed: (event) =>
		input = event.currentTarget
		fieldId = @fields[input.id]
		fieldValue = @attendee[fieldId]
		if not fieldValue?
			fieldValue = ''
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
			attendeeValue = @attendee[objectKey]
			if not attendeeValue?
				attendeeValue = ''
			if input.value == attendeeValue
				continue
			resultArray.push "#{objectKey}=#{input.value}"
		return resultArray.join('&')

window.AttendeeEditor = AttendeeEditor