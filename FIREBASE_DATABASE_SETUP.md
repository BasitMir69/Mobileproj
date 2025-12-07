# 🔥 Firebase Database Setup Guide

## Firebase Project Details
- **Project ID**: `campuswave-9f2b3`
- **Region**: Default (us-central1 recommended)
- **Database**: Cloud Firestore

---

## 📊 Database Collections Structure

### 1. **users** Collection
Stores user profile information for both students and professors.

**Document ID**: Firebase Authentication UID

**Structure**:
```json
{
  "displayName": "Ahmed Ali",
  "email": "ahmed@lgs.edu.pk",
  "role": "student",  // or "professor"
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**For Demo Professor**:
```json
{
  "displayName": "Dr. Ayesha Khan",
  "email": "dr.ayesha.khan@lgs.edu.pk",
  "role": "professor",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 2. **professors** Collection
Stores professor profile details.

**Document ID**: `demo_professor` (hardcoded for demo account)

**Structure**:
```json
{
  "userID": "<Firebase UID of Dr. Ayesha>",
  "name": "Dr. Ayesha Khan",
  "Campus": "LGS Gulberg Campus 2",
  "Department": "Biology",
  "Title": "Associate Professor",
  "office": "Bio Lab 1",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Additional Professor Documents** (for other professors in the system):
```json
{
  "userID": "<Firebase UID>",
  "name": "Dr. Sara Malik",
  "Campus": "LGS 1A1",
  "Department": "Computer Science",
  "Title": "Associate Professor",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 3. **appointmentID** Collection ⭐ (CRITICAL FOR LINKING)
This is the **bridge collection** that connects students and professors.

**Document ID**: Auto-generated

**Structure**:
```json
{
  "ProffessorID": "demo_professor",  // Links to professors collection
  "studentID": "<Firebase UID>",      // Links to users collection
  "campus": "LGS Gulberg Campus 2",
  "location": "Bio Lab 1",
  "requestedSlot": "2025-12-08 10:00",
  "status": "pending",                // pending, confirmed, rejected
  "reminderSent": false,
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "professorNotes": "optional notes"
}
```

---

## 🔗 How the Linking Works

### Student Booking Flow:
```
1. Student sees Dr. Ayesha in professors list
   (from campusProfessors.dart, id: 'demo_professor')

2. Student clicks "Book Slot"
   → Calls createAppointment()
   → Stores appointment with:
      - ProffessorID: 'demo_professor'
      - studentID: current user's UID
      - requestedSlot: chosen time

3. Appointment saved to 'appointmentID' collection
```

### Professor Dashboard Flow:
```
1. Dr. Ayesha logs in with Firebase Auth
   (email: dr.ayesha.khan@lgs.edu.pk)

2. System fetches professor record:
   - Calls getProfessorByUserId(firebaseUID)
   - Returns: { id: 'demo_professor', ... }

3. Fetch appointments for this professor:
   - Calls streamProfessorAppointments('demo_professor')
   - Queries appointmentID collection
   - Client-side filters: ProffessorID == 'demo_professor'

4. Shows all student bookings with status "pending", "confirmed", etc.
```

### Bidirectional Linking:
```
Appointment Document:
┌──────────────────────────────────┐
│ ProffessorID: 'demo_professor'   │──→ professors collection
│ studentID: 'user_abc123'         │──→ users collection
│ status: 'pending'                │
└──────────────────────────────────┘
```

---

## 📋 Firebase Console Setup Steps

### Step 1: Create Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: `campuswave-9f2b3`
3. Navigate to **Firestore Database**
4. Click **Create database**
5. Choose:
   - **Location**: `us-central1` (or closest to you)
   - **Security rules**: Start in **test mode** (we'll configure proper rules later)
6. Click **Create**

### Step 2: Enable Authentication Methods

1. Go to **Authentication** → **Sign-in method**
2. Enable:
   - **Email/Password** ✅
   - **Google** (optional, for future enhancement)

### Step 3: Create Collections Manually (or via code initialization)

#### Option A: Manual Creation (via Firebase Console)

1. **Create `users` collection**:
   - Click "Start collection"
   - Collection ID: `users`
   - Add your first document (can be empty initially)

2. **Create `professors` collection**:
   - Click "Start collection"
   - Collection ID: `professors`

3. **Create `appointmentID` collection**:
   - Click "Start collection"
   - Collection ID: `appointmentID`

#### Option B: Automatic Creation (via App Initialization)

The app will automatically create these collections when:
- User signs up (creates `users` document)
- Demo professor initializes (creates `professors` document)
- First appointment is booked (creates `appointmentID` document)

---

## 🔐 Firestore Security Rules

**File**: `firestore.rules`

**Recommended Configuration**:

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if false;
    }

    // Professors can be read by anyone, written only by admin
    match /professors/{professorId} {
      allow read: if true;
      allow write: if false; // Only backend/admin can write
    }

    // Appointments visibility and modification
    match /appointmentID/{appointmentId} {
      // Students can see their own appointments
      allow read: if resource.data.studentID == request.auth.uid;
      
      // Professors can see their appointments
      allow read: if resource.data.ProffessorID != null;
      
      // Students can create appointments
      allow create: if request.auth.uid == request.resource.data.studentID;
      
      // Students can cancel their own appointments
      allow delete: if resource.data.studentID == request.auth.uid;
      
      // Professors can update appointment status
      allow update: if request.auth.uid != null;
    }
  }
}
```

---

## 🚀 Initialization Flow (App Startup)

When your app starts, here's what happens:

```
App Startup (main.dart)
  ↓
