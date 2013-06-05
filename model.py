# -*- coding: utf-8 -*-
import re
from flask.ext.pymongo import PyMongo
from flask.ext.pymongo import ASCENDING, DESCENDING


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


def find_attendees(db, search_term):
    words = search_term.split(' ')
    words.sort(key=len, reverse=True)
    search_fields = {'lastname': 4, 'city': 3, 'firstname': 2, 'middlename': 1}

    conditions = []
    for word in words:
        word_condition = [get_find_term(field, word)
                          for field in search_fields]
        conditions.append({'$or': word_condition})

    query = {'$and': conditions}
    cursor = db.attendees.find(query)
    attendees = [attendee for attendee in cursor]

    #sort by priority
    for attendee in attendees:
        attendee['priority'] = 0
        for field in search_fields:
            for word in words:
                r = get_word_regexp(word.upper())
                if r.match(attendee[field].upper()):
                    attendee['priority'] = attendee[
                        'priority'] + search_fields[field]
                    break
    attendees.sort(key=lambda attendee: attendee['priority'], reverse=True)

    return attendees
