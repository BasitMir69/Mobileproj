/**
 * Test script to preview the email format
 * Run: node test-email-format.js
 */

const sampleData = {
  parentName: "Ahmed Ali Khan",
  parentEmail: "ahmed.khan@example.com",
  phone: "+92-300-1234567",
  childName: "Sara Ahmed Khan",
  gender: "Female",
  childDob: "2018-03-15",
  gradeApplying: "Grade 1",
  campus: "Gulberg Campus",
  status: "pending",
  testDate: "2025-12-20",
  notes: "Child has nut allergies. Prefers morning classes.",
  imageBase64: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
  emailTo: "261936681@formanite.fccollege.edu.pk"
};

function formatEmailHTML(data) {
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

        <div class="footer">
          <p>Submitted on: ${new Date().toLocaleString()}</p>
          <p>Campus Wave Admission System | Powered by Firebase</p>
        </div>
      </div>
    </body>
    </html>
  `;
}

const fs = require('fs');
const html = formatEmailHTML(sampleData);
fs.writeFileSync('email-preview.html', html);
console.log('✅ Email preview saved to email-preview.html');
console.log('📧 Open the file in a browser to see how the email will look');
