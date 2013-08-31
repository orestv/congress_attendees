// Generated by CoffeeScript 1.4.0
(function() {
  var Index, search,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Index = (function() {

    function Index() {
      this.backToList = __bind(this.backToList, this);

      this.registerAttendee = __bind(this.registerAttendee, this);

      this.updateEditedAttendee = __bind(this.updateEditedAttendee, this);

      this.editAttendee = __bind(this.editAttendee, this);

      this.editFirstAttendee = __bind(this.editFirstAttendee, this);

      this.editAttendeeClicked = __bind(this.editAttendeeClicked, this);

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
      searchbox = new window.SearchBox(searchBoxInput, this.searchRequested, this.editFirstAttendee);
      document.getElementById('btnRegisterAttendee').onclick = this.registerAttendee;
      document.getElementById('btnBackToList').onclick = this.backToList;
    }

    Index.prototype.searchRequested = function(searchQuery) {
      if (searchQuery === '') {
        this.nextSearch = null;
        this.searchRequest.abort();
        this.searching = false;
        document.getElementById('imgSearchLoader').style.visibility = 'hidden';
        this.clearSearchResults();
        return;
      }
      document.getElementById('imgSearchLoader').style.visibility = 'visible';
      if (this.searching) {
        this.searchRequest.abort();
      }
      this.searchRequest = new XMLHttpRequest();
      this.searchRequest.onreadystatechange = this.processSearchRequest;
      this.searchRequest.open('GET', "/attendees?s=" + searchQuery, true);
      this.searchRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      this.searchRequest.send(null);
      return this.searching = true;
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
      this.first_attendee = null;
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
        this.first_attendee = attendees[0];
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
      var attendeeName, button, city, td, tr,
        _this = this;
      tr = document.createElement('tr');
      city = attendee.city != null ? attendee.city : 'N/A';
      this.appendCell(tr, city);
      attendeeName = "" + attendee.lastname + " " + attendee.firstname + " " + attendee.middlename;
      this.appendCell(tr, attendeeName);
      if ((attendee.registered != null) && attendee.registered) {
        tr.className = 'registered';
      }
      td = document.createElement('td');
      button = document.createElement('input');
      button.type = 'button';
      if (!(attendee.registered != null)) {
        button.value = 'Зареєструвати';
      } else {
        button.value = 'Змінити інформацію';
      }
      button.onclick = function() {
        _this.editAttendeeClicked(attendee);
        return _this.selectedAttendeeRow = tr;
      };
      td.appendChild(button);
      tr.appendChild(td);
      return tr;
    };

    Index.prototype.editAttendeeClicked = function(attendee) {
      return this.editAttendee(attendee);
    };

    Index.prototype.editFirstAttendee = function() {
      if (this.first_attendee != null) {
        return this.editAttendee(this.first_attendee);
      }
    };

    Index.prototype.editAttendee = function(attendee) {
      if (attendee.registered && !confirm('Цей учасник вже зареєстрований. Ви справді бажаєте змінити його дані?')) {
        return;
      }
      this.editor = new AttendeeEditor(attendee);
      document.getElementById('searchListContainer').style.display = 'none';
      return this.editor.show();
    };

    Index.prototype.updateEditedAttendee = function(attendeeId) {
      var request,
        _this = this;
      request = new XMLHttpRequest();
      request.onreadystatechange = function() {
        var attendee, newRow;
        if (request.readyState === 4) {
          attendee = JSON.parse(request.responseText).attendee;
          newRow = _this.createAttendeeRow(attendee);
          return _this.tableBody.replaceChild(newRow, _this.selectedAttendeeRow);
        }
      };
      request.open('GET', "/attendees?id=" + attendeeId, true);
      return request.send(null);
    };

    Index.prototype.registerAttendee = function() {
      var attendeeData, data, eventsData, request;
      request = new XMLHttpRequest();
      eventsData = this.editor.getEventsData();
      attendeeData = this.editor.getAttendeeData();
      data = "events=" + eventsData;
      if (attendeeData) {
        data += '&' + attendeeData;
      }
      request.open('PUT', "/attendees?id=" + this.editor.attendee._id.$oid + "&registered=1", false);
      request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      request.send(data);
      this.updateEditedAttendee(this.editor.attendee._id.$oid);
      return this.backToList();
    };

    Index.prototype.backToList = function() {
      this.editor.hide();
      return document.getElementById('searchListContainer').style.display = 'block';
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

  window.onload = function() {
    return window.Page = new Index();
  };

  search = function(text) {
    return console.log(text);
  };

}).call(this);
