/**
 * Campus Wave Admission Email Watcher
 * Monitors Firestore for new admission submissions and sends formatted emails
 * with embedded images directly to the admissions office.
 */

const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Email configuration
const MAIL_CONFIG = {
  service: 'gmail',
  auth: {
    user: process.env.MAIL_USER || 'your-email@gmail.com',
    pass: process.env.MAIL_PASS || 'your-app-password',
  },
};

const transporter = nodemailer.createTransport(MAIL_CONFIG);

console.log('📧 Campus Wave Email Watcher Started');
console.log('=====================================');
console.log(`Sender: ${MAIL_CONFIG.auth.user}`);
console.log('Monitoring Firestore for new submissions...\n');

/**
 * Formats admission form data into HTML email with approval buttons
 */
function formatEmailHTML(data, docId) {
  // Create approval/rejection links
  const approveLink = `https://firestore.googleapis.com/v1/projects/campuswave-9f2b3/databases/(default)/documents/admission_submissions/${docId}?updateMask.fieldPaths=status&updateMask.fieldPaths=approvedAt`;
  
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }
        .header { background: #2c3e50; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border: 1px solid #ddd; border-radius: 0 0 8px 8px; }
        .section { margin-bottom: 25px; }
        .section-title { color: #2c3e50; font-size: 18px; font-weight: bold; border-bottom: 2px solid #3498db; padding-bottom: 5px; margin-bottom: 15px; }
        .info-row { margin: 8px 0; }
        .label { font-weight: bold; color: #555; display: inline-block; width: 150px; }
        .value { color: #333; }
        .image-container { margin: 20px 0; text-align: center; background: white; padding: 15px; border: 2px solid #ddd; border-radius: 8px; }
        .image-container img { max-width: 100%; height: auto; border-radius: 4px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .action-buttons { margin: 30px 0; text-align: center; padding: 20px; background: white; border: 2px solid #ddd; border-radius: 8px; }
        .action-btn { display: inline-block; padding: 12px 30px; margin: 0 10px; font-size: 16px; font-weight: bold; border-radius: 4px; text-decoration: none; cursor: pointer; }
        .approve-btn { background: #27ae60; color: white; }
        .approve-btn:hover { background: #229954; }
        .reject-btn { background: #e74c3c; color: white; }
        .reject-btn:hover { background: #c0392b; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 2px solid #ddd; text-align: center; color: #777; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>🎓 New Admission Request</h1>
        <p>Campus Wave Admission System</p>
      </div>
      
      <div class="content">
        <div class="section">
          <div class="section-title">👨‍👩‍👧 Parent Information</div>
          <div class="info-row"><span class="label">Full Name:</span> <span class="value">${data.parentName}</span></div>
          <div class="info-row"><span class="label">Email:</span> <span class="value">${data.parentEmail}</span></div>
          <div class="info-row"><span class="label">Phone:</span> <span class="value">${data.phone}</span></div>
        </div>

        <div class="section">
          <div class="section-title">👶 Child Information</div>
          <div class="info-row"><span class="label">Child Name:</span> <span class="value">${data.childName}</span></div>
          <div class="info-row"><span class="label">Gender:</span> <span class="value">${data.gender}</span></div>
          <div class="info-row"><span class="label">Date of Birth:</span> <span class="value">${data.childDob}</span></div>
          <div class="info-row"><span class="label">Grade Applying:</span> <span class="value">${data.gradeApplying}</span></div>
          <div class="info-row"><span class="label">Preferred Campus:</span> <span class="value">${data.campus}</span></div>
        </div>

        <div class="section">
          <div class="section-title">📋 Application Details</div>
          <div class="info-row"><span class="label">Status:</span> <span class="value">${data.status.toUpperCase()}</span></div>
          <div class="info-row"><span class="label">Test Date:</span> <span class="value">${data.testDate || 'To Be Determined'}</span></div>
          <div class="info-row"><span class="label">Notes:</span> <span class="value">${data.notes?.trim() || 'None'}</span></div>
        </div>

        ${data.imageBase64 ? `
        <div class="section">
          <div class="section-title">📄 CNIC / B-Form Document</div>
          <div class="image-container">
            <img src="data:image/jpeg;base64,${data.imageBase64}" alt="CNIC/B-Form Document" />
          </div>
        </div>
        ` : ''}

        <div class="action-buttons">
          <p><strong>Take Action:</strong></p>
          <a href="https://campuswave-app.web.app/admin/admission/${docId}/approve" class="action-btn approve-btn">✓ Approve</a>
          <a href="https://campuswave-app.web.app/admin/admission/${docId}/reject" class="action-btn reject-btn">✗ Reject</a>
          <p style="font-size: 12px; color: #666; margin-top: 15px;">
            Or use the Campus Wave Admin Portal to manage admissions
          </p>
        </div>

        <div class="footer">
          <p>Submission ID: ${docId}</p>
          <p>Submitted on: ${new Date().toLocaleString()}</p>
          <p>Campus Wave Admission System | Powered by Firebase</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

/**
 * Sends admission email with embedded image
 */
async function sendAdmissionEmail(doc, data) {
  const recipients = Array.isArray(data.emailTo) && data.emailTo.length
    ? data.emailTo
    : [
        '261936681@formanite.fccollege.edu.pk',
        'abdulbasit9546@gmail.com',
      ];

  const mailOptions = {
    from: MAIL_CONFIG.auth.user,
    to: recipients,
    subject: `🎓 New Admission Request - ${data.childName} (${data.gradeApplying})`,
    html: formatEmailHTML(data, doc.id),
  };

  await transporter.sendMail(mailOptions);

  await doc.ref.update({
    emailSent: true,
    emailSentAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Main watcher - monitors Firestore for new submissions
 */
const unsubscribe = db.collection('admission_submissions')
  .where('emailSent', '==', false)
  .onSnapshot(async snapshot => {
    for (const change of snapshot.docChanges()) {
      if (change.type === 'added') {
        const doc = change.doc;
        const data = doc.data();

        console.log(`\n📨 New submission detected:`);
        console.log(`   Child: ${data.childName}`);
        console.log(`   Grade: ${data.gradeApplying}`);
        console.log(`   Campus: ${data.campus}`);

        try {
          await sendAdmissionEmail(doc, data);
          console.log(`✅ Email sent successfully to ${data.emailTo}`);
        } catch (error) {
          console.error(`❌ Failed to send email:`, error.message);
          await doc.ref.update({
            emailError: error.message,
            emailAttemptedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }, error => {
    console.error('❌ Firestore watcher error:', error);
  });

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\n👋 Shutting down email watcher...');
  unsubscribe();
  process.exit(0);
});
