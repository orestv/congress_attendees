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
	{'caption': u'Обід 19.09'},
	{'caption': u'Обід 20.09'},
	{'caption': u'Екскурсія 19.09, 11:00', 'limit': 5},
	{'caption': u'Екскурсія 19.09, 12:00', 'limit': 7},
	{'caption': u'Екскурсія 20.09, 11:00', 'limit': 3},
	{'caption': u'Екскурсія 20.09, 12:00', 'limit': 4},
	{'caption': u'Урочиста вечеря 19.09'}
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

	db.events.drop()
	db.events.insert(EVENTS)

def init_users(conn):
	db = conn.congress
	db.users.drop()
	fields = {'firstname': 1, 'lastname': 0, 'login': 2, 'password': 3}

	file_users = open('users_pwds', 'r')

	for line in file_users:
		line = line.rstrip()
		line_split = line.split(' ')
		user = {key : line_split[fields[key]] for key in fields}
		user['password_hash'] = crypt.crypt(user['password'], 'sha2')
		user['admin'] = (len(line_split) > 4)
		del user['password']
		db.users.insert(user)

	file_users.close()

	# db.users.insert(user)

if __name__ == '__main__':
	conn = pymongo.MongoClient()
	init_users(conn)
	conn.close()