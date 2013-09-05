//@ sourceMappingURL=attendee.map
// Generated by CoffeeScript 1.6.1
(function() {
  var AttendeeEditor,
    _this = this;

  AttendeeEditor = (function() {
    var firstInputId;

    AttendeeEditor.prototype.fields = {
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
    };

    firstInputId = 'txtLastname';

    function AttendeeEditor(attendeeId) {
      var _this = this;
      this.attendeeId = attendeeId;
      this.joinEventData = function() {
        return AttendeeEditor.prototype.joinEventData.apply(_this, arguments);
      };
      this.getAttendeeData = function() {
        return AttendeeEditor.prototype.getAttendeeData.apply(_this, arguments);
      };
      this.updateInfoSaveButtonState = function() {
        return AttendeeEditor.prototype.updateInfoSaveButtonState.apply(_this, arguments);
      };
      this.isInputChanged = function(input) {
        return AttendeeEditor.prototype.isInputChanged.apply(_this, arguments);
      };
      this.infoInputChangedMark = function(input) {
        return AttendeeEditor.prototype.infoInputChangedMark.apply(_this, arguments);
      };
      this.allInfoInputsChangedMark = function() {
        return AttendeeEditor.prototype.allInfoInputsChangedMark.apply(_this, arguments);
      };
      this.infoInputKeyPressed = function(event) {
        return AttendeeEditor.prototype.infoInputKeyPressed.apply(_this, arguments);
      };
      this.infoInputsEnable = function(enable) {
        return AttendeeEditor.prototype.infoInputsEnable.apply(_this, arguments);
      };
      this.btnCancelRegistration_clicked = function() {
        return AttendeeEditor.prototype.btnCancelRegistration_clicked.apply(_this, arguments);
      };
      this.btnRegister_clicked = function() {
        return AttendeeEditor.prototype.btnRegister_clicked.apply(_this, arguments);
      };
      this.btnFinishRegistration_clicked = function() {
        return AttendeeEditor.prototype.btnFinishRegistration_clicked.apply(_this, arguments);
      };
      this.btnSaveInfo_clicked = function(event) {
        return AttendeeEditor.prototype.btnSaveInfo_clicked.apply(_this, arguments);
      };
      this.btnCancel_clicked = function(event) {
        return AttendeeEditor.prototype.btnCancel_clicked.apply(_this, arguments);
      };
      this.btnBook_clicked = function(event) {
        return AttendeeEditor.prototype.btnBook_clicked.apply(_this, arguments);
      };
      this.prepareItemsList = function() {
        return AttendeeEditor.prototype.prepareItemsList.apply(_this, arguments);
      };
      this.preparePrice = function() {
        return AttendeeEditor.prototype.preparePrice.apply(_this, arguments);
      };
      this.hidePostRegistrationMessage = function() {
        return AttendeeEditor.prototype.hidePostRegistrationMessage.apply(_this, arguments);
      };
      this.showPostRegistrationMessage = function() {
        return AttendeeEditor.prototype.showPostRegistrationMessage.apply(_this, arguments);
      };
      this.register = function(callback) {
        return AttendeeEditor.prototype.register.apply(_this, arguments);
      };
      this.updateEventFreePlaces = function(eventId) {
        return AttendeeEditor.prototype.updateEventFreePlaces.apply(_this, arguments);
      };
      this.updateLocalAttendeeData = function() {
        return AttendeeEditor.prototype.updateLocalAttendeeData.apply(_this, arguments);
      };
      this.unbookEvent = function(evt) {
        return AttendeeEditor.prototype.unbookEvent.apply(_this, arguments);
      };
      this.bookEvent = function(evt) {
        return AttendeeEditor.prototype.bookEvent.apply(_this, arguments);
      };
      this.fillEventActions = function(evt) {
        return AttendeeEditor.prototype.fillEventActions.apply(_this, arguments);
      };
      this.fillEventsActions = function() {
        return AttendeeEditor.prototype.fillEventsActions.apply(_this, arguments);
      };
      this.fetchEvents = function(callback) {
        return AttendeeEditor.prototype.fetchEvents.apply(_this, arguments);
      };
      this.fetchEventFreePlaces = function(callback) {
        return AttendeeEditor.prototype.fetchEventFreePlaces.apply(_this, arguments);
      };
      this.saveAttendeeInfo = function(callback) {
        return AttendeeEditor.prototype.saveAttendeeInfo.apply(_this, arguments);
      };
      this.createAttendee = function(callback) {
        return AttendeeEditor.prototype.createAttendee.apply(_this, arguments);
      };
      this.fetchAttendee = function() {
        return AttendeeEditor.prototype.fetchAttendee.apply(_this, arguments);
      };
      this.attendeeFetched = false;
      this.eventsFetched = false;
      this.attendee = {
        'attended_events': []
      };
      this.dvEvents = document.getElementById('dvEvents');
      this.btnSaveInfo = document.getElementById('btnSaveInfo');
      this.btnFinishRegistration = document.getElementById('btnFinishRegistration');
      document.getElementById(firstInputId).focus();
      this.btnSaveInfo.onclick = this.btnSaveInfo_clicked;
      this.btnFinishRegistration.onclick = this.btnFinishRegistration_clicked;
      document.getElementById('btnRegister').onclick = this.btnRegister_clicked;
      document.getElementById('btnCancelRegistration').onclick = this.btnCancelRegistration_clicked;
      this.tbEvents = Sizzle('#tbEvents')[0];
      this.initInputEvents();
      this.fetchEventFreePlaces(function() {
        if (_this.attendeeId != null) {
          _this.fetchAttendee();
          return _this.fetchEvents();
        } else {
          return _this.dvEvents.style.display = 'none';
        }
      });
    }

    AttendeeEditor.prototype.fetchAttendee = function() {
      var request,
        _this = this;
      request = new XMLHttpRequest();
      request.onreadystatechange = function() {
        var response;
        if (request.readyState === 4) {
          response = JSON.parse(request.responseText);
          _this.attendee = response.attendee;
          _this.attendeeFetched = true;
          setTimeout(_this.fillEventsActions, 1);
          return setTimeout((function() {
            return _this.fillAttendeeDetails(_this.attendee, 1);
          }));
        }
      };
      request.open('GET', "/attendees?id=" + this.attendeeId, true);
      return request.send(null);
    };

    AttendeeEditor.prototype.createAttendee = function(callback) {
      var rqCA,
        _this = this;
      this.btnSaveInfo.style.display = 'none';
      Sizzle('#imgSaveLoader')[0].style.display = 'inline';
      rqCA = new XMLHttpRequest();
      rqCA.onreadystatechange = function() {
        var response;
        if (rqCA.readyState !== 4) {
          return;
        }
        response = JSON.parse(rqCA.responseText);
        _this.attendee = response.attendee;
        _this.attendeeId = _this.attendee._id;
        _this.attendeeFetched = true;
        if (callback != null) {
          setTimeout(callback, 1);
        }
        return setTimeout(_this.fillEventsActions, 1);
      };
      rqCA.open('POST', '/attendees');
      return rqCA.send(null);
    };

    AttendeeEditor.prototype.saveAttendeeInfo = function(callback) {
      var rqSAI,
        _this = this;
      this.btnSaveInfo.style.display = 'none';
      Sizzle('#imgSaveLoader')[0].style.display = 'inline';
      this.infoInputsEnable(false);
      rqSAI = new XMLHttpRequest();
      rqSAI.onreadystatechange = function() {
        if (rqSAI.readyState !== 4) {
          return;
        }
        _this.btnSaveInfo.style.display = 'inline';
        Sizzle('#imgSaveLoader')[0].style.display = 'none';
        _this.infoInputsEnable(true);
        _this.updateLocalAttendeeData();
        _this.allInfoInputsChangedMark();
        return setTimeout(callback, 1);
      };
      rqSAI.open('PUT', "/attendees?id=" + this.attendee._id, true);
      rqSAI.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      return rqSAI.send(this.getAttendeeData());
    };

    AttendeeEditor.prototype.fetchEventFreePlaces = function(callback) {
      var request,
        _this = this;
      request = new XMLHttpRequest();
      request.onreadystatechange = function() {
        var response;
        if (request.readyState === 4) {
          response = JSON.parse(request.responseText);
          _this.eventsFreePlaces = response.events;
          _this.fillEventsFreePlaces(_this.eventsFreePlaces);
          if (callback != null) {
            return callback();
          }
        }
      };
      request.open('GET', '/events?type=free_places', true);
      return request.send(null);
    };

    AttendeeEditor.prototype.fetchEvents = function(callback) {
      var request,
        _this = this;
      request = new XMLHttpRequest();
      request.onreadystatechange = function() {
        var response;
        if (request.readyState === 4) {
          response = JSON.parse(request.responseText);
          _this.events = response.events;
          _this.eventsFetched = true;
          setTimeout(_this.fillEventsActions, 1);
          if (callback != null) {
            return callback();
          }
        }
      };
      request.open('GET', '/events', true);
      return request.send(null);
    };

    AttendeeEditor.prototype.fillAttendeeDetails = function(attendee) {
      var input, inputId, objectKey, _ref, _results;
      _ref = this.fields;
      _results = [];
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if ((input != null) && (this.attendee[objectKey] != null)) {
          _results.push(this.setInputValue(input, this.attendee[objectKey]));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    AttendeeEditor.prototype.fillEventsFreePlaces = function(events) {
      var evt, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = events.length; _i < _len; _i++) {
        evt = events[_i];
        _results.push(this.fillEventFreePlaces(evt));
      }
      return _results;
    };

    AttendeeEditor.prototype.fillEventFreePlaces = function(evt) {
      var span;
      console.log(evt);
      this.getEventElement('spNoLimit', evt).style.display = 'none';
      this.getEventElement('spFreePlaces', evt).style.display = 'none';
      this.getEventElement('spNoFreePlaces', evt).style.display = 'none';
      if (evt.free_places == null) {
        span = this.getEventElement('spNoLimit', evt);
      } else {
        if (evt.free_places > 0) {
          span = this.getEventElement('spFreePlaces', evt);
          span.textContent = evt.free_places;
        } else {
          span = this.getEventElement('spNoFreePlaces', evt);
        }
      }
      return span.style.display = 'block';
    };

    AttendeeEditor.prototype.fillEventsActions = function() {
      var evt, _i, _len, _ref;
      if (!this.attendeeFetched || !this.eventsFetched) {
        console.log("Attendee fetched: " + this.attendeeFetched + ", events fetched: " + this.eventsFetched);
        return;
      }
      this.joinEventData();
      this.setDefaultActions = this.attendee.attended_events.length === 0;
      _ref = this.events;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        evt = _ref[_i];
        this.fillEventActions(evt);
      }
      if (this.setDefaultActions) {
        return this.setDefaultActions = false;
      }
    };

    AttendeeEditor.prototype.fillEventActions = function(evt) {
      var btnBook, btnCancel, e, item, spBooked, spPaid, _i, _j, _len, _len1, _ref, _ref1;
      btnCancel = this.getEventElement('btnCancel', evt);
      btnBook = this.getEventElement('btnBook', evt);
      spBooked = this.getEventElement('spBooked', evt);
      spPaid = this.getEventElement('spPaid', evt);
      btnBook.onclick = this.btnBook_clicked;
      btnCancel.onclick = this.btnCancel_clicked;
      _ref = [btnCancel, btnBook, spBooked, spPaid];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        item.style.display = 'none';
      }
      if (evt['booked'] || evt['paid']) {
        btnCancel.style.display = 'inline';
        if (evt['paid']) {
          return spPaid.style.display = 'inline';
        } else {
          return spBooked.style.display = 'inline';
        }
      } else {
        if (evt.limit != null) {
          _ref1 = this.eventsFreePlaces;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            e = _ref1[_j];
            if (e._id === evt._id) {
              if ((e.free_places != null) && e.free_places <= 0) {
                return;
              }
            }
          }
        }
        btnBook.style.display = 'inline';
        if (this.setDefaultActions && evt["default"]) {
          return this.bookEvent(evt);
        }
      }
    };

    AttendeeEditor.prototype.bookEvent = function(evt) {
      var data, loader, request,
        _this = this;
      loader = this.getEventElement('imgLoader', evt);
      this.getEventElement('btnBook', evt).style.display = 'none';
      loader.style.display = 'inline';
      request = new XMLHttpRequest();
      request.onreadystatechange = function() {
        var error, response;
        if (request.readyState !== 4) {
          return;
        }
        loader.style.display = 'none';
        response = JSON.parse(request.responseText);
        if (response['success']) {
          _this.getEventElement('spBooked', evt).style.display = 'inline';
          _this.getEventElement('btnCancel', evt).style.display = 'inline';
          evt['booked'] = true;
        } else {
          error = response.error;
          if (error.type === 'outofplaces') {

          } else {
            alert('Відбулась невідома помилка, бронювання не вдалось');
          }
        }
        return _this.updateEventFreePlaces(evt._id);
      };
      request.open('PUT', '/attendee_event', true);
      request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      data = "eid=" + evt._id + "&aid=" + this.attendeeId;
      return request.send(data);
    };

    AttendeeEditor.prototype.unbookEvent = function(evt) {
      var data, loader, request,
        _this = this;
      loader = this.getEventElement('imgLoader', evt);
      this.getEventElement('btnCancel', evt).style.display = 'none';
      this.getEventElement('spBooked', evt).style.display = 'none';
      loader.style.display = 'inline';
      request = new XMLHttpRequest();
      request.onreadystatechange = function() {
        if (request.readyState !== 4) {
          return;
        }
        delete evt.paid;
        delete evt.booked;
        _this.updateEventFreePlaces(evt._id);
        _this.fillEventActions(evt);
        return loader.style.display = 'none';
      };
      request.open('DELETE', '/attendee_event');
      request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      data = "eid=" + evt._id + "&aid=" + this.attendeeId;
      return request.send(data);
    };

    AttendeeEditor.prototype.updateLocalAttendeeData = function() {
      var input, inputId, objectKey, _ref, _results;
      _ref = this.fields;
      _results = [];
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        _results.push(this.attendee[objectKey] = this.getInputValue(input));
      }
      return _results;
    };

    AttendeeEditor.prototype.updateEventFreePlaces = function(eventId) {
      var rqUEFP,
        _this = this;
      rqUEFP = new XMLHttpRequest();
      rqUEFP.onreadystatechange = function() {
        var current_evt, e, response, _i, _len, _ref;
        if (rqUEFP.readyState !== 4) {
          return;
        }
        response = JSON.parse(rqUEFP.responseText);
        current_evt = response.event;
        _ref = _this.eventsFreePlaces;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          e = _ref[_i];
          if (e._id = current_evt._id) {
            e.free_places = current_evt.free_places;
          }
        }
        return _this.fillEventFreePlaces(current_evt);
      };
      rqUEFP.open('GET', "/events?type=free_places&id=" + eventId, true);
      return rqUEFP.send(null);
    };

    AttendeeEditor.prototype.register = function(callback) {
      var rqRegister,
        _this = this;
      rqRegister = new XMLHttpRequest();
      rqRegister.onreadystatechange = function() {
        if (rqRegister.readyState !== 4) {
          return;
        }
        if (callback != null) {
          return callback();
        }
      };
      rqRegister.open('PUT', "/attendees?id=" + this.attendee._id + "&registered=True", true);
      return rqRegister.send(null);
    };

    AttendeeEditor.prototype.showPostRegistrationMessage = function() {
      this.dvEvents.style.display = 'none';
      this.infoInputsEnable(false);
      document.getElementById('dvModalPlaceholder').style.display = 'block';
      document.getElementById('dvPostRegistrationMessage').style.display = 'block';
      this.preparePrice();
      return this.prepareItemsList();
    };

    AttendeeEditor.prototype.hidePostRegistrationMessage = function() {
      this.dvEvents.style.display = 'block';
      this.infoInputsEnable(true);
      document.getElementById('dvModalPlaceholder').style.display = 'none';
      return document.getElementById('dvPostRegistrationMessage').style.display = 'none';
    };

    AttendeeEditor.prototype.preparePrice = function() {
      var evt, price, _i, _len, _ref;
      price = 0;
      _ref = this.events;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        evt = _ref[_i];
        if ((evt.price != null) && evt['booked'] && !evt['paid']) {
          price += evt['price'];
        }
      }
      return document.getElementById('spPrice').textContent = price;
    };

    AttendeeEditor.prototype.prepareItemsList = function() {
      var evt, li, ul, _i, _len, _ref, _results;
      ul = document.getElementById('itemsList');
      while (ul.hasChildNodes()) {
        ul.removeChild(ul.lastChild);
      }
      _ref = this.events;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        evt = _ref[_i];
        if (!(evt['item_caption'] != null)) {
          continue;
        }
        if (!evt['booked']) {
          continue;
        }
        if (evt['paid'] && this.attendee.registered) {
          continue;
        }
        li = document.createElement('li');
        li.textContent = evt.item_caption;
        _results.push(ul.appendChild(li));
      }
      return _results;
    };

    AttendeeEditor.prototype.btnBook_clicked = function(event) {
      var btnBook, e, eventId, evt, _i, _len, _ref;
      btnBook = event.currentTarget;
      eventId = this.getEventIdFromEvent(event);
      evt = null;
      _ref = this.events;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        if (e['_id'] === eventId) {
          evt = e;
        }
      }
      return this.bookEvent(evt);
    };

    AttendeeEditor.prototype.btnCancel_clicked = function(event) {
      var btnCancel, e, eventId, evt, _i, _len, _ref;
      btnCancel = event.currentTarget;
      eventId = this.getEventIdFromEvent(event);
      _ref = this.events;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        if (e['_id'] === eventId) {
          evt = e;
        }
      }
      if (confirm("Ви впевнені, що бажаєте відмінити реєстрацію на '" + evt.caption + "'?")) {
        return this.unbookEvent(evt);
      }
    };

    AttendeeEditor.prototype.btnSaveInfo_clicked = function(event) {
      var _this = this;
      if (this.attendeeId == null) {
        return this.createAttendee(function() {
          return _this.saveAttendeeInfo(function() {
            return _this.fetchEvents(function() {
              return document.getElementById('dvEvents').style.display = 'block';
            });
          });
        });
      } else {
        return this.saveAttendeeInfo();
      }
    };

    AttendeeEditor.prototype.btnFinishRegistration_clicked = function() {
      return this.saveAttendeeInfo(this.showPostRegistrationMessage);
    };

    AttendeeEditor.prototype.btnRegister_clicked = function() {
      var _this = this;
      return this.register(function() {
        return window.location.href = '/';
      });
    };

    AttendeeEditor.prototype.btnCancelRegistration_clicked = function() {
      this.btnFinishRegistration.style.display = 'block';
      return this.hidePostRegistrationMessage();
    };

    AttendeeEditor.prototype.infoInputsEnable = function(enable) {
      var input, inputId, objectKey, _ref, _results;
      _ref = this.fields;
      _results = [];
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if (enable) {
          _results.push(input.removeAttribute('disabled'));
        } else {
          _results.push(input.setAttribute('disabled', 'disabled'));
        }
      }
      return _results;
    };

    AttendeeEditor.prototype.initInputEvents = function() {
      var input, inputId, objectKey, _ref, _results;
      _ref = this.fields;
      _results = [];
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if (input != null) {
          switch (input.type) {
            case 'text':
            case 'tel':
              _results.push(input.onkeyup = this.infoInputKeyPressed);
              break;
            case 'checkbox':
              _results.push(input.onchange = this.infoInputKeyPressed);
              break;
            default:
              _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    AttendeeEditor.prototype.infoInputKeyPressed = function(event) {
      var input;
      input = event.currentTarget;
      this.infoInputChangedMark(input);
      return this.updateInfoSaveButtonState();
    };

    AttendeeEditor.prototype.allInfoInputsChangedMark = function() {
      var input, inputId, objectKey, _ref;
      _ref = this.fields;
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        this.infoInputChangedMark(input);
      }
      return this.updateInfoSaveButtonState();
    };

    AttendeeEditor.prototype.infoInputChangedMark = function(input) {
      if (this.isInputChanged(input)) {
        return input.style.backgroundColor = '#E0FFE0';
      } else {
        return input.style.backgroundColor = 'white';
      }
    };

    AttendeeEditor.prototype.isInputChanged = function(input) {
      var fieldId, fieldValue, inputValue;
      fieldId = this.fields[input.id];
      fieldValue = this.attendee[fieldId];
      if (fieldValue == null) {
        fieldValue = '';
      }
      inputValue = this.getInputValue(input);
      return fieldValue !== inputValue;
    };

    AttendeeEditor.prototype.updateInfoSaveButtonState = function() {
      var input, inputId, objectKey, _ref;
      _ref = this.fields;
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if (this.isInputChanged(input)) {
          this.btnSaveInfo.removeAttribute('disabled');
          return;
        }
      }
      return this.btnSaveInfo.setAttribute('disabled', 'disabled');
    };

    AttendeeEditor.prototype.getAttendeeData = function() {
      var attendeeValue, input, inputId, objectKey, resultArray, value, _ref;
      resultArray = [];
      _ref = this.fields;
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        value = this.getInputValue(input);
        attendeeValue = this.attendee[objectKey];
        if (attendeeValue == null) {
          attendeeValue = '';
        }
        if (value === attendeeValue) {
          continue;
        }
        resultArray.push("" + objectKey + "=" + value);
      }
      return resultArray.join('&');
    };

    AttendeeEditor.prototype.joinEventData = function() {
      var a_evt, attr, evt, _i, _len, _ref, _results;
      _ref = this.attendee['attended_events'];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a_evt = _ref[_i];
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = this.events;
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            evt = _ref1[_j];
            if (evt['_id'] === a_evt['_id']) {
              _results1.push((function() {
                var _k, _len2, _ref2, _results2;
                _ref2 = ['booked', 'paid'];
                _results2 = [];
                for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
                  attr = _ref2[_k];
                  _results2.push(evt[attr] = a_evt[attr]);
                }
                return _results2;
              })());
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    AttendeeEditor.prototype.getInputValue = function(input) {
      switch (input.type) {
        case 'text':
        case 'tel':
          return input.value;
        case 'checkbox':
          return input.checked;
      }
    };

    AttendeeEditor.prototype.setInputValue = function(input, value) {
      switch (input.type) {
        case 'text':
        case 'tel':
          return input.value = value;
        case 'checkbox':
          return input.checked = value;
      }
    };

    AttendeeEditor.prototype.getEventElement = function(name, evt) {
      return Sizzle("[eventId=" + evt._id + "][name=" + name + "]", this.tbEvents)[0];
    };

    AttendeeEditor.prototype.getEventIdFromEvent = function(event) {
      var target;
      target = event.target;
      return target.getAttribute('eventId');
    };

    return AttendeeEditor;

  })();

  window.onload = function() {
    var attendeeId;
    attendeeId = window.attendeeId;
    return window.editor = new AttendeeEditor(attendeeId);
  };

}).call(this);
