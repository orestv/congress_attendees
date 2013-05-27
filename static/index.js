// Generated by CoffeeScript 1.4.0
(function() {
  var Index, search,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Index = (function() {

    function Index() {
      this.createAttendeeRow = __bind(this.createAttendeeRow, this);

      this.populateSearchResults = __bind(this.populateSearchResults, this);

      this.clearSearchResults = __bind(this.clearSearchResults, this);

      this.processSearchRequest = __bind(this.processSearchRequest, this);

      this.searchRequested = __bind(this.searchRequested, this);

      var searchBoxInput, searchbox;
      this.searching = false;
      this.tableBody = document.getElementById('searchResultsBody');
      searchBoxInput = document.getElementById('searchBox');
      searchBoxInput.focus();
      searchbox = new window.SearchBox(searchBoxInput, this.searchRequested);
    }

    Index.prototype.searchRequested = function(searchTerm) {
      if (this.searching) {
        this.searchRequest.abort();
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
        return this.searching = false;
      }
    };

    Index.prototype.clearSearchResults = function() {
      var _results;
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
      return this.tableBody.appendChild(frag);
    };

    Index.prototype.createAttendeeRow = function(attendee) {
      var td, tr;
      tr = document.createElement('tr');
      td = document.createElement('td');
      td.appendChild(document.createTextNode("" + attendee.lastname + " " + attendee.firstname + " " + attendee.middlename));
      tr.appendChild(td);
      return tr;
    };

    return Index;

  })();

  window.bodyLoaded = function() {
    return window.Page = new Index();
  };

  search = function(text) {
    return console.log(text);
  };

}).call(this);