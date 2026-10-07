import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import messaging
import time
import sys

print("Starting Taskly Push Notification Server...")

try:
    # 1. Download your Service Account Key from Firebase Console -> Project Settings -> Service Accounts
    # 2. Rename it to 'serviceAccountKey.json' and place it in the same folder as this script.
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("Successfully connected to Firebase!")
except Exception as e:
    print("Failed to initialize Firebase! Did you place 'serviceAccountKey.json' in this folder?")
    print(e)
    sys.exit(1)

def on_snapshot(col_snapshot, changes, read_time):
    for change in changes:
        if change.type.name == 'ADDED' or change.type.name == 'MODIFIED':
            notif = change.document.to_dict()
            
            # Check if we already sent a push for this notification
            if not notif.get('push_sent', True):
                user_id = notif.get('user_id')
                title = notif.get('title', 'Taskly')
                body = notif.get('message', 'You have a new notification')
                
                print(f"New notification detected for user: {user_id}")
                
                # Look up the user's FCM token
                token_doc = db.collection('fcm_tokens').document(user_id).get()
                if token_doc.exists:
                    token = token_doc.to_dict().get('token')
                    if token:
                        # Send Push Notification via Firebase Cloud Messaging
                        message = messaging.Message(
                            notification=messaging.Notification(
                                title=title,
                                body=body,
                            ),
                            data={
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                'action_type': notif.get('type', 'task_assigned'),
                                'task_id': notif.get('task_id', ''),
                            },
                            token=token,
                        )
                        try:
                            response = messaging.send(message)
                            print(f"✅ Push Notification sent successfully: {response}")
                            # Mark as sent so we don't send it again
                            change.document.reference.update({'push_sent': True})
                        except Exception as e:
                            print(f"❌ Error sending push message: {e}")
                else:
                    print(f"⚠️ User {user_id} has no FCM token registered.")

# Listen to all notifications where push_sent == False
col_query = db.collection('notifications').where('push_sent', '==', False)
query_watch = col_query.on_snapshot(on_snapshot)

print("Listening for new tasks to send push notifications... (Press Ctrl+C to stop)")

# Keep the script running
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("Shutting down server.")
