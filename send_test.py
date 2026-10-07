import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import uuid
import datetime

print("Connecting to Firebase...")
cred = credentials.Certificate('serviceAccountKey.json')
# We must check if app is already initialized in case this runs in the same environment
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

notif_id = f"notif-test-{uuid.uuid4().hex[:8]}"
doc_ref = db.collection('notifications').document(notif_id)

print("Injecting test notification into Firestore...")
doc_ref.set({
    'id': notif_id,
    'organization_id': 'org-taskly-labs-001',
    'user_id': 'usr-harsh-admin',
    'task_id': 'test-123',
    'type': 'task_assigned',
    'title': 'Test Push Notification! 🚀',
    'message': 'Hello Harsh! Your push notifications are working perfectly.',
    'is_read': False,
    'push_sent': False,
    'created_at': datetime.datetime.now().isoformat()
})
print("Done! Your background server should catch this in 1 second and push it to your phone.")
