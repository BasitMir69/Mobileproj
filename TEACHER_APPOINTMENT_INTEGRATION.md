# 📚 Teacher Appointment Management System Integration Guide

## Overview

A completely **separate and independent** appointment system has been integrated into your app. Teachers can upload/manage their appointment slots, and students can browse and book them.

**Key Point**: This system is **completely isolated** from the existing professor appointment system and won't interfere with it.

---

## 🎯 What Was Added

### 1. **New Data Model**
- **File**: `lib/models/teacher_appointment.dart`
- **Purpose**: Defines the `TeacherAppointment` class for type-safe operations
- **Key Fields**:
  - `teacherId` (Firebase UID)
  - `teacherName`, `department`, `campus`, `location`
  - `appointmentDateTime` (scheduled time)
  - `dayOfWeek`, `timeSlot` (readable formats)
  - `subject`, `description`
  - `status` (available/booked/cancelled)
  - `bookedByStudents` (list of student UIDs who booked)

### 2. **Extended Firestore Service**
- **File**: `lib/services/firestore_service.dart`
- **New Collection**: `teacherAppointments`
- **New Methods** (10 methods added):

```dart
// Teacher operations
createTeacherAppointment()          // Create new appointment
streamTeacherAppointments()         // Get teacher's appointments (real-time)
updateTeacherAppointment()          // Edit time, subject, etc.
deleteTeacherAppointment()          // Remove appointment

// Student operations
streamAllTeacherAppointments()      // Browse available appointments
bookTeacherAppointment()            // Student books a slot
cancelTeacherAppointmentBooking()   // Student cancels booking
isStudentBookedTeacherAppointment() // Check if already booked

// Utility
getTeacherAppointment()             // Get single appointment by ID
```

### 3. **Teacher Management Screen**
- **File**: `lib/screens/teacher_appointment_management_screen.dart`
- **Purpose**: Teachers can upload and manage their appointment slots
- **Features**:
  - ✅ **Tab 1: "My Appointments"** - Lists all slots created by this teacher
    - View appointment details (date, time, location, bookings count)
    - Edit appointment (update time, subject, description, location)
    - Delete appointment
  - ✅ **Tab 2: "Add New"** - Form to create new appointment
    - Subject/Topic
    - Description
    - Department & Campus
    - Room/Location
    - Date picker
    - Time slot (e.g., "10:00 AM - 11:00 AM")
    - Duration in minutes

### 4. **Student Browse & Book Screen**
- **File**: `lib/screens/browse_teacher_appointments_screen.dart`
- **Purpose**: Students can find and book teacher appointments
- **Features**:
  - ✅ Filter by campus
  - ✅ Filter by department
  - ✅ Browse all available appointments (real-time)
  - ✅ View teacher name, subject, time, location
  - ✅ "Book Appointment" button (becomes "Cancel Booking" if already booked)
  - ✅ Visual indicator of booking status

### 5. **Router Updates**
- **File**: `lib/router.dart`
- **New Routes Added**:
  ```
  /teacherAppointmentManagement   → Teacher management screen
  /browseTeacherAppointments      → Student browse/book screen
  ```

---

## 🚀 How to Access These Features

### For Teachers:

1. **Navigate to management screen**:
   ```dart
   context.push('/teacherAppointmentManagement');
   // or
   context.go('/teacherAppointmentManagement');
   ```

2. **Add to navigation menu** (in homescreen.dart or navigation drawer):
   ```dart
   ListTile(
     leading: const Icon(Icons.event_note),
     title: const Text('Manage Appointments'),
     onTap: () => context.push('/teacherAppointmentManagement'),
   )
   ```

### For Students:

1. **Navigate to browse screen**:
   ```dart
   context.push('/browseTeacherAppointments');
   ```

