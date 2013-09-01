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

	constructor: (@attendeeId) ->
		@attendeeFetched = false
		@eventsFetched = false
		@attendee = {'attended_events': []}

		@dvEvents = document.getElementById 'dvEvents'
		@btnSaveInfo = document.getElementById('btnSaveInfo')
		@btnFinishRegistration = document.getElementById('btnFinishRegistration')

		document.getElementById(firstInputId).focus()

		@btnSaveInfo.onclick = @btnSaveInfo_clicked
		@btnFinishRegistration.onclick = @btnFinishRegistration_clicked
		document.getElementById('btnRegister').onclick = @btnRegister_clicked
		document.getElementById('btnCancelRegistration').onclick = @btnCancelRegistration_clicked

		@tbEvents = Sizzle('#tbEvents')[0]
		@initInputEvents()
		@fetchEventFreePlaces()
		if @attendeeId?
			@fetchAttendee()
			@fetchEvents()
		else
			@dvEvents.style.display = 'none'

	fetchAttendee: () =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				response = JSON.parse(request.responseText)
				@attendee = response.attendee
				console.log @attendee
				@attendeeFetched = true
				setTimeout @fillEventsActions, 1
				setTimeout (() => 
					@fillAttendeeDetails @attendee
					, 1)
		request.open('GET', "/attendees?id=#{@attendeeId}", true)
		request.send(null)

	createAttendee: (callback) =>
		@btnSaveInfo.style.display = 'none'
		Sizzle('#imgSaveLoader')[0].style.display = 'inline'
		rqCA = new XMLHttpRequest()
		rqCA.onreadystatechange = () =>
			if rqCA.readyState != 4
				return
			response = JSON.parse(rqCA.responseText)
			@attendee = response.attendee
			@attendeeId = @attendee._id
			@attendeeFetched = true
			if callback?
				setTimeout callback, 1
			setTimeout @fillEventsActions, 1
		rqCA.open('POST', '/attendees')
		rqCA.send(null)

	saveAttendeeInfo: (callback) =>
		@btnSaveInfo.style.display = 'none'
		Sizzle('#imgSaveLoader')[0].style.display = 'inline'
		@infoInputsEnable(false)
		rqSAI = new XMLHttpRequest()
		rqSAI.onreadystatechange = () =>
			if rqSAI.readyState != 4
				return
			@btnSaveInfo.style.display = 'inline'
			Sizzle('#imgSaveLoader')[0].style.display = 'none'
			@infoInputsEnable(true)
			@updateLocalAttendeeData()
			@allInfoInputsChangedMark()
			setTimeout callback, 1
		rqSAI.open('PUT', "/attendees?id=#{@attendee._id}", true)
		rqSAI.setRequestHeader("Content-type","application/x-www-form-urlencoded");
		rqSAI.send(@getAttendeeData())

	fetchEventFreePlaces: () =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				response = JSON.parse(request.responseText)
				events = response.events
				@fillEventsFreePlaces(events)
		request.open('GET', '/events?type=free_places', true)
		request.send(null)

	fetchEvents: (callback) =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				response = JSON.parse(request.responseText)
				@events = response.events
				@eventsFetched = true
				setTimeout @fillEventsActions, 1
				if callback?
					callback()
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
			console.log "Attendee fetched: #{@attendeeFetched}, events fetched: #{@eventsFetched}"
			return
		@joinEventData()
		@setDefaultActions = (@attendee.attended_events.length == 0)
		console.log 'Filling event actions'
		for evt in @events
			@fillEventActions evt
		if @setDefaultActions
			@setDefaultActions = false

	fillEventActions: (evt) =>
		btnCancel = @getEventElement 'btnCancel', evt
		btnBook = @getEventElement 'btnBook', evt
		spBooked = @getEventElement 'spBooked', evt
		spPaid = @getEventElement 'spPaid', evt
		btnBook.onclick = @btnBook_clicked
		btnCancel.onclick = @btnCancel_clicked
		for item in [btnCancel, btnBook, spBooked, spPaid]
			item.style.display = 'none'		
		if evt['booked'] or evt['checked']
			btnCancel.style.display = 'inline'
			if evt['booked']
				spBooked.style.display = 'inline'
			else
				spPaid.style.display = 'inline'
		else
			btnBook.style.display = 'inline'
			if @setDefaultActions and evt.default
				@bookEvent evt

	bookEvent: (evt) =>
		loader = @getEventElement 'imgLoader', evt
		@getEventElement('btnBook', evt).style.display = 'none'
		loader.style.display = 'inline'
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState != 4
				return
			loader.style.display = 'none'
			response = JSON.parse(request.responseText)
			if response['success']
				@getEventElement('spBooked', evt).style.display = 'inline'
				@getEventElement('btnCancel', evt).style.display = 'inline'
				evt['booked'] = true
			else
				alert('Error!')
				console.log response.error
			@updateEventFreePlaces evt._id
		request.open('PUT', '/attendee_event', true)
		request.setRequestHeader("Content-type","application/x-www-form-urlencoded");
		data = "eid=#{evt._id}&aid=#{@attendeeId}"
		request.send(data)

	unbookEvent: (evt) =>
		loader = @getEventElement 'imgLoader', evt
		@getEventElement('btnCancel', evt).style.display = 'none'
		@getEventElement('spBooked', evt).style.display = 'none'
		loader.style.display = 'inline'
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState != 4
				return
			delete evt.checked
			delete evt.booked
			@fillEventActions(evt)
			@updateEventFreePlaces evt._id
			loader.style.display = 'none'
		request.open('DELETE', '/attendee_event')
		request.setRequestHeader("Content-type","application/x-www-form-urlencoded");
		data = "eid=#{evt._id}&aid=#{@attendeeId}"
		request.send(data)

	updateLocalAttendeeData: () =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			@attendee[objectKey] = input.value		

	updateEventFreePlaces: (eventId) =>
		rqUEFP = new XMLHttpRequest()
		rqUEFP.onreadystatechange = () =>
			if rqUEFP.readyState != 4
				return
			response = JSON.parse(rqUEFP.responseText)
			current_evt = response.event
			@fillEventFreePlaces current_evt
		rqUEFP.open('GET', "/events?type=free_places&id=#{eventId}", true)
		rqUEFP.send(null)

	register: (callback) =>
		rqRegister = new XMLHttpRequest()
		rqRegister.onreadystatechange = () =>
			if rqRegister.readyState != 4
				return
			if callback?
				callback()
		rqRegister.open('PUT', "/attendees?id=#{@attendee._id}&registered=True", true)
		rqRegister.send(null)

	showPostRegistrationMessage: () =>
		@dvEvents.style.display = 'none'
		@infoInputsEnable(false)
		document.getElementById('dvModalPlaceholder').style.display = 'block'
		document.getElementById('dvPostRegistrationMessage').style.display = 'block'
		@preparePrice()
		@prepareItemsList()

	hidePostRegistrationMessage: () =>
		@dvEvents.style.display = 'block'
		@infoInputsEnable(true)
		document.getElementById('dvModalPlaceholder').style.display = 'none'
		document.getElementById('dvPostRegistrationMessage').style.display = 'none'

	preparePrice: () =>
		price = 0
		for evt in @events when evt.price? and evt['booked']
			price += evt['price']
		document.getElementById('spPrice').textContent = price

	prepareItemsList: () =>
		ul = document.getElementById('itemsList')
		while ul.hasChildNodes()
			ul.removeChild ul.lastChild
		console.log @events
		for evt in @events when evt['item_caption']? and (evt['booked'] or evt['checked'])
			li = document.createElement('li')
			li.textContent = evt.item_caption
			ul.appendChild(li)

	btnBook_clicked: (event) =>
		btnBook = event.currentTarget		
		eventId = @getEventIdFromEvent event
		evt = null
		for e in @events when e['_id'] == eventId
			evt = e
		@bookEvent(evt)

	btnCancel_clicked: (event) =>
		btnCancel = event.currentTarget
		eventId = @getEventIdFromEvent event
		for e in @events when e['_id'] == eventId
			evt = e
		if confirm("Ви впевнені, що бажаєте відмінити реєстрацію на '#{evt.caption}'?")
			@unbookEvent(evt)

	btnSaveInfo_clicked: (event) =>
		if not @attendeeId?
			@createAttendee(() =>
				@saveAttendeeInfo(() =>
					@fetchEvents(() =>
						document.getElementById('dvEvents').style.display = 'block'
					)
				)
			)			
		else
			@saveAttendeeInfo()

	btnFinishRegistration_clicked: () =>
		@btnFinishRegistration.style.display = 'None'
		@saveAttendeeInfo(@showPostRegistrationMessage)

	btnRegister_clicked: () =>
		@register(() =>
			window.location.href = '/')

	btnCancelRegistration_clicked: () =>
		@btnFinishRegistration.style.display = 'block'
		@hidePostRegistrationMessage()


	infoInputsEnable: (enable) =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if enable
				input.removeAttribute('disabled')
			else
				input.setAttribute('disabled', 'disabled')

	initInputEvents: () ->
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if input?
				input.onkeyup = @infoInputKeyPressed

	infoInputKeyPressed: (event) =>
		input = event.currentTarget
		@infoInputChangedMark(input)
		@updateInfoSaveButtonState()

	allInfoInputsChangedMark: () =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			@infoInputChangedMark(input)
		@updateInfoSaveButtonState()

	infoInputChangedMark: (input) =>
		if @isInputChanged(input)
			input.style.backgroundColor = '#E0FFE0'
		else
			input.style.backgroundColor = 'white'

	isInputChanged: (input) =>
		fieldId = @fields[input.id]
		fieldValue = @attendee[fieldId]
		if not fieldValue?
			fieldValue = ''
		return fieldValue != input.value

	updateInfoSaveButtonState: () =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			if @isInputChanged(input)
				@btnSaveInfo.removeAttribute('disabled')
				return
		@btnSaveInfo.setAttribute('disabled', 'disabled')

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

	joinEventData: () =>
		for a_evt in @attendee['attended_events']
			for evt in @events when evt['_id'] == a_evt['_id']
				for attr in ['booked', 'checked']
					evt[attr] = a_evt[attr]

	getEventElement: (name, evt) ->
		return Sizzle("[eventId=#{evt._id}][name=#{name}]", @tbEvents)[0]

	getEventIdFromEvent: (event) ->
		target = event.target
		return target.getAttribute('eventId')

window.onload = () ->
	attendeeId = window.attendeeId
	window.editor = new AttendeeEditor(attendeeId)