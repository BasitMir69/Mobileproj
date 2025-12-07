const functions = require('firebase-functions/v2');
const nodemailer = require('nodemailer');
const admin = require('firebase-admin');

// Initialize Admin SDK for approval handling
try {
  admin.app();
} catch (_) {
  admin.initializeApp();
}

// Configure your Gmail credentials as environment variables
// Set these using: firebase functions:config:set mail.user="your@gmail.com" mail.pass="your-app-password"
// Or use environment variables in Firebase console

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.MAIL_USER,  // Your Gmail address
    pass: process.env.MAIL_PASS,  // Gmail App Password (not regular password)
  },
});

exports.sendAdmissionEmail = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.set('Access-Control-Max-Age', '3600');
    return res.status(204).send('');
  }

  if (req.method !== 'POST') {
    return res.status(405).send('Method not allowed');
  }

  try {
    const body = req.body || {};
    const submissionId = String(body.submissionId || '').trim();

    // Recipients: include both requested addresses by default
    const toList = [
      body.to,
      '261936681@formanite.fccollege.edu.pk',
      'abdulbasit9546@gmail.com',
    ].filter(Boolean);

    // Build HTML with inline image and approval links
    const origin = process.env.APPROVAL_BASE_URL || 'https://us-central1-campuswave-9f2b3.cloudfunctions.net';
    const approveUrl = submissionId
      ? `${origin}/admissionApproval?action=approve&submissionId=${encodeURIComponent(submissionId)}`
      : null;
    const rejectUrl = submissionId
      ? `${origin}/admissionApproval?action=reject&submissionId=${encodeURIComponent(submissionId)}`
      : null;

    const html = `
      <div style="font-family:Arial, Helvetica, sans-serif;">
        <h2 style="margin-bottom:8px;">Campus Wave - Admission Submission</h2>
        <p style="color:#555;margin-top:0;">A new admission form has been submitted.</p>
        <hr/>
        <h3>Parent Information</h3>
        <p><strong>Name:</strong> ${body.parentName || '-'}<br/>
        <strong>Email:</strong> ${body.parentEmail || '-'}<br/>
        <strong>Phone:</strong> ${body.phone || '-'}</p>
        <h3>Child Information</h3>
        <p><strong>Name:</strong> ${body.childName || '-'}<br/>
        <strong>Gender:</strong> ${body.gender || '-'}<br/>
        <strong>DOB:</strong> ${body.childDob || '-'}<br/>
        <strong>Grade Applying:</strong> ${body.gradeApplying || '-'}<br/>
        <strong>Campus:</strong> ${body.campus || '-'}</p>
        ${body.notes ? `<p><strong>Notes:</strong> ${body.notes}</p>` : ''}
        ${body.imageBase64 ? `<h3>Uploaded Document</h3><img src="data:image/jpeg;base64,${body.imageBase64}" alt="Document" style="max-width:480px;border-radius:8px;border:1px solid #ddd;"/>` : ''}
        <hr/>
        <p><strong>Status:</strong> ${body.status || 'pending'}</p>
        ${approveUrl && rejectUrl ? `
        <div style="margin-top:16px;">
          <a href="${approveUrl}" style="background:#2e7d32;color:#fff;padding:10px 14px;text-decoration:none;border-radius:6px;margin-right:8px;">Approve</a>
          <a href="${rejectUrl}" style="background:#c62828;color:#fff;padding:10px 14px;text-decoration:none;border-radius:6px;">Reject</a>
        </div>
        <p style="color:#777;margin-top:12px;font-size:12px;">If buttons don’t work, copy these links:<br/>
          Approve: ${approveUrl}<br/>Reject: ${rejectUrl}
        </p>
        ` : ''}
      </div>`;

    const mailOptions = {
      from: process.env.MAIL_USER,
      to: toList,
      subject: `Admission Form - ${body.childName || 'New Submission'}`,
      html,
    };

    await transporter.sendMail(mailOptions);
    console.log('Email sent successfully for:', body.childName);
    return res.status(200).json({ success: true, message: 'Email sent successfully' });
  } catch (error) {
    console.error('Error sending email:', error);
    return res.status(500).json({ success: false, error: error.message || 'Failed to send email' });
  }
});

// Approval handler: updates Firestore status for admission_submissions
exports.admissionApproval = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'GET');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(204).send('');
  }
  try {
    const submissionId = String(req.query.submissionId || '').trim();
    const action = String(req.query.action || '').trim();
    if (!submissionId || !['approve', 'reject'].includes(action)) {
      return res.status(400).send('Invalid request');
    }
    const db = admin.firestore();
    const ref = db.collection('admission_submissions').doc(submissionId);
    const snap = await ref.get();
    if (!snap.exists) {
      return res.status(404).send('Submission not found');
    }
    const status = action === 'approve' ? 'approved' : 'rejected';
    await ref.update({ status, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    return res.send(`
      <html><body style="font-family:Arial;">
        <h2>Admission ${status}</h2>
        <p>Submission ID: ${submissionId}</p>
        <p>Status updated successfully.</p>
      </body></html>
    `);
  } catch (err) {
    console.error('Approval error:', err);
    return res.status(500).send('Internal error');
  }
});

// Send feedback email from students/professors
exports.sendFeedbackEmail = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.set('Access-Control-Max-Age', '3600');
    return res.status(204).send('');
  }
  if (req.method !== 'POST') {
    return res.status(405).send('Method not allowed');
  }
  try {
    const body = req.body || {};
    const message = String(body.message || '').trim();
    const role = String(body.role || '').trim();
    const userEmail = String(body.userEmail || '').trim();
    if (!message) {
      return res.status(400).json({ success: false, error: 'Message required' });
    }
    const toList = ['abdulbasit9546@gmail.com'];
    const html = `
      <div style="font-family:Arial, Helvetica, sans-serif;">
        <h2 style="margin-bottom:8px;">Campus Wave - Feedback</h2>
        <p style="color:#555;margin-top:0;">New feedback submitted.</p>
        <hr/>
        <p><strong>Role:</strong> ${role || 'unknown'}<br/>
        <strong>User Email:</strong> ${userEmail || '-'}<br/>
        <strong>Submitted At:</strong> ${new Date().toISOString()}</p>
        <h3>Message</h3>
        <p>${message.replace(/</g, '&lt;').replace(/>/g, '&gt;')}</p>
      </div>`;

    const mailOptions = {
      from: process.env.MAIL_USER,
      to: toList,
      subject: `Feedback from ${userEmail || 'user'}`,
      html,
    };
    await transporter.sendMail(mailOptions);
    return res.status(200).json({ success: true, message: 'Feedback sent' });
  } catch (err) {
    console.error('Feedback send error:', err);
    return res.status(500).json({ success: false, error: err.message || 'Internal error' });
  }
});
