#!/usr/bin/env python
# -*- coding: utf-8 -*-

# -*- coding: utf-8 -*-
import sqlite3 as sql
import random
import pymongo
from pymongo import MongoClient
import re
from string import digits
import crypt

def read_names(filename):
	input_file = open(filename, 'r')
	result = [name.replace('\n', '') for name in input_file]
	result = [name.decode('utf-8') for name in result]
	input_file.close()
	return result

def generate_middlename(firstname):
	suffix = u'вич'
	if firstname[-2:] != u'о':
		firstname += u'о'
	return firstname + suffix

def generate_digit_sequence(length):
	return ''.join(random.choice(digits) for d in xrange(length))

def generate_phone():
	country = generate_digit_sequence(2)
	city = generate_digit_sequence(3)
	phone = generate_digit_sequence(7)
	return '+%s (%s) %s' % (country, city, phone)

def db_connect():
	con = sql.connect('congress.db')
	return con

def create_attendee(cursor, firstname, middlename, lastname):
	cur.execute(u'INSERT INTO attendees (firstname, middlename, lastname) VALUES (:firstname, :middlename, :lastname)',
		{'firstname': firstname,
		'middlename': middlename,
		'lastname': lastname})

EVENTS = [
	{'caption': u'Обов’язковий реєстраційний платіж',
		'import_id': 'registration', 'price': 200, 'default': True},
	{'caption': u'Пакет матеріалів',
		'import_id': 'materials', 'price': 100, 
		'limit': 900, 'default': True,
		'item_caption': 'пакет матеріалів'},
	{'caption': u'Екскурсія 19.09 в 14 год.',
		'import_id': 'excursion_19', 
		'price': 40, 'limit': 90,
		'item_caption': u'квиток на екскурсію 19.09'},
	{'caption': u'Екскурсія 20.09 в 14 год.',
		'import_id': 'excursion_20', 
		'price': 40, 'limit': 90,
		'item_caption': u'квиток на екскурсію 20.09'},
	{'caption': u'Церемонія відкриття 18.09 в 19 год.',
		'import_id': 'opening', 'limit': 500,
		'item_caption': u'квиток на церемонію відкриття'},
	{'caption': u'Урочиста вечеря 19.09 в 19 год.',
		'import_id': 'ceremonial_dinner', 
		'price': 300, 'limit': 500,
		'item_caption': u'квиток на урочисту вечерю'},
	{'caption': u'Обід 19.09 в 13 год.',
		'import_id': 'dinner_19', 
		'price': 50, 'limit': 600,
		'item_caption': u'квиток на обід 19.09'},
	{'caption': u'Обід 20.09 в 13 год.',
		'import_id': 'dinner_20', 
		'price': 50, 'limit': 600,
		'item_caption': u'квиток на обід 20.09'}
]


def init_attendees(conn):
	db = conn.congress
	attendees = db.attendees
	firstnames = read_names('firstnames')
	lastnames = read_names('lastnames')
	cities = read_names('cities')
	fields = ['хірург', 'анестезіолог', 'педіатр', 'патологоанатом', 'пульмонолог']
	attendees.drop()

	local_attendees = []
	for i in xrange(100000):
		firstname = random.choice(firstnames)
		lastname = random.choice(lastnames)
		city = random.choice(cities)
		middlename = generate_middlename(random.choice(firstnames))
		phone = generate_phone()
		field = random.choice(fields)
		attendee = {'firstname': firstname,
			'middlename': middlename,
			'lastname': lastname,
			'city': city,
			'phone': phone,
			'field': field,
			'attended_events': []}
		local_attendees.append(attendee)
	attendees.insert(local_attendees)

def init_users(conn):
	db = conn.congress
	db.users.drop()
	fields = {'firstname': 1, 'lastname': 0, 'login': 2, 'password': 3}

	file_users = open('users_pwds', 'r')

	for line in file_users:
		line = line.rstrip()
		line_split = line.split('\t')
		user = {key : line_split[fields[key]] for key in fields}
		user['password_hash'] = crypt.crypt(user['password'], 'sha2')
		user['admin'] = (len(line_split) > 4)
		del user['password']
		db.users.insert(user)

	db.attendees.update({},
		{'$set': {
			'registered': False
		}}, multi = True)
	db.attendees.update({},
		{'$unset': {
			'registered_on': None,
			'registered_by': None
		}}, multi = True)

	file_users.close()

def init_events(conn):
	db = conn.congress
	db.attendees.update({}, 
		{'$set': 
			{'attended_events': []}
		},
		multi = True)
	db.events.drop()
	db.events.insert(EVENTS)

if __name__ == '__main__':
	conn = pymongo.MongoClient()
	init_users(conn)
	conn.close()