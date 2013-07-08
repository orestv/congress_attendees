# -*- coding: utf-8 -*-
import re
from flask.ext.pymongo import PyMongo
from flask.ext.pymongo import ASCENDING, DESCENDING
import locale
from bson import ObjectId
import datetime

def get_word_regexp(word):
    return re.compile('^%s' % word, re.IGNORECASE)


def get_find_term(field, word):
    return {field: get_word_regexp(word)}


def intersect_attendees(a, b):
    a_ids = [item['_id'] for item in a]
    b_ids = [item['_id'] for item in b]
    ids = list(set(a_ids) & set(b_ids))
    result = filter(lambda item: item['_id'] in ids, a + b)
    return result

def compare_attendees(a1, a2):
    for field in ['lastname', 'firstname', 'middlename']:
        compare_result = locale.strcoll(a1[field], a2[field])
        if compare_result:
            return compare_result
    return 0

def get_events(db):
    return db.events.find()

def get_event_attendees(db, event_id):
    if type(event_id) is not str:
        event_id = str(event_id)
    return db.attendees.find({'attended_events': {'$elemMatch': {'id': event_id}}})

def get_event_attendees_count(db, event_id):
    event_attendees = get_event_attendees(db, event_id)
    return event_attendees.count()

def set_attendee_events(db, attendee_id, event_ids):
    now = datetime.datetime.utcnow()
    event_objids = [ObjectId(id) for id in event_ids]
    event_cursor = db.events.find({'_id': {'$in': event_objids}}, fields=['_id'])
    new_valid_event_ids = [str(event['_id']) for event in event_cursor]
    attendee_id = ObjectId(attendee_id)
    attendee = db.attendees.find_one({'_id': attendee_id}, fields=['attended_events'])

    old_valid_events = attendee['attended_events']
    print old_valid_events
    old_valid_event_ids = [str(event['id']) for event in old_valid_events]

    unchanged_events = [event for event in old_valid_events if event['id'] in new_valid_event_ids]
    added_events = [{'id': eid, 'time': now} for eid in new_valid_event_ids if eid not in old_valid_event_ids]

    all_events = unchanged_events + added_events
    db.attendees.update({'_id': attendee_id},
        {'$set': {'attended_events': all_events}})

def set_attendee_registered(db, attendee_id, registered):
    db.attendees.update({'_id': ObjectId(attendee_id)},
        {'$set': {'registered': registered}})

def find_attendee(db, id):
    cursor = db.attendees.find({'_id': ObjectId(id)})
    return cursor

def find_attendees(db, search_term, search_by_city = False):
    words = search_term.split(' ')
    words.sort(key=len, reverse=True)
    search_fields = ['lastname', 'firstname', 'middlename']
    if search_by_city:
        search_fields.append('city')

    conditions = []
    for word in words:
        word_condition = [get_find_term(field, word)
                          for field in search_fields]
        conditions.append({'$or': word_condition})

    query = {'$and': conditions}
    cursor = db.attendees.find(query, fields=['firstname', 'lastname', 'middlename', 'city', 'registered'])
    attendees = [attendee for attendee in cursor]
    return attendees
