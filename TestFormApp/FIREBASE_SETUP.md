# Firebase Setup Guide for TestFormApp

This guide will walk you through setting up Firebase for the TestFormApp to enable document approval and sharing features.

## Features Enabled by Firebase

- ✅ **User Authentication**: Email/password and anonymous authentication
- ✅ **Cloud Storage**: Upload and store approved PDF documents
- ✅ **Firestore Database**: Store document metadata and approval information
- ✅ **Shared Access**: All authenticated users can view approved documents

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- Apple Developer Account (for device testing)
- Google Account (for Firebase Console)

## Step-by-Step Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `TestFormApp` (or your preferred name)
4. Disable Google Analytics (optional for this project)
5. Click "Create project"

### 2. Add iOS App to Firebase Project

1. In Firebase Console, click the iOS icon (or "Add app")
2. **Bundle ID**: Enter your app's bundle identifier
   - Default: `com.yourcompany.TestFormApp`
   - Find in Xcode: Select project → General → Bundle Identifier
3. **App nickname** (optional): `TestFormApp`
4. **App Store ID** (optional): Leave blank for now
5. Click "Register app"

### 3. Download Configuration File

1. Download the `GoogleService-Info.plist` file
2. In Xcode, right-click on `TestFormApp/Resources` folder
3. Select "Add Files to TestFormApp..."
4. Select the downloaded `GoogleService-Info.plist`
5. **IMPORTANT**: Check "Copy items if needed"
6. **IMPORTANT**: Ensure "TestFormApp" target is selected
7. Click "Add"

### 4. Install Firebase SDK

#### Option A: Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the Firebase iOS SDK URL:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Set version rule: **Up to Next Major Version** `10.0.0`
4. Click "Add Package"
5. Select the following products:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
6. Click "Add Package"

#### Option B: CocoaPods

If you prefer CocoaPods, add to your `Podfile`:

```ruby
platform :ios, '17.0'

target 'TestFormApp' do
  use_frameworks!

  # Firebase
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
end
```

Then run:
```bash
pod install
```

### 5. Enable Firebase Services

#### Enable Authentication

1. In Firebase Console, go to **Build → Authentication**
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable **Email/Password**:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"
5. Enable **Anonymous** (optional, for demo):
   - Click on "Anonymous"
   - Toggle "Enable"
   - Click "Save"

#### Enable Cloud Firestore

1. In Firebase Console, go to **Build → Firestore Database**
2. Click "Create database"
3. Choose production mode or test mode:
   - **Test mode**: Open for 30 days (recommended for development)
   - **Production mode**: Secure from day 1 (use rules below)
4. Select location (choose closest to your users)
5. Click "Enable"

#### Set Firestore Security Rules

Go to **Firestore Database → Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read all approved documents
    match /approved_documents/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
      allow delete: if request.auth != null &&
                    (request.auth.token.email == resource.data.approvedByEmail ||
                     request.auth.uid == resource.data.approvedBy);
    }
  }
}
```

Click "Publish"

#### Enable Cloud Storage

1. In Firebase Console, go to **Build → Storage**
2. Click "Get started"
3. Choose security rules:
   - **Test mode**: Open for 30 days (for development)
   - **Production mode**: Secure (use rules below)
4. Select location (same as Firestore)
5. Click "Done"

#### Set Storage Security Rules

Go to **Storage → Rules** and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to read all approved documents
    match /approved_documents/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
      allow delete: if request.auth != null;
    }
  }
}
```

Click "Publish"

### 6. Configure App Info.plist

