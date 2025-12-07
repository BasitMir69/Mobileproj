# Cloud Functions Setup for Push Notifications

This document provides step-by-step instructions for setting up Firebase Cloud Functions to send push notifications when appointments are created or updated.

## Prerequisites

- Firebase project with Firestore and Authentication enabled
- Node.js and npm installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase Cloud Messaging (FCM) configured in your Flutter app

## Step 1: Initialize Cloud Functions

```bash
# Login to Firebase
firebase login

# Navigate to your project directory
cd path/to/flutter_application_1

# Initialize Cloud Functions
firebase init functions

# Choose the following options:
# - Select your Firebase project
# - Choose TypeScript or JavaScript (recommended: TypeScript)
# - Install dependencies with npm
```

This will create a `functions/` directory with the following structure:
```
functions/
├── src/
│   └── index.ts
├── package.json
├── tsconfig.json
└── .gitignore
```

## Step 2: Install Required Dependencies

```bash
cd functions
npm install firebase-admin firebase-functions
```

## Step 3: Implement Cloud Functions

Replace the content of `functions/src/index.ts` with the following:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();

/**
 * Sends a push notification when a new appointment is created.
 * Notifies the professor that a student has requested an appointment.
 */
export const onAppointmentCreate = functions.firestore
  .document('appointmentID/{appointmentId}')
  .onCreate(async (snap, context) => {
    const appointment = snap.data();
    const professorId = appointment.ProffessorID;
    const studentId = appointment.studentID;
    const slot = appointment.requestedSlot;
    const campus = appointment.campus;

    try {
      // Get professor's FCM token
      const professorDoc = await db.collection('professors').where('userID', '==', professorId).limit(1).get();
      
      if (professorDoc.empty) {
        console.log(`No professor found for userID: ${professorId}`);
        return;
      }

      const professorData = professorDoc.docs[0].data();
      const fcmToken = professorData.fcmToken;

      if (!fcmToken) {
        console.log(`Professor ${professorId} has no FCM token`);
        return;
      }

      // Get student details
      const studentDoc = await db.collection('users').doc(studentId).get();
      const studentName = studentDoc.exists ? studentDoc.data()?.displayName : 'A student';

      // Send notification
      const message = {
        notification: {
          title: 'New Appointment Request',
          body: `${studentName} requested an appointment at ${slot} (${campus})`,
        },
        data: {
          appointmentId: context.params.appointmentId,
          type: 'appointment_created',
          studentId: studentId,
          slot: slot,
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log(`Notification sent to professor ${professorId}`);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });

/**
 * Sends a push notification when an appointment status is updated.
 * Notifies the student when their appointment is confirmed or rejected.
 */
export const onAppointmentUpdate = functions.firestore
  .document('appointmentID/{appointmentId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Only trigger if status changed
    if (beforeData.status === afterData.status) {
      return;
    }

    const studentId = afterData.studentID;
    const status = afterData.status;
    const professorId = afterData.ProffessorID;
    const professorNotes = afterData.professorNotes || '';

    try {
      // Get student's FCM token
      const studentDoc = await db.collection('users').doc(studentId).get();
      
      if (!studentDoc.exists) {
        console.log(`No user found for studentID: ${studentId}`);
        return;
      }

      const studentData = studentDoc.data();
      const fcmToken = studentData?.fcmToken;

      if (!fcmToken) {
        console.log(`Student ${studentId} has no FCM token`);
        return;
      }

      // Get professor details
      const professorDoc = await db.collection('professors').where('userID', '==', professorId).limit(1).get();
      const professorName = professorDoc.empty ? 'Your professor' : professorDoc.docs[0].data().name;

      // Determine notification content based on status
      let title = 'Appointment Update';
      let body = '';

      if (status === 'confirmed') {
        title = 'Appointment Confirmed! ✅';
        body = `${professorName} has confirmed your appointment`;
      } else if (status === 'rejected') {
        title = 'Appointment Declined';
        body = `${professorName} declined your appointment`;
        if (professorNotes) {
          body += `: ${professorNotes}`;
        }
      } else if (status === 'cancelled') {
        title = 'Appointment Cancelled';
        body = `Your appointment with ${professorName} has been cancelled`;
      }

      // Send notification
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          appointmentId: context.params.appointmentId,
          type: 'appointment_updated',
          status: status,
          professorNotes: professorNotes,
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
      console.log(`Notification sent to student ${studentId}`);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });
```

## Step 4: Store FCM Tokens in Firestore

Update your Flutter app to store FCM tokens when users sign in or when tokens refresh.

### Add Firebase Messaging dependency to `pubspec.yaml`:

```yaml
dependencies:
  firebase_messaging: ^14.7.6
```

### Create FCM token service in Flutter:

```dart
// lib/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:campus_wave/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and save token to Firestore
  static Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Save token to user profile
    await FirestoreService.updateUserFCMToken(user.uid, token);
  }
}
```

### Add FCM token field to FirestoreService:

```dart
// Add to lib/services/firestore_service.dart

static Future<void> updateUserFCMToken(String userId, String fcmToken) async {
  await _users.doc(userId).update({'fcmToken': fcmToken});
}
```

### Call FCM initialization after login/signup:

```dart
// In loginscreen_new.dart and signup.dart, after successful auth:
await FCMService.initialize();
```

## Step 5: Update Firestore Security Rules

Add FCM token field to security rules:

```javascript
// firestore.rules
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
  
  // Allow users to update their own FCM token
  allow update: if request.auth.uid == userId 
    && request.resource.data.keys().hasOnly(['fcmToken']);
}
```

## Step 6: Deploy Cloud Functions

```bash
# Deploy functions to Firebase
firebase deploy --only functions

# Or deploy specific functions
firebase deploy --only functions:onAppointmentCreate,onAppointmentUpdate
```

## Step 7: Test Notifications

1. **Create test appointment**: Have a student book an appointment with a professor
2. **Check Firebase Console**: Navigate to Functions → Logs to see execution logs
3. **Verify notification delivery**: Professor should receive push notification
4. **Update appointment**: Professor confirms/rejects appointment
5. **Verify student notification**: Student should receive status update

## Monitoring & Troubleshooting

### View Function Logs:
```bash
firebase functions:log
```

### Common Issues:

1. **No FCM token stored**: Ensure FCMService.initialize() is called after authentication
2. **Token expired**: FCM tokens refresh periodically; ensure onTokenRefresh listener is active
3. **Permissions denied**: Check iOS/Android notification permissions
4. **Function not triggering**: Verify Firestore collection names match exactly ("appointmentID", "users", "professors")

### Firebase Console:
- **Functions Dashboard**: Monitor invocations, errors, and execution time
- **Cloud Messaging**: View notification send history
- **Firestore**: Verify FCM tokens are stored in user/professor documents

## Cost Considerations

- Cloud Functions: Free tier includes 2M invocations/month
- Cloud Messaging: Free unlimited notifications
- Firestore: Free tier includes 1GB storage, 50K reads/day

## Next Steps

1. **Rich notifications**: Add images, actions, or custom sounds
2. **Notification scheduling**: Send reminders before appointments
3. **In-app notifications**: Display notification UI when app is in foreground
4. **Notification history**: Store notification logs in Firestore
5. **Admin notifications**: Notify admins of system events

## Resources

- [Firebase Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Package](https://pub.dev/packages/firebase_messaging)
