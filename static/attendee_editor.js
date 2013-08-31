// Generated by CoffeeScript 1.4.0
(function() {
  var AttendeeEditor,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  AttendeeEditor = (function() {
    var firstInputId;

    AttendeeEditor.prototype.fields = {
      'txtFirstname': 'firstname',
      'txtLastname': 'lastname',
      'txtMiddlename': 'middlename',
      'txtCity': 'city',
      'txtPhone': 'personal_phone',
      'txtPosition': 'position',
      'txtOrganization': 'organization'
    };

    firstInputId = 'txtLastname';

    function AttendeeEditor(attendee) {
      this.attendee = attendee;
      this.getAttendeeData = __bind(this.getAttendeeData, this);

      this.getEventsData = __bind(this.getEventsData, this);

      this.infoInputKeyPressed = __bind(this.infoInputKeyPressed, this);

      this.hide = __bind(this.hide, this);

      this.clear = __bind(this.clear, this);

      this.fill = __bind(this.fill, this);

      this.fetch = __bind(this.fetch, this);

      this.show = __bind(this.show, this);

      this.editorContainer = document.getElementById('attendeeEditorContainer');
      this.initInputEvents();
    }

    AttendeeEditor.prototype.show = function() {
      this.editorContainer.style.display = 'block';
      this.clear();
      if (this.attendee._id != null) {
        this.fetch();
      }
      return document.getElementById(firstInputId).focus();
    };

    AttendeeEditor.prototype.fetch = function() {
      var _this = this;
      this.request = new XMLHttpRequest();
      this.request.onreadystatechange = function() {
        var response;
        if (_this.request.readyState === 4) {
          response = JSON.parse(_this.request.responseText);
          _this.attendee = response.attendee;
          _this.events = response.events;
          return _this.fill();
        }
      };
      this.request.open('GET', "/attendees?id=" + this.attendee._id.$oid, true);
      return this.request.send(null);
    };

    AttendeeEditor.prototype.initInputEvents = function() {
      var input, inputId, objectKey, _ref, _results;
      _ref = this.fields;
      _results = [];
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if (input != null) {
          _results.push(input.onkeyup = this.infoInputKeyPressed);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    AttendeeEditor.prototype.clearInputEvents = function() {
      var input, inputId, objectKey, _ref, _results;
      _ref = this.fields;
      _results = [];
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if (input != null) {
          _results.push(input.onkeyup = null);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    AttendeeEditor.prototype.fill = function() {
      var evt, input, inputId, objectKey, spAttendees, spLimit, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
      _ref = this.fields;
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if (input != null) {
          input.value = this.attendee[objectKey];
        }
      }
      _ref1 = this.attendee['attended_events'];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        evt = _ref1[_i];
        document.getElementById(evt['id']).checked = true;
      }
      _ref2 = this.events;
      _results = [];
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        evt = _ref2[_j];
        spLimit = document.getElementById("spLimit_" + evt._id.$oid);
        spAttendees = document.getElementById("spAttendees_" + evt._id.$oid);
        spLimit.style.color = '#000';
        spAttendees.style.color = '#000';
        if (evt.limit != null) {
          spLimit.textContent = evt.limit;
          spAttendees.textContent = evt.attendees;
          if (evt.attendees >= evt.limit) {
            spAttendees.style.color = '#F00';
            _results.push(spLimit.style.color = '#F00');
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    AttendeeEditor.prototype.clear = function() {
      var checkbox, input, inputId, objectKey, _i, _len, _ref, _ref1, _results;
      _ref = this.fields;
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        input.value = '';
        input.style.backgroundColor = 'white';
      }
      _ref1 = document.getElementsByName('events');
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        checkbox = _ref1[_i];
        _results.push(checkbox.checked = false);
      }
      return _results;
    };

    AttendeeEditor.prototype.hide = function() {
      this.editorContainer.style.display = 'none';
      return this.clearInputEvents();
    };

    AttendeeEditor.prototype.infoInputKeyPressed = function(event) {
      var fieldId, fieldValue, input;
      input = event.currentTarget;
      fieldId = this.fields[input.id];
      fieldValue = this.attendee[fieldId];
      if (!(fieldValue != null)) {
        fieldValue = '';
      }
      if (fieldValue !== input.value) {
        return input.style.backgroundColor = '#E0FFE0';
      } else {
        return input.style.backgroundColor = 'white';
      }
    };

    AttendeeEditor.prototype.getEventsData = function() {
      var cb, eventCheckboxes, result;
      eventCheckboxes = document.getElementsByName('events');
      result = [
        (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = eventCheckboxes.length; _i < _len; _i++) {
            cb = eventCheckboxes[_i];
            if (cb.checked) {
              _results.push(cb.id);
            }
          }
          return _results;
        })()
      ];
      return result.join(',');
    };

    AttendeeEditor.prototype.getAttendeeData = function() {
      var attendeeValue, input, inputId, objectKey, resultArray, _ref;
      resultArray = [];
      _ref = this.fields;
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        attendeeValue = this.attendee[objectKey];
        if (!(attendeeValue != null)) {
          attendeeValue = '';
        }
        if (input.value === attendeeValue) {
          continue;
        }
        resultArray.push("" + objectKey + "=" + input.value);
      }
      return resultArray.join('&');
    };

    return AttendeeEditor;

  })();

  window.AttendeeEditor = AttendeeEditor;

}).call(this);