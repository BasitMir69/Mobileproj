import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:campus_wave/services/firestore_service.dart';
import 'package:campus_wave/data/hardcoded_professor.dart';
import 'package:flutter/foundation.dart';

/// Service to initialize the app with demo data
/// This ensures the demo professor account exists in Firebase
class InitializationService {
  static final _auth = FirebaseAuth.instance;

  /// Initialize the app - sets up demo professor if needed
  static Future<void> initializeApp() async {
    try {
      debugPrint('🚀 Initializing Campus Wave App...');

      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('⚠️ Firebase not initialized');
        return;
      }

      // Try to set up demo professor account
      await _setupDemoProfessor();

      // Ensure admin account exists and has correct role
      await _setupAdminAccount();

      debugPrint('✅ App initialization complete');
    } catch (e) {
      debugPrint('❌ App initialization error\: $e');
    }
  }

  /// Sets up the demo professor account if it doesn't exist
  static Future<void> _setupDemoProfessor() async {
    try {
      debugPrint('📚 Setting up demo professor account...');
      // Check if demo professor exists without signing in
      final methods = await _auth.fetchSignInMethodsForEmail(
        HardcodedProfessor.email,
      );

      if (methods.isEmpty) {
        debugPrint(
            '📝 Demo professor not found, creating new account in Firebase...');
        // Create new account (will briefly log in), then sign out
        final result = await _auth.createUserWithEmailAndPassword(
          email: HardcodedProfessor.email,
          password: HardcodedProfessor.password,
        );
        if (result.user != null) {
          await result.user!.updateDisplayName(HardcodedProfessor.name);
          // Create professor profile with hardcoded ID for consistency
          await FirestoreService.setProfessorProfileWithId(
            docId: 'demo_professor',
            userId: result.user!.uid,
            name: HardcodedProfessor.name,
            campus: HardcodedProfessor.campus,
            department: HardcodedProfessor.department,
            title: HardcodedProfessor.title,
          );
          // Create user profile (role: professor)
          await FirestoreService.setUserProfile(
            userId: result.user!.uid,
            displayName: HardcodedProfessor.name,
            email: HardcodedProfessor.email,
            role: 'professor',
          );
          // Sign out so user can log in fresh
          await _auth.signOut();
          debugPrint('✅ Demo professor ready for login');
        }
      } else {
        debugPrint('✅ Demo professor already exists in Firebase Auth');
        // Optionally ensure Firestore profiles exist without signing in
        // This step assumes profiles were created previously.
      }
    } catch (e) {
      debugPrint('❌ Error setting up demo professor: $e');
      // Don't throw - app should continue to work even without demo setup
    }
  }

  // One-time admin account seeding (Option B roles)
  static const _adminEmail = 'admin@campuswave.com';
  static const _adminPassword = '11223344';

  static Future<void> _setupAdminAccount() async {
    try {
      debugPrint('👤 Checking admin account existence...');
      final methods = await _auth.fetchSignInMethodsForEmail(_adminEmail);

      if (methods.isEmpty) {
        debugPrint('📝 Admin not found, creating admin account...');
        final cred = await _auth.createUserWithEmailAndPassword(
          email: _adminEmail,
          password: _adminPassword,
        );
        if (cred.user != null) {
          await cred.user!.updateDisplayName('CampusWave Admin');
          await FirestoreService.setUserProfile(
            userId: cred.user!.uid,
            displayName: 'CampusWave Admin',
            email: _adminEmail,
            role: 'admin',
          );
          debugPrint('✅ Admin user profile created');
          await _auth.signOut();
          debugPrint('✅ Admin ready for login');
        }
      } else {
        debugPrint('✅ Admin account already exists');
        // Ensure role is set to admin
        final uid = (await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _adminEmail,
          password: _adminPassword,
        ))
            .user!
            .uid;
        await FirestoreService.setUserProfile(
          userId: uid,
          displayName: 'CampusWave Admin',
          email: _adminEmail,
          role: 'admin',
        );
        await _auth.signOut();
        debugPrint('🔄 Ensured admin role on user profile');
      }
    } catch (e) {
      debugPrint('⚠️ Admin seeding error: $e');
    }
  }

  /// Manually trigger demo professor setup (for debugging)
  /// Call this from the login screen if demo setup fails
  static Future<void> forceDemoProfessorSetup() async {
    try {
      debugPrint('🔄 Forcing demo professor setup...');
      await _setupDemoProfessor();
      debugPrint('✅ Demo professor setup complete');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  /// Check if demo professor exists in Firebase Auth
  static Future<bool> demoProfessorExists() async {
    try {
      debugPrint('🔍 Checking if demo professor exists...');

      // Try to sign in
      try {
        final result = await _auth.signInWithEmailAndPassword(
          email: HardcodedProfessor.email,
          password: HardcodedProfessor.password,
        );

        if (result.user != null) {
          debugPrint('✅ Demo professor EXISTS in Firebase Auth');
          await _auth.signOut();
          return true;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          debugPrint('❌ Demo professor DOES NOT EXIST - account not found');
          return false;
        } else if (e.code == 'wrong-password') {
          debugPrint('⚠️ Password is incorrect');
          return false;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error checking demo professor: $e');
      return false;
    }
  }
}