InitializationService.initialize()
  ↓
1. Check if demo professor Firebase account exists
   - Email: dr.ayesha.khan@lgs.edu.pk
   - If not, create it
   
2. Create professor document in 'professors' collection
   - Document ID: 'demo_professor'
   - userID: Firebase UID of demo account
   - Fields: name, campus, department, title
   
3. Create user profile in 'users' collection
   - Document ID: Firebase UID
   - role: 'professor'
   
4. Sign out for user login

5. Continue to login screen
```

---

## 👤 Demo Account

Use this to test the system:

**Student Account** (for booking):
```
Email: student@lgs.edu.pk
Password: Student@123
```

**Professor Account** (Dr. Ayesha):
```
Email: dr.ayesha.khan@lgs.edu.pk
Password: Professor@123
```

---

## ✅ Verification Checklist

Before testing, ensure:

- [ ] Firebase project `campuswave-9f2b3` exists
- [ ] Firestore database is created and active
- [ ] Email/Password authentication is enabled
- [ ] Three collections exist:
  - [ ] `users`
  - [ ] `professors`
  - [ ] `appointmentID`
- [ ] Demo professor Firebase account created
- [ ] Firestore security rules deployed (or in test mode)

---

## 🔍 Testing the Bidirectional Link

### Test Case 1: Student Books Appointment

1. **Student Login**:
   - Email: student@lgs.edu.pk
   - Password: Student@123

2. **Browse Professors**:
   - See "Dr. Ayesha Khan" in "LGS Gulberg Campus 2"

3. **Book Appointment**:
   - Click "Book" on Dr. Ayesha
   - Select slot: 2025-12-08 10:00
   - Confirm booking

4. **Verify in My Appointments**:
   - Should see booking with status "pending"
   - Shows: Professor: demo_professor, Campus: LGS Gulberg Campus 2, Slot: 2025-12-08 10:00

### Test Case 2: Professor Views Booking

1. **Check Firebase Console**:
   - Go to Firestore → appointmentID collection
   - Should see new document with:
     - ProffessorID: "demo_professor"
     - studentID: student's UID
     - requestedSlot: "2025-12-08 10:00"
     - status: "pending"

2. **Professor Login** (Dr. Ayesha):
   - Email: dr.ayesha.khan@lgs.edu.pk
   - Password: Professor@123

3. **View Appointments**:
   - Should see student's booking in "Pending" tab
   - Shows student name, slot, campus, location

4. **Accept/Reject**:
   - Can change status to "confirmed" or "rejected"
   - Status updates in Firestore

---

## 📱 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Firebase Project                      │
│              (campuswave-9f2b3)                         │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   users      │  │ professors   │  │appointmentID │   │
│  │  (UID docs)  │  │(demo_prof)   │  │  (bridge)    │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│       ▲                  ▲                    ▲           │
│       │                  │                    │           │
│   Student UID        Prof UID          Links both        │
│                                                           │
└─────────────────────────────────────────────────────────┘
         ▲                                       ▲
         │                                       │
    Student App                           Professor App
    (Books Appointments)                  (Views Bookings)
```

---

## 🔧 Code Reference

### Key Methods in firestore_service.dart

**For Students**:
```dart
FirestoreService.createAppointment(
  professorId: 'demo_professor',
  campus: 'LGS Gulberg Campus 2',
  location: 'Bio Lab 1',
  requestedSlot: '2025-12-08 10:00',
)
```

**For Professors**:
```dart
// Get professor ID from Firebase UID
FirestoreService.getProfessorByUserId(firebaseUID)

// Get all appointments for this professor
FirestoreService.streamProfessorAppointments('demo_professor')
```

---

## 📞 Troubleshooting

### Issue: "Query requires index"
**Solution**: Already fixed! Using client-side filtering instead of composite indexes.

### Issue: Professor doesn't see student bookings
**Check**:
1. Professor logged in with correct account
2. Appointment's `ProffessorID` matches professor's document ID
3. Firestore rules allow professor to read appointments

### Issue: Student can't create appointment
**Check**:
1. User is authenticated (logged in)
2. Firestore rules allow appointment creation
3. `studentID` is set to current user's UID

---

**Status**: ✅ Ready for Firebase Console Setup
