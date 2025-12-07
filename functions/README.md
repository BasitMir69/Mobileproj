# Firebase Cloud Function Setup for Admission Email

## Prerequisites
1. Firebase CLI installed: `npm install -g firebase-tools`
2. Gmail account with App Password enabled

## Setup Steps

### 1. Enable Gmail App Password
1. Go to your Google Account settings
2. Security → 2-Step Verification (enable if not already)
3. App Passwords → Generate new app password for "Mail"
4. Copy the 16-character password

### 2. Install Dependencies
```bash
cd functions
npm install
```

### 3. Set Environment Variables
```bash
firebase functions:config:set mail.user="your-email@gmail.com"
firebase functions:config:set mail.pass="your-16-char-app-password"
```

Or set them in Firebase Console:
- Go to Firebase Console → Functions → Configuration
- Add environment variables:
  - `MAIL_USER`: Your Gmail address
  - `MAIL_PASS`: Your Gmail App Password

### 4. Deploy Function
```bash
firebase deploy --only functions
```

### 5. Get Function URL
After deployment, copy the function URL (e.g., `https://us-central1-yourproject.cloudfunctions.net/sendAdmissionEmail`)

### 6. Update Flutter App
Edit `lib/services/email_submission_service.dart`:
```dart
static const String _endpoint = 'YOUR_FUNCTION_URL_HERE';
```

## Testing Locally
```bash
cd functions
npm run serve
```
This will start the emulator at `http://localhost:5001/...`

## Troubleshooting
- If emails aren't sending, check Firebase Functions logs: `firebase functions:log`
- Ensure Gmail "Less secure app access" is NOT needed (App Passwords work with 2FA)
- Test the endpoint with curl:
```bash
curl -X POST YOUR_FUNCTION_URL \
  -H "Content-Type: application/json" \
  -d '{"parentName":"Test","parentEmail":"test@test.com","childName":"Child","to":"261936681@formanite.fccollege.edu.pk"}'
```
