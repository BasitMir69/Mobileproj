# Email Submission Setup Guide

## Current Implementation

The admission form stores submissions in Firestore with images embedded as base64. The email watcher sends beautifully formatted HTML emails with images directly embedded (no links needed).

## How It Works

1. **User submits form** → Data + image (as base64) saved to Firestore
2. **Email watcher** → Monitors Firestore for new submissions
3. **Sends formatted email** → HTML email with embedded image to `261936681@formanite.fccollege.edu.pk`

## Setup Instructions

### Option 1: Local Email Watcher (Recommended for Development)

1. **Get Firebase Service Account Key**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `serviceAccountKey.json` in project root

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Setup Gmail App Password**
   - Enable 2-Step Verification in your Google Account
   - Generate App Password: https://myaccount.google.com/apppasswords
   - Copy the 16-character password

4. **Set Environment Variables**
   ```bash
   # Windows PowerShell
   $env:MAIL_USER="your-email@gmail.com"
   $env:MAIL_PASS="your-16-char-app-password"
   
   # Or create a .env file (install dotenv package)
   ```

5. **Run Email Watcher**
   ```bash
   npm start
   ```
   
   Keep this running in the background. It will automatically send emails when new submissions appear.

### Option 2: Deploy to a Server

Deploy `email-watcher.js` to:
- **Heroku** (free tier available)
- **Render** (free tier available)
- **Your own VPS**
- **Railway** (free tier available)

### Option 3: Upgrade to Firebase Blaze Plan

If you upgrade Firebase to Blaze (pay-as-you-go), you can deploy the Cloud Function:

```bash
firebase deploy --only functions
```

Then update `lib/services/email_submission_service.dart` with the function URL.

## Testing

1. **Run Flutter app**:
   ```bash
   flutter run -d emulator-5554
   ```

2. **Submit an admission form** with all details and an image

3. **Check Firestore** (Firebase Console → Firestore Database):
   - Look for new document in `admission_submissions` collection
   - Verify `emailSent: false`

4. **Start email watcher** (if not running):
   ```bash
   npm start
   ```

5. **Verify email**:
   - Check `261936681@formanite.fccollege.edu.pk` inbox
   - Document should update to `emailSent: true` in Firestore

## Troubleshooting

**Firestore permissions error?**
- Update `firestore.rules` to allow writes to `admission_submissions`:
  ```
  allow write: if request.auth != null;
  ```

**Image not showing?**
- Check Firebase Storage rules allow uploads
- Verify image file exists at the path

**Email not sending?**
- Check Gmail credentials
- Verify Gmail App Password (not regular password)
- Check email-watcher.js console output for errors

## Firestore Rules

Update `firestore.rules` to allow authenticated users to submit:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /admission_submissions/{document} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
    }
  }
}
```
