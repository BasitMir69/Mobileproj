# 📧 Admission Form Email System - Clean Implementation

## ✨ Features

- **Image Preview**: Shows uploaded CNIC/B-Form image immediately in the form
- **Direct Email Embedding**: Images embedded directly in email (no links)
- **Formatted HTML Email**: Professional layout with all admission details
- **Automated Processing**: Background watcher sends emails automatically
- **Firestore Storage**: All submissions stored securely in Firebase

## 🏗️ Architecture

```
Flutter App (User)
    ↓
Fills admission form + uploads image
    ↓
Converts image to base64
    ↓
Saves to Firestore (admission_submissions)
    ↓
Email Watcher (Node.js) detects new submission
    ↓
Generates HTML email with embedded image
    ↓
Sends to: 261936681@formanite.fccollege.edu.pk
    ↓
Marks as sent in Firestore
```

## 📁 Key Files

### Flutter App
- **`lib/services/email_submission_service.dart`**
  - Converts images to base64
  - Submits forms to Firestore
  - Clean, organized code

- **`lib/screens/admission_form_screen.dart`**
  - Shows image preview after upload
  - Validates all form fields
  - Calls email service on submit

### Backend
- **`email-watcher.js`**
  - Monitors Firestore for new submissions
  - Generates formatted HTML emails
  - Embeds images directly in email body
  - Handles errors gracefully

- **`start-email-watcher.ps1`**
  - Easy setup script for Windows
  - Validates prerequisites
  - Starts the watcher service

## 🚀 Quick Start

### 1. Get Firebase Service Account
```bash
Firebase Console → Project Settings → Service Accounts
→ Generate New Private Key → Save as serviceAccountKey.json
```

### 2. Setup Gmail App Password
```
Google Account → Security → 2-Step Verification → App Passwords
→ Generate for "Mail" → Copy 16-character password
```

### 3. Install & Run
```powershell
# Install dependencies
npm install

# Start email watcher
.\start-email-watcher.ps1

# Or manually:
$env:MAIL_USER = "your-email@gmail.com"
$env:MAIL_PASS = "your-app-password"
npm start
```

### 4. Test the System
```bash
# Run Flutter app
flutter run -d emulator-5554

# Submit a test admission form
# Check console for email watcher logs
# Verify email received at recipient address
```

## 📧 Email Format

The generated email includes:

- **Professional HTML Layout** with proper styling
- **Parent Information** section
- **Child Information** section with gender, DOB, grade
- **Application Details** with status and test date
- **Embedded Image** showing CNIC/B-Form document
- **Timestamp** of submission

## 🔒 Security

- Firestore rules enforce authentication
- Only authenticated users can submit forms
- Email watcher runs server-side (not exposed to client)
- Gmail App Password (not regular password)
- Base64 images stored temporarily in Firestore

## 🎯 Benefits

✅ **No Firebase Blaze plan required**
✅ **No external image hosting**
✅ **Images embedded directly in email**
✅ **Professional HTML formatting**
✅ **Automatic error handling**
✅ **Clean, maintainable code**
✅ **Works offline (saves to Firestore)**

## 📊 Monitoring

Check Firestore Console:
- Collection: `admission_submissions`
- Fields: `emailSent`, `emailSentAt`, `emailError`
- Monitor success/failure rates

Check email-watcher.js console:
- Real-time submission notifications
- Email send confirmations
- Error messages with details

## 🛠️ Troubleshooting

**Image not showing in email?**
- Verify image was uploaded (check form preview)
- Check Firestore document has `imageBase64` field
- Some email clients may block embedded images

**Email not sending?**
- Verify Gmail credentials in environment variables
- Check email-watcher.js is running
- Look for error logs in Firestore document
- Ensure Gmail App Password (not regular password)

**Form submission failing?**
- Check user is authenticated
- Verify Firestore rules are deployed
- Check network connectivity
- Look for errors in Flutter debug console

## 📝 Code Quality

All code follows best practices:
- Clear variable naming
- Proper error handling
- Organized structure
- Inline documentation
- Type safety

---

**Recipient Email**: `261936681@formanite.fccollege.edu.pk`  
**Last Updated**: December 6, 2025
