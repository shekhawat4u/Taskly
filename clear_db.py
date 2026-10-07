import firebase_admin
from firebase_admin import credentials, firestore
import time

try:
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)
except ValueError:
    pass # App already initialized

db = firestore.client()

def delete_collection(coll_ref, batch_size):
    docs = coll_ref.limit(batch_size).stream()
    deleted = 0
    
    for doc in docs:
        print(f'Deleting doc {doc.id} => {doc.to_dict()}')
        doc.reference.delete()
        deleted = deleted + 1

    if deleted >= batch_size:
        return delete_collection(coll_ref, batch_size)

print("Deleting all tasks...")
delete_collection(db.collection('tasks'), 100)

print("Deleting all activities...")
delete_collection(db.collection('activities'), 100)

print("Deleting all notifications...")
delete_collection(db.collection('notifications'), 100)

print("Deleting all fcm_tokens...")
delete_collection(db.collection('fcm_tokens'), 100)

print("Deleting all attachments...")
delete_collection(db.collection('attachments'), 100)

print("Deleting all users...")
delete_collection(db.collection('users'), 100)

print("Creating admin user Harsh...")
admin_id = "usr-harsh-admin-v2"
db.collection('users').document(admin_id).set({
    'id': admin_id,
    'organization_id': 'org-taskly-labs-001',
    'organizationId': 'org-taskly-labs-001',
    'name': 'Harsh',
    'auth_email': 'harsh@deepbasics.in',
    'email_display': 'harsh@deepbasics.in',
    'role': 'admin',
    'password': 'Ks@210109',
    'is_active': True,
    'isActive': True,
    'active_task_count': 0,
    'activeTaskCount': 0,
})

print("Database cleared and seeded successfully!")
