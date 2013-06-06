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
      if (searchTerm === '' && this.searching) {
        this.nextSearch = null;
        this.searchRequest.abort();
        this.searching = false;
        document.getElementById('imgSearchLoader').style.visibility = 'hidden';
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
      this.searchRequest.open('GET', "/find_attendee?s=" + searchTerm, true);
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
      var attendee, frag, _fn, _i, _len,
        _this = this;
      this.tableBody = document.getElementById('searchResultsBody');
      frag = document.createDocumentFragment();
      _fn = function(attendee) {
        return frag.appendChild(_this.createAttendeeRow(attendee));
      };
      for (_i = 0, _len = results.length; _i < _len; _i++) {
        attendee = results[_i];
        _fn(attendee);
      }
      this.tableBody.appendChild(frag);
      if (results.length > 0) {
        return this.table.style.visibility = 'visible';
      }
    };

    Index.prototype.createAttendeeRow = function(attendee) {
      var attendeeName, tr,
        _this = this;
      tr = document.createElement('tr');
      tr.onclick = function() {
        return _this.attendeeRowClicked(attendee);
      };
      this.appendCell(tr, attendee.city);
      attendeeName = "" + attendee.lastname + " " + attendee.firstname + " " + attendee.middlename;
      this.appendCell(tr, attendeeName);
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
      'txtCity': 'city'
    };

    function AttendeeEditor(attendee) {
      this.attendee = attendee;
      this.backToList = __bind(this.backToList, this);

      this.registerAttendee = __bind(this.registerAttendee, this);

      this.saveInfoUpdate = __bind(this.saveInfoUpdate, this);

      this.cancelInfoUpdate = __bind(this.cancelInfoUpdate, this);

      this.updateInfo = __bind(this.updateInfo, this);

      this.hide = __bind(this.hide, this);

      this.fill = __bind(this.fill, this);

      this.show = __bind(this.show, this);

      this.editorContainer = document.getElementById('attendeeEditorContainer');
      document.getElementById('btnRegisterAttendee').onclick = this.registerAttendee;
      document.getElementById('btnBackToList').onclick = this.backToList;
      document.getElementById('btnUpdateInfo').onclick = this.updateInfo;
      document.getElementById('btnSaveInfoUpdate').onclick = this.saveInfoUpdate;
      document.getElementById('btnCancelInfoUpdate').onclick = this.cancelInfoUpdate;
    }

    AttendeeEditor.prototype.show = function() {
      document.getElementById('searchListContainer').style.display = 'none';
      this.editorContainer.style.display = 'block';
      this.setEditorsEnabled(false);
      return this.fill();
    };

    AttendeeEditor.prototype.fill = function() {
      var input, inputId, objectKey, _ref, _results;
      _ref = this.fields;
      _results = [];
      for (inputId in _ref) {
        objectKey = _ref[inputId];
        input = document.getElementById(inputId);
        if (input != null) {
          _results.push(input.value = this.attendee[objectKey]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    AttendeeEditor.prototype.hide = function() {
      document.getElementById('searchListContainer').style.display = 'block';
      return this.editorContainer.style.display = 'none';
    };

    AttendeeEditor.prototype.setEditorsEnabled = function(enabled) {
      var input, inputId, _results;
      _results = [];
      for (inputId in this.fields) {
        input = document.getElementById(inputId);
        if (input != null) {
          _results.push(input.disabled = !enabled);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    AttendeeEditor.prototype.updateInfo = function() {
      this.setEditorsEnabled(true);
      document.getElementById('dvUpdateInfo').style.display = 'none';
      return document.getElementById('dvUpdateInfoSaveCancel').style.display = 'block';
    };

    AttendeeEditor.prototype.cancelInfoUpdate = function() {
      this.setEditorsEnabled(false);
      document.getElementById('dvUpdateInfo').style.display = 'block';
      return document.getElementById('dvUpdateInfoSaveCancel').style.display = 'none';
    };

    AttendeeEditor.prototype.saveInfoUpdate = function() {
      this.setEditorsEnabled(false);
      document.getElementById('dvUpdateInfo').style.display = 'block';
      return document.getElementById('dvUpdateInfoSaveCancel').style.display = 'none';
    };

    AttendeeEditor.prototype.registerAttendee = function() {
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
