# 🎯 Firebase Setup Checklist & Quick Start

## Step-by-Step Firebase Console Setup

### 1️⃣ Create Firestore Database

**Go to**: https://console.firebase.google.com

1. Select project: **campuswave-9f2b3**
2. Click **Firestore Database** (left sidebar)
3. Click **Create Database**
4. Choose settings:
   - **Location**: `us-central1` (recommended)
   - **Security Rules**: Choose **Start in test mode** (for now)
5. Click **Create**

✅ **Firestore database is now ready**

---

### 2️⃣ Enable Email/Password Authentication

1. Go to **Authentication** (left sidebar)
2. Click **Sign-in method**
3. Enable **Email/Password**:
   - Click the toggle switch
   - Enable "Email/Password"
   - Enable "Email link sign-in" (optional)
   - Click **Save**

✅ **Authentication is now ready**

---

### 3️⃣ Create Initial Firestore Collections

The app will auto-create collections when:
- First user signs up → `users` collection created
- Demo professor initializes → `professors` collection created
- First appointment booked → `appointmentID` collection created

**OR manually create them**:

1. In Firestore, click **Start collection**
2. Create these 3 collections:
   - `users`
   - `professors`
   - `appointmentID`

✅ **Collections are ready**

---

## 👤 Create Test Accounts in Firebase Console

### Step 1: Create Demo Professor Account

1. Go to **Authentication** → **Users**
2. Click **Add user**
3. Enter:
   - **Email**: `dr.ayesha.khan@lgs.edu.pk`
   - **Password**: `Professor@123`
4. Click **Add user**

### Step 2: Create Demo Student Account

1. Click **Add user** again
2. Enter:
   - **Email**: `student@lgs.edu.pk`
   - **Password**: `Student@123`
3. Click **Add user**

✅ **Test accounts created**

---

## 🚀 Initialize Demo Professor Data

**The app will do this automatically when it starts**, but here's what happens:

### Option A: Automatic (Recommended)

Just run the app:
```bash
flutter run -d emulator-5554
```

The `InitializationService` will:
1. Check if demo professor exists in Firebase
2. If not, create the professor profile document:
   - Collection: `professors`
   - Document ID: `demo_professor`
   - Fields: userID, name, campus, department, title
3. Create user profile in `users` collection

### Option B: Manual (Firebase Console)

If you want to manually add the demo professor data:

1. Go to **Firestore** → **professors** collection
2. Click **Add document**
3. Document ID: `demo_professor`
4. Add fields:
   ```
   userID: <UID of dr.ayesha.khan@lgs.edu.pk>
   name: "Dr. Ayesha Khan"
   Campus: "LGS Gulberg Campus 2"
   Department: "Biology"
   Title: "Associate Professor"
   office: "Bio Lab 1"
   createdAt: (timestamp)
   updatedAt: (timestamp)
   ```

---

## ✅ Testing Checklist

### ✓ Before Testing

- [ ] Firebase project `campuswave-9f2b3` created
- [ ] Firestore database is active
- [ ] Email/Password auth enabled
- [ ] `users`, `professors`, `appointmentID` collections created
- [ ] Demo professor account created
- [ ] Demo student account created

### ✓ Testing Student → Professor Link

**Test 1: Student Books Appointment**

```
1. Run app: flutter run -d emulator-5554
2. Login as student: student@lgs.edu.pk / Student@123
3. Go to "Find Professors"
4. Select "Dr. Ayesha Khan" from "LGS Gulberg Campus 2"
5. Click "Book" on available slot (e.g., 2025-12-08 10:00)
6. Confirm booking
7. Check "My Appointments" screen → Should see pending booking
```

**What happens in Firebase**:
- New document created in `appointmentID` collection
- Fields: ProffessorID: "demo_professor", studentID: <student_uid>, status: "pending"

**Verify in Firebase Console**:
```
Firestore → appointmentID collection
Should see a new document with:
- ProffessorID: "demo_professor"
- studentID: "<student_uid>"
- campus: "LGS Gulberg Campus 2"
- location: "Bio Lab 1"
- requestedSlot: "2025-12-08 10:00"
- status: "pending"
- createdAt: <timestamp>
```

**Test 2: Professor Views Booking** ⭐ THE LINK

```
1. Logout (student)
2. Login as professor: dr.ayesha.khan@lgs.edu.pk / Professor@123
3. Go to "My Appointments"
4. Check "Pending" tab
5. Should see the student's booking!
   ├─ Shows student info
   ├─ Shows requested slot
   └─ Shows campus/location
```

**How the Link Works**:

```
Student Books Appointment:
  └─ Creates document in appointmentID with:
     ProffessorID: "demo_professor"
     studentID: "<student_uid>"

Professor Views Appointments:
  └─ getProfessorByUserId(dr.ayesha_uid)
     → Returns { id: "demo_professor", ... }
  
  └─ streamProfessorAppointments("demo_professor")
     → Queries appointmentID collection
     → Filters: ProffessorID == "demo_professor"
     → Shows all student bookings
```

