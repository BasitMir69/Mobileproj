# Email Watcher Quick Start Script
# Run this in PowerShell to start the email monitoring service

Write-Host "📧 Campus Wave Email Watcher Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found. Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Check if service account key exists
if (-not (Test-Path "serviceAccountKey.json")) {
    Write-Host "❌ serviceAccountKey.json not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download your Firebase service account key:" -ForegroundColor Yellow
    Write-Host "1. Go to Firebase Console → Project Settings → Service Accounts" -ForegroundColor Yellow
    Write-Host "2. Click 'Generate New Private Key'" -ForegroundColor Yellow
    Write-Host "3. Save the file as 'serviceAccountKey.json' in this directory" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "✅ Service account key found" -ForegroundColor Green

# Check if dependencies are installed
if (-not (Test-Path "node_modules")) {
    Write-Host ""
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    npm install
}

Write-Host ""
Write-Host "⚙️  Configuration:" -ForegroundColor Cyan
Write-Host "- Email will be sent to: 261936681@formanite.fccollege.edu.pk" -ForegroundColor White

# Prompt for Gmail credentials if not set
if (-not $env:MAIL_USER) {
    Write-Host ""
    $mailUser = Read-Host "Enter your Gmail address (e.g., youremail@gmail.com)"
    $env:MAIL_USER = $mailUser
}

if (-not $env:MAIL_PASS) {
    Write-Host ""
    Write-Host "To get Gmail App Password:" -ForegroundColor Yellow
    Write-Host "1. Enable 2-Step Verification in your Google Account" -ForegroundColor Yellow
    Write-Host "2. Go to https://myaccount.google.com/apppasswords" -ForegroundColor Yellow
    Write-Host "3. Generate new app password for 'Mail'" -ForegroundColor Yellow
    Write-Host ""
    $mailPass = Read-Host "Enter your Gmail App Password (16 characters)" -AsSecureString
    $env:MAIL_PASS = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mailPass))
}

Write-Host ""
Write-Host "✅ Starting email watcher..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Start the watcher
npm start
