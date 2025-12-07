import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_wave/data/admission_form.dart';

/// Service for submitting admission forms to Firestore.
/// Converts images to base64 for direct email embedding.
class EmailSubmissionService {
  static final _firestore = FirebaseFirestore.instance;
  static const _recipientEmail = '261936681@formanite.fccollege.edu.pk';

  /// Submits admission form with embedded image data to Firestore.
  /// The image is converted to base64 for direct email embedding.
  static Future<void> send(AdmissionForm form) async {
    String? imageBase64;

    // Convert image to base64 if exists
    if (form.documentPath != null && form.documentPath!.isNotEmpty) {
      try {
        final file = File(form.documentPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          imageBase64 = base64Encode(bytes);
        }
      } catch (e) {
        // Continue without image if file cannot be read
      }
    }

    // Store submission in Firestore with base64 image
    final submission = {
      'parentName': form.parentName,
      'parentEmail': form.parentEmail,
      'phone': form.phone,
      'childName': form.childName,
      'gender': form.gender,
      'childDob': form.childDob,
      'gradeApplying': form.gradeApplying,
      'campus': form.campus,
      'status': form.status,
      'testDate': form.testDate,
      'notes': form.notes,
      'imageBase64': imageBase64,
      'emailTo': _recipientEmail,
      'emailSent': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('admission_submissions').add(submission);
  }
}