---

## 🔐 Firestore Security Rules (Production)

Once you've tested in test mode, update security rules:

**Go to**: Firestore → Rules

**Replace with**:
```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read/write their own profiles
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if false;
    }

    // Professors readable by all (needed for professor list)
    match /professors/{professorId} {
      allow read: if true;
      allow write: if false;
    }

    // Appointments
    match /appointmentID/{appointmentId} {
      // Students can see their own
      allow read: if resource.data.studentID == request.auth.uid;
      // Professors can see theirs (by ProffessorID)
      allow read: if true;
      // Create if you're the student
      allow create: if request.resource.data.studentID == request.auth.uid;
      // Delete if you're the student
      allow delete: if resource.data.studentID == request.auth.uid;
      // Update (status changes) by anyone for now
      allow update: if request.auth != null;
    }
  }
}
```

Click **Publish**

---

## 🎬 Complete Workflow Diagram

```
FIREBASE SETUP COMPLETE ✅
┌─────────────────────────────────────────────────┐
│         campuswave-9f2b3 (Your Project)        │
└─────────────────────────────────────────────────┘
         ↓                    ↓                   ↓
   ┌──────────┐      ┌──────────────┐    ┌────────────┐
   │   Auth   │      │  Firestore   │    │  Storage   │
   │          │      │              │    │            │
   │ Email/   │      │ Collections: │    │ (Optional) │
   │Password  │      │ • users      │    │            │
   └──────────┘      │ • professors │    └────────────┘
         ↓           │ • appointmentID
         │           └──────────────┘
         │                ↓
         └────────────────┘
                ↓
    ┌──────────────────────┐
    │  Your Flutter App    │
    │                      │
    │  Student Login →     │
    │  Book Appointment →  │
    │  (Stored in Firebase)│
    │                      │
    │  Professor Login →   │
    │  See Bookings ←      │
    │  (Read from Firebase)│
    └──────────────────────┘
```

---

## 🔗 The Bidirectional Link Explained

### Data Flow:

```
STUDENT SIDE:
┌──────────────────┐
│  Student logs in │
│  with UID: abc123│
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│  Finds professor │
│ (id: demo_prof)  │
└────────┬─────────┘
         │
         ↓
┌──────────────────────────────┐
│  Books appointment:          │
│  createAppointment(          │
│    professorId:              │
│    'demo_professor'          │
│    studentID: 'abc123'       │
│  )                           │
└────────┬─────────────────────┘
         │
         ↓
┌──────────────────────────────┐
│  appointmentID Collection:   │
│  {                           │
│    ProffessorID:             │
│    'demo_professor' ←────────┼─────┐
│    studentID: 'abc123' ←─────┼──┐  │
│    status: 'pending'         │  │  │
│  }                           │  │  │
└──────────────────────────────┘  │  │
                                  │  │
PROFESSOR SIDE:                   │  │
┌──────────────────┐              │  │
│ Prof logs in     │              │  │
│ with UID: xyz789 │              │  │
└────────┬─────────┘              │  │
         │                        │  │
         ↓                        │  │
┌──────────────────────────────┐ │  │
│ getProfessorByUserId('xyz789')│ │  │
│ Returns: {                   │ │  │
│   id: 'demo_professor' ──────┼─┘  │
│ }                            │    │
└────────┬─────────────────────┘    │
         │                          │
         ↓                          │
┌──────────────────────────────┐   │
│ streamProfessorAppointments( │   │
│   'demo_professor'           │   │
│ )                            │   │
└────────┬─────────────────────┘   │
         │                          │
         ↓                          │
    Query appointmentID where    │
    ProffessorID == 'demo_prof' ←──┘
         │
         ↓
    Shows all bookings by
    this professor
```

---

## 🆘 If Something Doesn't Work

### Issue: "Permission denied" errors
**Solution**: Make sure Firestore is in **test mode** or rules are set correctly

### Issue: Collections not appearing
**Solution**: Collections are created automatically on first write. Just book an appointment!

### Issue: Professor doesn't see bookings
**Check**:
1. ✅ Professor document ID is `demo_professor`
2. ✅ Appointment's `ProffessorID` field is `demo_professor`
3. ✅ Professor is logged in with correct account
4. ✅ Firebase rules allow reads

### Issue: Student doesn't see bookings
**Check**:
1. ✅ Student is logged in with same account used for booking
2. ✅ Appointment's `studentID` matches student's Firebase UID
3. ✅ Firebase rules allow student reads

---

## 📞 Quick Links

- **Firebase Console**: https://console.firebase.google.com
- **Your Project**: https://console.firebase.google.com/project/campuswave-9f2b3
- **Firestore Docs**: https://firebase.google.com/docs/firestore
- **Authentication**: https://firebase.google.com/docs/auth

---

**Status**: 🔥 Ready to Set Up!
**Next Step**: Follow the step-by-step checklist above
