#!/usr/bin/env python
# -*- coding: utf-8 -*-

import model
from bson import ObjectId
import crypt

class User:

    def __init__(self, uid, is_admin, firstname, lastname):
        self.uid = uid
        self.is_admin = is_admin
        self.firstname = firstname
        self.lastname = lastname

    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def get_id(self):
        return unicode(self.uid)


def get_user_by_id(db, uid):
    uid = ObjectId(uid)
    db_user = db.users.find_one({'_id': uid})
    if not db_user:
        return None
    return User(str(db_user['_id']), db_user['admin'], db_user['firstname'], db_user['lastname'])

def get_user_by_credentials(db, login, password):
    password_hash = crypt.crypt(password, 'sha2')
    db_user = db.users.find_one({'login': login, 'password_hash': password_hash})
    if not db_user:
        return None
    return User(str(db_user['_id']), db_user['admin'], db_user['firstname'], db_user['lastname'])