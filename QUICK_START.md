🎯 QUICK REFERENCE - Professor Account & Testing
=================================================

DEMO PROFESSOR CREDENTIALS:
═════════════════════════════════════════════════

Email:    dr.ayesha.khan@lgs.edu.pk
Password: Professor@123

That's it! 🚀 Just use these on the login screen!


HOW TO TEST:
═════════════════════════════════════════════════

1️⃣  LOGIN AS PROFESSOR:
   ├─ Click "Use Demo Account" button on login screen
   ├─ OR manually enter credentials above
   ├─ Make sure "Professor" role is selected
   └─ Click Login

2️⃣  YOU'LL SEE:
   ├─ Professor Dashboard with welcome card
   ├─ Stats showing current appointments
   ├─ Quick action cards
   └─ "My Appointments" link

3️⃣  TO SEE APPOINTMENTS:
   ├─ Click "My Appointments"
   ├─ You'll see 3 tabs: Pending, Confirmed, History
   ├─ (Empty initially - need students to book first)
   └─ Once students book, appointments appear here


HOW STUDENTS BOOK APPOINTMENTS:
═════════════════════════════════════════════════

1. Login as Student
2. Go to Professors tab
3. Select any professor
4. Click "Book" or a time slot
5. Confirm booking dialog
6. Appointment appears in "My Appointments"
7. AND automatically in professor's "Pending" appointments


WHAT PROFESSOR CAN DO:
═════════════════════════════════════════════════

✓ View all student appointments
✓ Confirm appointments
✓ Reject appointments (with optional notes)
✓ Track appointment status (Pending → Confirmed → History)
✓ See student booking details
✓ Logout and switch back to student mode


FILE LOCATIONS:
═════════════════════════════════════════════════

Demo Credentials: lib/data/hardcoded_professor.dart
Login Screen:     lib/loginscreen_new.dart (has demo button)
Prof Dashboard:   lib/screens/professor_home_screen.dart
Prof Appts:       lib/screens/professor_appointments_screen.dart
Router:           lib/router.dart


KEY ROUTES:
═════════════════════════════════════════════════

/login              → Login screen (both roles)
/home               → Student home (5 tabs)
/professorHome      → Professor dashboard
/appointments       → Student's bookings
/professorAppointments → Professor's bookings


FIRESTORE COLLECTIONS:
═════════════════════════════════════════════════

appointmentID     ← Where bookings are saved
  └─ Contains: professorId, studentID, slot, status, etc

professors        ← Professor profiles
  └─ Contains: name, campus, department, etc

users             ← User profiles with roles
  └─ Contains: displayName, email, role (student/professor)


WHAT'S INCLUDED:
═════════════════════════════════════════════════

✅ Hardcoded professor account
✅ Role-based authentication (Student/Professor)
✅ Demo credentials button on login
✅ Professor dashboard screen
✅ Professor appointments view with tabs
✅ Real-time Firestore sync
✅ Appointment confirmation/rejection
✅ Student-to-professor booking workflow
✅ Firestore integration ready
✅ Theme support (dark/light)


TESTING SCENARIOS:
═════════════════════════════════════════════════

Scenario 1: Professor Login
   1. Open app
   2. Look for "Demo Professor Account" section
   3. Click "Use Demo Account"
   4. Click Login
   5. See professor dashboard
   ✅ PASS: You're logged in as professor

Scenario 2: Professor Views Appointments
   1. Login as professor (see above)
   2. Click "My Appointments"
   3. See 3 tabs (Pending, Confirmed, History)
   ✅ PASS: Appointments screen loaded

Scenario 3: Student Books → Professor Sees
   1. Login as Student (use any email/password)
   2. Book any professor appointment
   3. Logout and login as professor
   4. Click "My Appointments" → "Pending"
   5. See the booking!
   ✅ PASS: Booking synced to professor

Scenario 4: Professor Confirms
   1. (Continuing from Scenario 3)
   2. Click "Confirm" on the appointment
   3. Appointment moves to "Confirmed" tab
   ✅ PASS: Status updated


TROUBLESHOOTING:
═════════════════════════════════════════════════

Issue: Can't see "Demo Professor Account" section
→ You're probably not on the login screen. Go back and try again.

Issue: Login fails with demo credentials
→ Check your internet connection
→ Check Firebase is initialized
→ Try manually entering credentials

Issue: Professor dashboard is blank
→ Make sure you logged in as "Professor" role
→ Check you're on /professorHome route

Issue: No appointments showing for professor
→ Student hasn't booked yet
→ Try booking as student first
→ Check Firestore database for appointmentID collection

Issue: Can't confirm/reject appointments
→ Check appointment is in correct status (should be "pending")
→ Check Firestore rules allow write access


NEXT STEPS:
═════════════════════════════════════════════════

✓ Test with demo credentials
✓ Create student accounts
✓ Book appointments as students
✓ Confirm from professor side
✓ Check Firestore data updates
✓ Test on different devices
✓ Verify notifications work
✓ Deploy to production


REMEMBER:
═════════════════════════════════════════════════

Your hardcoded professor account:
  📧 dr.ayesha.khan@lgs.edu.pk
  🔒 Professor@123

Keep it safe! This is your demo account! 🛡️

Questions? Check TESTING_GUIDE.md for detailed walkthrough!
