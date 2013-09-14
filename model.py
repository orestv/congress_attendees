#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

def get_comparer(fields):
    def compare_records(a1, a2):
        for field in fields:
            f1 = a1.get(field)
            f2 = a2.get(field)
            if f1 and f2:
                compare_result = locale.strcoll(a1[field], a2[field])
                if compare_result:
                    return compare_result
        return 0
    return compare_records

def get_events(db):
    return db.events.find()

def get_event(db, event_id):
    return db.events.find_one({'_id': ObjectId(event_id)})

def get_event_attendees(db, event_id):
    s_eid = str(event_id)
    print s_eid
    cursor = db.attendees.find({
        'attended_events._id': s_eid,
        'attended_events.booked': True
        })
    attendees = list(cursor)
    return attendees

def get_event_attendees_count(db, event_id):
    event_attendees = get_event_attendees(db, event_id)
    return len(event_attendees)

def get_event_free_places(db, event_id):
    s_eid = event_id
    event_id = ObjectId(event_id)
    evt = db.events.find_one({'_id': event_id})
    if not evt.get('limit', None):
        free_places = None
    else:
        attendees_count = db.attendees.find({
                'attended_events._id': s_eid,
                'attended_events.booked': True
            }).count()
        free_places = evt['limit'] - attendees_count
    return {'_id': s_eid, 'free_places': free_places}

def get_events_free_places(db):
    events = []
    for evt in db.events.find():
        s_eid = str(evt['_id'])
        free_places = None
        if evt.get('limit', None):
            events.append (get_event_free_places(db, s_eid))
        else:
            events.append({'_id': s_eid})
    return events

def book_attendee_event(db, attendee_id, event_id):
    unbook_attendee_event(db, attendee_id, event_id)
    db.attendees.update({'_id': ObjectId(attendee_id)}, 
        {'$push': {'attended_events': 
            {'_id': event_id, 'booked': True}}})

def unbook_attendee_event(db, attendee_id, event_id):
    db.attendees.update({'_id': ObjectId(attendee_id)}, 
        {'$pull': {'attended_events': {'_id': event_id}}})

def set_attendee_events(db, attendee_id, event_ids):
    now = datetime.datetime.utcnow()
    event_objids = [ObjectId(id) for id in event_ids]
    event_cursor = db.events.find({'_id': {'$in': event_objids}}, fields=['_id'])
    new_valid_event_ids = [str(event['_id']) for event in event_cursor]
    attendee_id = ObjectId(attendee_id)
    attendee = db.attendees.find_one({'_id': attendee_id}, fields=['attended_events'])

    old_valid_events = attendee['attended_events']
    old_valid_event_ids = [str(event['id']) for event in old_valid_events]

    unchanged_events = [event for event in old_valid_events if event['id'] in new_valid_event_ids]
    added_events = [{'id': eid, 'time': now} for eid in new_valid_event_ids if eid not in old_valid_event_ids]

    all_events = unchanged_events + added_events
    db.attendees.update({'_id': attendee_id},
        {'$set': {'attended_events': all_events}})

def set_attendee_registered(db, attendee_id, user_id, registered, cash):
    cur = db.attendees.find({'_id': ObjectId(attendee_id), 
        'registered': True})
    already_registered = (cur.count() > 0)
    if not already_registered:
        db.attendees.update({'_id': ObjectId(attendee_id)},
            {'$set': {'registered': registered, 
                    'registered_on': datetime.datetime.now(), 
                    'registered_by': user_id}})
    db.users.update({'_id': ObjectId(user_id)}, 
        {'$inc': {'cash': int(cash)}})
    attendee = db.attendees.find_one({'_id': ObjectId(attendee_id)})
    for event in attendee['attended_events']:
        db.attendees.update({'_id': ObjectId(attendee_id), 'attended_events._id': event['_id']},
            {'$set': {'attended_events.$.paid': True}})


def add_attendee(db):
    aid = db.attendees.insert({'attended_events': []})
    return str(aid)

def delete_attendee(db, attendee_id):
    aid = ObjectId(attendee_id)
    db.attendees.remove({'_id': aid})

def set_attendee_info(db, attendee_id, info):
    if attendee_id:
        db.attendees.update({'_id': ObjectId(attendee_id)},
            {'$set': info})
    else:
        db.attendees.insert(info)

def find_attendee(db, id):
    cursor = db.attendees.find_one({'_id': ObjectId(id)})
    return cursor

def get_attendee_count_by_registrator(db, r_id):
    return db.attendees.find({'registered_by': r_id}).count()

def get_attendee_count_by_registrators(db):
    result = []
    users = db.users.find()
    for user in users:
        item = {
            'firstname': user['firstname'],
            'lastname': user['lastname'],
            'cash': user.get('cash', 0),
            'attendee_count': get_attendee_count_by_registrator(db, str(user['_id'])),
        }
        result.append(item)
    return result

def get_all_attendee_count(db):
    return db.attendees.find().count()

def get_registered_attendee_count(db):
    return db.attendees.find({'registered': True}).count()

def get_user_by_id(db, uid):
    return db.users.find_one({'_id': ObjectId(uid)})

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
