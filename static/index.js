// Generated by CoffeeScript 1.4.0
(function() {
  var AttendeeEditor, Index, search,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Index = (function() {

    function Index() {
      this.attendeeRowClicked = __bind(this.attendeeRowClicked, this);

      this.createAttendeeRow = __bind(this.createAttendeeRow, this);

      this.populateSearchResults = __bind(this.populateSearchResults, this);

      this.clearSearchResults = __bind(this.clearSearchResults, this);

      this.processSearchRequest = __bind(this.processSearchRequest, this);

      this.searchRequested = __bind(this.searchRequested, this);

      var searchBoxInput, searchbox;
      this.searching = false;
      this.nextSearch = null;
      this.table = document.getElementById('searchResultsTable');
      this.tableBody = document.getElementById('searchResultsBody');
      searchBoxInput = document.getElementById('searchBox');
      searchBoxInput.focus();
      searchbox = new window.SearchBox(searchBoxInput, this.searchRequested);
    }

    Index.prototype.searchRequested = function(searchTerm) {
      var term,
        _this = this;
      if (searchTerm === '') {
        this.nextSearch = null;
        this.searchRequest.abort();
        this.searching = false;
        document.getElementById('imgSearchLoader').style.visibility = 'hidden';
        this.clearSearchResults();
        return;
      }
      document.getElementById('imgSearchLoader').style.visibility = 'visible';
      if (this.searching) {
        term = searchTerm;
        this.nextSearch = function() {
          return _this.searchRequested(term);
        };
        return;
      }
      this.searching = true;
      this.searchRequest = new XMLHttpRequest();
      this.searchRequest.onreadystatechange = this.processSearchRequest;
      this.searchRequest.open('GET', "/attendees?s=" + searchTerm, true);
      this.searchRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      return this.searchRequest.send(null);
    };

    Index.prototype.processSearchRequest = function() {
      var result;
      if (this.searchRequest.readyState === 4 && this.searchRequest.status === 200) {
        result = JSON.parse(this.searchRequest.responseText);
        this.clearSearchResults();
        this.populateSearchResults(result);
        this.searching = false;
        document.getElementById('imgSearchLoader').style.visibility = 'hidden';
        if (this.nextSearch != null) {
          this.nextSearch();
          return this.nextSearch = null;
        }
      }
    };

    Index.prototype.clearSearchResults = function() {
      var _results;
      this.table.style.visibility = 'hidden';
      _results = [];
      while (this.tableBody.firstChild) {
        _results.push(this.tableBody.removeChild(this.tableBody.firstChild));
      }
      return _results;
    };

    Index.prototype.populateSearchResults = function(results) {
      var attendee, attendee_count, attendees, frag, _fn, _i, _len,
        _this = this;
      this.tableBody = document.getElementById('searchResultsBody');
      frag = document.createDocumentFragment();
      attendees = results['attendees'];
      attendee_count = results['count'];
      if (attendee_count > 0) {
        _fn = function(attendee) {
          return frag.appendChild(_this.createAttendeeRow(attendee));
        };
        for (_i = 0, _len = attendees.length; _i < _len; _i++) {
          attendee = attendees[_i];
          _fn(attendee);
        }
      }
      this.tableBody.appendChild(frag);
      if (attendee_count > 0) {
        document.getElementById('dvNoneFound').style.display = 'none';
        document.getElementById('dvFoundCount').style.display = 'block';
        document.getElementById('spFoundCount').textContent = attendee_count;
      } else {
        document.getElementById('dvNoneFound').style.display = 'block';
        document.getElementById('dvFoundCount').style.display = 'none';
      }
      return this.table.style.visibility = 'visible';
    };

    Index.prototype.createAttendeeRow = function(attendee) {
      var attendeeName, button, td, tr,
        _this = this;
      tr = document.createElement('tr');
      this.appendCell(tr, attendee.city);
      attendeeName = "" + attendee.lastname + " " + attendee.firstname + " " + attendee.middlename;
      this.appendCell(tr, attendeeName);
      td = document.createElement('td');
      button = document.createElement('input');
      button.type = 'button';
      button.value = 'Зареєструвати';
      button.onclick = function() {
        return _this.attendeeRowClicked(attendee);
      };
      td.appendChild(button);
      tr.appendChild(td);
      return tr;
    };

    Index.prototype.attendeeRowClicked = function(attendee) {
      return new AttendeeEditor(attendee).show();
    };

    Index.prototype.appendCell = function(tr, text) {
      var td;
      td = document.createElement('td');
      td.appendChild(document.createTextNode(text));
      tr.appendChild(td);
      return td;
    };

    return Index;

  })();

  AttendeeEditor = (function() {

    AttendeeEditor.prototype.fields = {
      'txtFirstname': 'firstname',
      'txtLastname': 'lastname',
      'txtMiddlename': 'middlename',
      'txtCity': 'city',
      'txtPhone': 'phone',
      'txtField': 'field'
    };

    function AttendeeEditor(attendee) {
      this.attendee = attendee;
      this.backToList = __bind(this.backToList, this);

      this.registerAttendee = __bind(this.registerAttendee, this);

      this.saveEvents = __bind(this.saveEvents, this);

      this.getEventsData = __bind(this.getEventsData, this);

      this.hide = __bind(this.hide, this);

      this.clear = __bind(this.clear, this);

      this.fill = __bind(this.fill, this);

      this.fetch = __bind(this.fetch, this);

      this.show = __bind(this.show, this);

      this.editorContainer = document.getElementById('attendeeEditorContainer');
      document.getElementById('btnRegisterAttendee').onclick = this.registerAttendee;
      document.getElementById('btnBackToList').onclick = this.backToList;
    }

    AttendeeEditor.prototype.show = function() {
      document.getElementById('searchListContainer').style.display = 'none';
      this.editorContainer.style.display = 'block';
      this.clear();
      return this.fetch();
    };

    AttendeeEditor.prototype.fetch = function() {
      var _this = this;
      this.request = new XMLHttpRequest();
      this.request.onreadystatechange = function() {
        if (_this.request.readyState === 4) {
          _this.attendee = JSON.parse(_this.request.responseText);
          return _this.fill();
        }
      };
      this.request.open('GET', "/attendees?id=" + this.attendee._id, true);
      return this.request.send(null);
    };

    AttendeeEditor.prototype.fill = function() {
      var eventId, input, inputId, objectKey, _i, _len, _ref, _ref1, _results;
      _ref = this.fields;
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if (input != null) {
          input.value = this.attendee[objectKey];
        }
      }
      _ref1 = this.attendee['attended_events'];
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        eventId = _ref1[_i];
        _results.push(document.getElementById(eventId).checked = true);
      }
      return _results;
    };

    AttendeeEditor.prototype.clear = function() {
      var checkbox, inputId, objectKey, _i, _len, _ref, _ref1, _results;
      _ref = this.fields;
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        document.getElementById(inputId).value = '';
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
      document.getElementById('searchListContainer').style.display = 'block';
      return this.editorContainer.style.display = 'none';
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
      console.log(result);
      return result;
    };

    AttendeeEditor.prototype.saveEvents = function() {
      var saveRequest, selectedEvents;
      selectedEvents = this.getEventsData();
      saveRequest = new XMLHttpRequest();
      saveRequest.open('PUT', "/attendees?id=" + this.attendee._id + "&events=" + selectedEvents, false);
      return saveRequest.send(null);
    };

    AttendeeEditor.prototype.registerAttendee = function() {
      this.saveEvents();
      return this.hide();
    };

    AttendeeEditor.prototype.backToList = function() {
      return this.hide();
    };

    return AttendeeEditor;

  })();

  window.bodyLoaded = function() {
    return window.Page = new Index();
  };

  search = function(text) {
    return console.log(text);
  };

}).call(this);
