# -*- coding: utf-8 -*-
import re
from flask.ext.pymongo import PyMongo
from flask.ext.pymongo import ASCENDING, DESCENDING
import locale
from bson import ObjectId

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

def set_attendee_events(db, attendee_id, event_ids):
    event_objids = [ObjectId(id) for id in event_ids]
    event_cursor = db.events.find({'_id': {'$in': event_objids}})
    valid_event_objids = [event for event in event_cursor]
    valid_event_ids = [str(event['_id']) for event in valid_event_objids]
    attendee_id = ObjectId(attendee_id)
    db.attendees.update({'_id': attendee_id},
        {'$set': {'attended_events': valid_event_ids}})

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