1. Open `Info.plist` in Xcode
2. Add the following keys if they don't exist:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to save PDFs to your photo library</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access for signature capture</string>
```

### 7. Test Firebase Integration

1. Build and run the app (⌘R)
2. Navigate to "Onaylı Dökümanlar" (Approved Documents)
3. Tap "Giriş Yap" (Sign In)
4. Choose authentication method:
   - **Email/Password**: Register a new account
   - **Anonim Giriş (Demo)**: Sign in anonymously
5. After authentication, you should see the authenticated state

### 8. Test Document Approval Flow

1. Create and fill out a test form
2. Complete all required fields (100% completion)
3. Tap menu (⋯) → "Onayla ve Yükle" (Approve and Upload)
4. Review document information
5. Tap "Onayla ve Yükle" button
6. Document will be uploaded to Firebase Storage
7. Metadata will be saved to Firestore
8. Navigate to "Onaylı Dökümanlar" to see the uploaded document

## Firestore Data Structure

### Collection: `approved_documents`

Document structure:
```json
{
  "id": "UUID string",
  "templateId": "form_template_id",
  "templateTitle": "UPS Panosu L2 Test",
  "category": "UPS",
  "level": "L2",
  "equipmentName": "Equipment name",
  "equipmentNumber": "Equipment number",
  "testDate": Timestamp,
  "approvedBy": "User display name",
  "approvedByEmail": "user@example.com",
  "approvedDate": Timestamp,
  "pdfStoragePath": "approved_documents/filename.pdf",
  "pdfDownloadURL": "https://firebasestorage...",
  "completionPercentage": 100.0
}
```

## Firebase Storage Structure

```
/approved_documents/
  ├── UPS_L2_uuid-1_timestamp.pdf
  ├── UPS_L2_uuid-2_timestamp.pdf
  └── Trafo_L1_uuid-3_timestamp.pdf
```

## Troubleshooting

### Firebase Not Initializing

**Error**: `FirebaseApp.app() == nil`

**Solution**:
- Verify `GoogleService-Info.plist` is added to project
- Check target membership in File Inspector
- Ensure bundle ID matches Firebase configuration

### Authentication Fails

**Error**: "Authentication failed"

**Solution**:
- Verify Email/Password is enabled in Firebase Console
- Check network connection
- Verify Firebase configuration

### Upload Fails

**Error**: "Permission denied" or "403 Forbidden"

**Solution**:
- Check Firestore security rules
- Check Storage security rules
- Ensure user is authenticated
- Verify storage bucket name in `GoogleService-Info.plist`

### Documents Not Appearing

**Error**: Approved documents list is empty

**Solution**:
- Verify Firestore rules allow read access
- Check user authentication state
- Verify documents were uploaded successfully
- Check Firestore console for documents

## Security Best Practices

### Production Deployment

Before deploying to production:

1. **Update Security Rules**:
   - Implement proper validation
   - Add rate limiting
   - Restrict delete operations

2. **Enable App Check**:
   - Protect against abuse
   - Verify requests come from your app

3. **Monitor Usage**:
   - Set up budget alerts
   - Monitor storage usage
   - Review authentication logs

### Recommended Production Rules

**Firestore**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /approved_documents/{document} {
      allow read: if request.auth != null;
      allow create: if request.auth != null &&
                    request.resource.data.approvedByEmail == request.auth.token.email &&
                    request.resource.data.completionPercentage == 100;
      allow update: if false; // Approved documents should not be modified
      allow delete: if request.auth != null &&
                    request.auth.token.email == resource.data.approvedByEmail;
    }
  }
}
```

**Storage**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /approved_documents/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                   request.resource.size < 10 * 1024 * 1024 && // 10MB limit
                   request.resource.contentType == 'application/pdf';
      allow delete: if request.auth != null;
    }
  }
}
```

## Cost Estimation

Firebase free tier includes:
- **Authentication**: Unlimited users
- **Firestore**: 1GB storage, 50K reads/day, 20K writes/day
- **Storage**: 5GB storage, 1GB/day downloads
- **Network**: 10GB/month

For typical usage (10-50 users, 100 documents/month):
- Should stay within free tier
- Monitor usage in Firebase Console

## Support

For issues:
1. Check Firebase Console logs
2. Review Xcode console for errors
3. Verify all setup steps completed
4. Check Firebase status page

## Additional Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Authentication Guide](https://firebase.google.com/docs/auth/ios/start)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore/quickstart)
- [Cloud Storage Guide](https://firebase.google.com/docs/storage/ios/start)
