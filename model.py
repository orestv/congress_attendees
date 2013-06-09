# -*- coding: utf-8 -*-
import re
from flask.ext.pymongo import PyMongo
from flask.ext.pymongo import ASCENDING, DESCENDING
import locale

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
    cursor = db.attendees.find(query, fields=['firstname', 'lastname', 'middlename', 'city'])
    attendees = [attendee for attendee in cursor]
    return attendees
