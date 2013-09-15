class AttendeeEditor

	fields: {
		'txtFirstname': 'firstname',
		'txtLastname': 'lastname',
		'txtMiddlename': 'middlename',
		'txtCity': 'city',
		'txtRegion': 'region',
		'txtPhone': 'phone',
		'txtPosition': 'position',
		'txtRank': 'rank',
		'txtOrganization': 'organization',
		'cbDelegate': 'delegate'
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
		@fetchEventFreePlaces(() =>
			if @attendeeId?
				@fetchAttendee()
				@fetchEvents()
			else
				@dvEvents.style.display = 'none'
			)

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

	fetchEventFreePlaces: (callback) =>
		request = new XMLHttpRequest()
		request.onreadystatechange = () =>
			if request.readyState == 4
				response = JSON.parse(request.responseText)
				@eventsFreePlaces = response.events
				@fillEventsFreePlaces(@eventsFreePlaces)
				if callback?
					callback()
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
				@setInputValue input, @attendee[objectKey]

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
		@setDefaultActions = not @attendee.registered
		for evt in @events
			@fillEventActions evt
		@setDefaultActions = false

	fillEventActions: (evt) =>
		console.log evt
		btnCancel = @getEventElement 'btnCancel', evt
		btnBook = @getEventElement 'btnBook', evt
		spBooked = @getEventElement 'spBooked', evt
		spPaid = @getEventElement 'spPaid', evt
		btnBook.onclick = @btnBook_clicked
		btnCancel.onclick = @btnCancel_clicked
		for item in [btnCancel, btnBook, spBooked, spPaid]
			item.style.display = 'none'

		if evt['booked'] and not evt['paid']
			btnCancel.style.display = 'inline'
			spBooked.style.display = 'inline'
		else if evt['paid']
			spPaid.style.display = 'inline'
		else
			if evt.limit?
				for e in @eventsFreePlaces when e._id == evt._id
					if e.free_places? and e.free_places <= 0
						return
			btnBook.style.display = 'inline'
			if @setDefaultActions and evt.default
				@bookEvent evt
		@updatePrice()

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
				evt['booked'] = true
				@fillEventActions(evt)
			else
				error = response.error
				if error.type == 'outofplaces'
					# alert('Пробачте, місць не залишилось')
				else
					alert('Відбулась невідома помилка, бронювання не вдалось')
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
			delete evt.paid
			delete evt.booked
			@updateEventFreePlaces evt._id
			@fillEventActions(evt)
			loader.style.display = 'none'
		request.open('DELETE', "/attendee_event?eid=#{evt._id}&aid=#{@attendeeId}", true)
		request.send(null)

	updateLocalAttendeeData: () =>
		for inputId, objectKey of @fields
			input = document.getElementById(inputId)
			@attendee[objectKey] = @getInputValue input

	updateEventFreePlaces: (eventId) =>
		rqUEFP = new XMLHttpRequest()
		rqUEFP.onreadystatechange = () =>
			if rqUEFP.readyState != 4
				return
			response = JSON.parse(rqUEFP.responseText)
			current_evt = response.event
			for e in @eventsFreePlaces when e._id = current_evt._id
				e.free_places = current_evt.free_places
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
		rqRegister.open('PUT', "/attendees?id=#{@attendee._id}&registered=True&cash=#{@price}", true)
		rqRegister.send(null)

	showPostRegistrationMessage: () =>
		@dvEvents.style.display = 'none'
		@infoInputsEnable(false)
		document.getElementById('dvModalPlaceholder').style.display = 'block'
		document.getElementById('dvPostRegistrationMessage').style.display = 'block'
		@updateRegistrationPrice()
		@prepareItemsList()

	hidePostRegistrationMessage: () =>
		@dvEvents.style.display = 'block'
		@infoInputsEnable(true)
		document.getElementById('dvModalPlaceholder').style.display = 'none'
		document.getElementById('dvPostRegistrationMessage').style.display = 'none'

	calculatePrice: () =>
		price = 0
		for evt in @events when evt.price? and evt['booked'] and not evt['paid']
			price += evt['price']
		return price

	updatePrice: () =>
		price = @calculatePrice()
		document.getElementById('spTotalPrice').textContent = price

	updateRegistrationPrice: () =>
		@price = @calculatePrice()
		document.getElementById('spPrice').textContent = @price

	prepareItemsList: () =>
		ul = document.getElementById('itemsList')
		while ul.hasChildNodes()
			ul.removeChild ul.lastChild
		for evt in @events when evt['item_caption']?
			if not evt['booked']
				continue
			if evt['paid'] and @attendee.registered
				continue
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
				switch input.type
					when 'text', 'tel'
						input.onkeyup = @infoInputKeyPressed
					when 'checkbox'
						input.onchange = @infoInputKeyPressed

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
		inputValue = @getInputValue input
		return fieldValue != inputValue

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
			value = @getInputValue input
			attendeeValue = @attendee[objectKey]
			if not attendeeValue?
				attendeeValue = ''
			if value == attendeeValue
				continue
			resultArray.push "#{objectKey}=#{value}"
		return resultArray.join('&')

	joinEventData: () =>
		for a_evt in @attendee['attended_events']
			for evt in @events when evt['_id'] == a_evt['_id']
				for attr in ['booked', 'paid']
					evt[attr] = a_evt[attr]

	getInputValue: (input) ->
		switch input.type
			when 'text', 'tel'
				return input.value
			when 'checkbox'
				return input.checked

	setInputValue: (input, value) ->
		switch input.type
			when 'text', 'tel'
				input.value = value
			when 'checkbox'
				input.checked = value

	getEventElement: (name, evt) ->
		return Sizzle("[eventId=#{evt._id}][name=#{name}]", @tbEvents)[0]

	getEventIdFromEvent: (event) ->
		target = event.target
		return target.getAttribute('eventId')

window.onload = () ->
	attendeeId = window.attendeeId
	window.editor = new AttendeeEditor(attendeeId)