// Generated by CoffeeScript 1.6.1
(function() {
  var Dashboard,
    _this = this;

  Dashboard = (function() {

    function Dashboard() {
      var _this = this;
      this.fillEventAttendees = function(eventAttendees) {
        return Dashboard.prototype.fillEventAttendees.apply(_this, arguments);
      };
      this.clearEventAttendees = function() {
        return Dashboard.prototype.clearEventAttendees.apply(_this, arguments);
      };
      this.showEventAttendees = function(eventId, eventCaption) {
        return Dashboard.prototype.showEventAttendees.apply(_this, arguments);
      };
      document.getElementById('btnEventAttendeesHide').onclick = this.clearEventAttendees;
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
      var aEdit, details, tdActions, tdDetails, tr;
      tr = document.createElement('tr');
      details = "" + attendee.lastname + " " + attendee.firstname + " " + attendee.middlename + ", " + attendee.city;
      tdDetails = document.createElement('td');
      tdDetails.appendChild(document.createTextNode(details));
      tdActions = document.createElement('td');
      aEdit = document.createElement('a');
      aEdit.appendChild(document.createTextNode('Редагувати'));
      aEdit.setAttribute('href', "/attendee_edit?id=" + attendee._id);
      tdActions.appendChild(aEdit);
      tr.appendChild(tdDetails);
      tr.appendChild(tdActions);
      return tr;
    };

    return Dashboard;

  })();

  window.onload = function() {
    return window.Page = new Dashboard();
  };

}).call(this);
