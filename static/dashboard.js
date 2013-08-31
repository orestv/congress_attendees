// Generated by CoffeeScript 1.4.0
(function() {
  var Dashboard,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Dashboard = (function() {

    function Dashboard() {
      this.addAttendee = __bind(this.addAttendee, this);

      this.hideAttendeeEditor = __bind(this.hideAttendeeEditor, this);

      this.showAttendeeEditor = __bind(this.showAttendeeEditor, this);

      this.fillEventAttendees = __bind(this.fillEventAttendees, this);

      this.clearEventAttendees = __bind(this.clearEventAttendees, this);

      this.showEventAttendees = __bind(this.showEventAttendees, this);
      document.getElementById('btnEventAttendeesHide').onclick = this.clearEventAttendees;
      this.btnShowAttendeeEditor = document.getElementById('btnShowAttendeeEditor');
      this.btnHideAttendeeEditor = document.getElementById('btnHideAttendeeEditor');
      this.btnAddAttendee = document.getElementById('btnAddAttendee');
      this.btnShowAttendeeEditor.onclick = this.showAttendeeEditor;
      this.btnHideAttendeeEditor.onclick = this.hideAttendeeEditor;
      this.btnAddAttendee.onclick = this.addAttendee;
    }

    Dashboard.prototype.showEventAttendees = function(eventId, eventCaption) {
      var eventAttendeesRequest,
        _this = this;
      this.clearEventAttendees();
      document.getElementById('spEventName').textContent = eventCaption;
      eventAttendeesRequest = new XMLHttpRequest();
      eventAttendeesRequest.open('GET', "/attendees?eventId=" + eventId, false);
      eventAttendeesRequest.onreadystatechange = function() {
        var attendees;
        if (eventAttendeesRequest.readyState === 4) {
          attendees = JSON.parse(eventAttendeesRequest.responseText);
          return _this.fillEventAttendees(attendees);
        }
      };
      return eventAttendeesRequest.send(null);
    };

    Dashboard.prototype.clearEventAttendees = function() {
      var tbody;
      tbody = document.getElementById('eventAttendeesTbody');
      while (tbody.firstChild) {
        tbody.removeChild(tbody.firstChild);
      }
      return document.getElementById('dvEventAttendees').style.display = 'none';
    };

    Dashboard.prototype.fillEventAttendees = function(eventAttendees) {
      var attendee, tbody, _i, _len;
      tbody = document.getElementById('eventAttendeesTbody');
      for (_i = 0, _len = eventAttendees.length; _i < _len; _i++) {
        attendee = eventAttendees[_i];
        tbody.appendChild(this.createEventAttendeeRow(attendee));
      }
      return document.getElementById('dvEventAttendees').style.display = 'block';
    };

    Dashboard.prototype.createEventAttendeeRow = function(attendee) {
      var details, tdDetails, tr;
      tr = document.createElement('tr');
      details = "" + attendee.lastname + " " + attendee.firstname + " " + attendee.middlename + ", " + attendee.city;
      tdDetails = document.createElement('td');
      tdDetails.appendChild(document.createTextNode(details));
      if (attendee.queue) {
        tr.className = 'queuedAttendee';
      }
      tr.appendChild(tdDetails);
      return tr;
    };

    Dashboard.prototype.showAttendeeEditor = function() {
      this.btnShowAttendeeEditor.style.display = 'none';
      this.attendeeEditor = new AttendeeEditor({});
      return this.attendeeEditor.show();
    };

    Dashboard.prototype.hideAttendeeEditor = function() {
      this.btnShowAttendeeEditor.style.display = 'block';
      this.attendeeEditor.clear();
      return this.attendeeEditor.hide();
    };

    Dashboard.prototype.addAttendee = function() {
      var attendeeData, request;
      attendeeData = this.attendeeEditor.getAttendeeData();
      console.log(attendeeData);
      request = new XMLHttpRequest();
      request.open('PUT', '/attendees', false);
      request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
      request.send(attendeeData);
      return this.hideAttendeeEditor();
    };

    return Dashboard;

  })();

  window.onload = function() {
    return window.Page = new Dashboard();
  };

}).call(this);
