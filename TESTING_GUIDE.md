🧪 TESTING GUIDE - PROFESSOR SIGN-IN & APPOINTMENTS
====================================================

QUICK START - USE DEMO ACCOUNT:

1. Open app and go to login screen
2. Look for "Demo Professor Account" section (blue info box)
3. You'll see:
   Email: dr.ayesha.khan@lgs.edu.pk
   Password: Professor@123
4. Click "Use Demo Account" button - it auto-fills everything
5. Make sure "Professor" role is selected (it will be after clicking the button)
6. Click "Login"
7. You're now in Professor Dashboard!

OR MANUAL LOGIN:

1. Select "Professor" role toggle at top
2. Enter:
   Email: dr.ayesha.khan@lgs.edu.pk
   Password: Professor@123
3. Click Login


TESTING WORKFLOW:

SCENARIO 1: Test Professor Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Login as professor (see above)
2. You should see:
   ✓ Welcome card with "Dr. Ayesha Khan"
   ✓ Department: "Biology"
   ✓ Campus: "LGS Gulberg Campus 2"
   ✓ Stats showing 0 appointments
   ✓ Three action cards
3. Click "My Appointments" → should show empty list (no bookings yet)
4. Click Logout at top right


SCENARIO 2: Test Student Booking → Professor Sees It
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A. STUDENT SIDE:
   1. Logout (if logged in as professor)
   2. Click Login again
   3. Select "Student" role
   4. Use any email/password (or sign up new)
   5. Go to "Professors" tab
   6. Find any professor
   7. Click "Book" or tap on professor
   8. Click a time slot (e.g., "Tue 10:00")
   9. Confirm the booking dialog
   10. You'll be redirected to "My Appointments"
   11. You should see your booking there ✓

B. PROFESSOR SIDE:
   1. Logout (from student)
   2. Login as professor (use demo credentials)
   3. Click "My Appointments"
   4. Go to "Pending" tab
   5. You should see the student's appointment! ✓
   6. You can:
      - Click "Confirm" to approve it
      - Click "Reject" to reject it (with optional notes)
   7. Confirmed appointments move to "Confirmed" tab


SCENARIO 3: Test Role-Based Routing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Login as Student:
   → Should route to /home (student home with 5 tabs)
2. Login as Professor:
   → Should route to /professorHome (professor dashboard)


SCENARIO 4: Test Demo Account Button
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Go to login screen
2. Manually clear email and password fields (if filled)
3. Look for "Demo Professor Account" section
4. Click "Use Demo Account" button
5. Verify:
   ✓ Email field: dr.ayesha.khan@lgs.edu.pk
   ✓ Password field: Professor@123
   ✓ "Professor" role is selected
6. Click Login to confirm it works


IMPORTANT NOTES:

1. Demo Credentials:
   Email: dr.ayesha.khan@lgs.edu.pk
   Password: Professor@123

2. First Time Setup:
   - If this is your first login with the demo account, Firestore 
     will create the user and professor profile automatically
   - Professor profile is loaded from Firestore, so make sure 
     Firebase rules allow this

3. Firestore Collections Used:
   - appointmentID → where student bookings are saved
   - users → user profiles with roles
   - professors → professor details

4. Real-Time Updates:
   - Appointments use Firestore streams, so updates are real-time
   - If you book from student and check professor side immediately,
     you'll see it without refreshing

5. Notifications:
   - When a student books, a reminder notification is scheduled
   - For professors, confirm/reject actions update Firestore in real-time

TROUBLESHOOTING:

Q: Demo Account Button Not Showing?
A: Make sure you're on the login screen. Look for the blue info box 
   before the role selection.

Q: Login Failed with Demo Credentials?
A: 1. Check Firebase is initialized
   2. Check internet connection
   3. Try using email/password fields manually
   4. Check Firebase Auth has the user created

Q: Professor Dashboard Shows Empty?
A: 1. Check you logged in with "Professor" role selected
   2. Check Firestore has professor data for this user
   3. Try logout and login again

Q: Can't See Student Appointment in Professor View?
A: 1. Make sure student completed the booking (should see in their /appointments)
   2. Check both are using same Firebase project
   3. Try refreshing professor appointments screen
   4. Check Firestore database has appointmentID collection with data

Q: Getting "User not authenticated" error?
A: 1. Check you're logged in (avatar should show at top right)
   2. Try logging out and back in
   3. Check Firebase Auth rules


FILES TO REVIEW:

1. Demo Account Definition:
   → lib/data/hardcoded_professor.dart

2. Login Screen with Demo Button:
   → lib/loginscreen_new.dart (lines ~200-240)

3. Professor Dashboard:
   → lib/screens/professor_home_screen.dart

4. Professor Appointments:
   → lib/screens/professor_appointments_screen.dart

5. Router Setup:
   → lib/router.dart (search for "professorHome")

6. Firestore Service:
   → lib/services/firestore_service.dart


EXPECTED BEHAVIOR:

✓ Login as professor → Professor Dashboard with welcome card
✓ Login as student → Student home with tabs
✓ Student books → Appointment saved to Firestore
✓ Professor checks → Sees student appointment in "Pending" tab
✓ Professor confirms → Appointment moves to "Confirmed" tab
✓ Professor rejects → Appointment moves to "History" tab


Happy Testing! 🚀
