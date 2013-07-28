import model
from bson import ObjectId

class User:

    def __init__(self, uid, is_admin):
        self.uid = uid
        self.is_admin = is_admin

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
    return User(str(db_user['_id']), db_user['admin'])

def get_user_by_credentials(db, login, password):
    db_user = db.users.find_one({'login': login, 'password': password})
    print login, password, db_user
    if not db_user:
        return None
    return User(str(db_user['_id']), db_user['admin'])