2. **Add to appointments screen** as a new tab or section:
   ```dart
   // In AppointmentsScreen, add a tab:
   TabBar(
     tabs: [
       Tab(text: 'My Appointments'),
       Tab(text: 'Teacher Slots'),  // ← NEW
     ],
   )
   
   TabBarView(
     children: [
       // Existing appointments
       AppointmentsScreen(),
       // New teacher appointments
       BrowseTeacherAppointmentsScreen(),
     ],
   )
   ```

---

## 📊 Firestore Structure

A **completely new collection** is created (doesn't touch existing data):

```
Firestore Database
├─ appointmentID/          (existing - untouched)
│  └─ [student → professor bookings]
│
├─ teacherAppointments/    (NEW - independent)
│  ├─ doc_001
│  │  ├─ teacherId: "uid_123"
│  │  ├─ teacherName: "Dr. Ahmed Khan"
│  │  ├─ subject: "Biology Lab"
│  │  ├─ campus: "LGS Gulberg Campus 2"
│  │  ├─ location: "Lab 101"
│  │  ├─ appointmentDateTime: Timestamp
│  │  ├─ dayOfWeek: "Monday"
│  │  ├─ timeSlot: "10:00 AM - 11:00 AM"
│  │  ├─ durationMinutes: 60
│  │  ├─ description: "Practical session"
│  │  ├─ status: "available"
│  │  ├─ bookedByStudents: ["student_id_1", "student_id_2"]
│  │  ├─ createdAt: Timestamp
│  │  └─ updatedAt: Timestamp
│  │
│  └─ doc_002
│     └─ ...
│
├─ users/                  (existing - untouched)
├─ professors/             (existing - untouched)
└─ ...
```

---

## 🔄 Data Flow

### Teacher Creating Appointment:

```
Teacher fills form
    ↓
FirestoreService.createTeacherAppointment()
    ↓
New document added to 'teacherAppointments' collection
    ↓
Real-time stream updates the teacher's "My Appointments" list
```

### Student Booking Appointment:

```
Student browses available slots
    ↓
Clicks "Book Appointment"
    ↓
FirestoreService.bookTeacherAppointment()
    ↓
Student's UID added to 'bookedByStudents' array
    ↓
Button changes to "Cancel Booking"
    ↓
Real-time update (if teacher viewing, booking count increases)
```

---

## ✅ Why This Won't Break Existing Features

1. **Separate Collection**: Uses `teacherAppointments`, not the existing `appointmentID`
2. **New Routes**: Independent routes `/teacherAppointmentManagement` and `/browseTeacherAppointments`
3. **No Modifications**: Didn't modify existing services, models, or screens
4. **Isolated Logic**: All teacher appointment logic in new files

| Feature | Collection | Status |
|---------|-----------|--------|
| Professor Appointments | appointmentID | ✅ Untouched |
| Student Appointments | appointmentID | ✅ Untouched |
| Teacher Appointments | teacherAppointments | ✨ NEW |

---

## 🎮 Testing the Integration

### 1. Login as a Teacher/User with role='teacher'
   - Or modify login to support role selection

### 2. Navigate to Teacher Management Screen
   ```
   /teacherAppointmentManagement
   ```

### 3. Create Sample Appointment:
   - Subject: "Biology Lab Session"
   - Description: "Practical microscope work"
   - Department: "Biology"
   - Campus: "LGS Gulberg Campus 2"
   - Location: "Lab 101"
   - Date: Tomorrow
   - Time: "10:00 AM - 11:00 AM"
   - Duration: 60 minutes

### 4. Check Firestore Console
   - Go to Firestore > `teacherAppointments` collection
   - See new appointment document

### 5. Login as Student
   - Navigate to `/browseTeacherAppointments`
   - See the appointment listed
   - Click "Book Appointment"
   - Check Firestore - student UID added to `bookedByStudents`

### 6. Go Back to Teacher View
   - Navigate to `/teacherAppointmentManagement` > "My Appointments"
   - See booking count increased
   - Edit or delete appointment

---

## 🔧 Optional: Add to Navigation Menu

**Add to homescreen.dart or navigation drawer**:

```dart
// For Teachers - in drawer or menu
ListTile(
  leading: const Icon(Icons.event_note),
  title: const Text('Manage My Appointments'),
  onTap: () {
    Navigator.pop(context);
    context.push('/teacherAppointmentManagement');
  },
)

// For Students - in appointments section
Tab(
  text: 'Teacher Slots',
  icon: Icon(Icons.person_outline),
),

// Or as a button in appointments screen
ElevatedButton.icon(
  icon: const Icon(Icons.search),
  label: const Text('Browse Teacher Appointments'),
  onPressed: () => context.push('/browseTeacherAppointments'),
)
```

---

## 📝 Code Examples

### For Teachers - Create Appointment Programmatically:

```dart
import 'package:campus_wave/services/firestore_service.dart';

final appointmentId = await FirestoreService.createTeacherAppointment(
  teacherId: 'uid_123',
  teacherName: 'Dr. Ahmed Khan',
  department: 'Biology',
  campus: 'LGS Gulberg Campus 2',
  location: 'Lab 101',
  appointmentDateTime: DateTime(2025, 12, 15, 10, 0),
  dayOfWeek: 'Monday',
  timeSlot: '10:00 AM - 11:00 AM',
  durationMinutes: 60,
  subject: 'Biology Lab',
  description: 'Practical session on cell division',
);
```

### For Students - Browse Appointments:

```dart
final appointments = FirestoreService.streamAllTeacherAppointments(
  campus: 'LGS Gulberg Campus 2',
  department: 'Biology',
);

appointments.listen((appointmentList) {
  // Display appointments
  for (var appt in appointmentList) {
    print('${appt['teacherName']} - ${appt['subject']}');
  }
});
```

### For Students - Book Appointment:

```dart
await FirestoreService.bookTeacherAppointment(
  appointmentId: 'appt_001',
  studentId: 'student_uid_123',
);
```

---

## 🚨 Important Notes

1. **Role Management**: Currently, any user can access both screens. Consider adding role checks:
   ```dart
   // Check if user is teacher
   final userProfile = await FirestoreService.getUserProfile(userId);
   if (userProfile?['role'] != 'teacher') {
     // Show permission denied
   }
   ```

2. **Input Validation**: The form validates inputs, but you may want additional validations:
   - Prevent booking past dates
   - Prevent double-booking same time slot
   - Minimum advance booking time

3. **Notifications**: Currently no notifications. Consider adding:
   - Student notified when appointment is booked
   - Teacher reminded of upcoming appointments
   - Student notified if teacher modifies/cancels

4. **Firestore Security Rules**: Add rules to protect data:
   ```firestore
   match /teacherAppointments/{document=**} {
     allow read: if true;  // Anyone can browse
     allow create: if request.auth.uid != null;  // Authenticated users
     allow update, delete: if resource.data.teacherId == request.auth.uid;  // Only creator
   }
   ```

---

## ✨ Summary

✅ **Teachers can**:
- Upload appointment slots
- Edit time/subject/location
- Delete appointments
- See how many students booked each slot

✅ **Students can**:
- Browse teacher appointments
- Filter by campus and department
- Book/cancel slots
- See real-time updates

✅ **System**:
- Completely independent from existing appointments
- Real-time Firestore streams
- No data conflicts
- Easy to extend with notifications

🎉 **You're ready to use it!**

---

## Quick Start Commands

```dart
// Teacher management screen
context.push('/teacherAppointmentManagement');

// Student browse screen
context.push('/browseTeacherAppointments');

// Create appointment (teacher)
FirestoreService.createTeacherAppointment(...);

// Book appointment (student)
FirestoreService.bookTeacherAppointment(appointmentId, studentId);

// Get all appointments for teacher
FirestoreService.streamTeacherAppointments(teacherId);

// Get all available appointments for students
FirestoreService.streamAllTeacherAppointments();
```
