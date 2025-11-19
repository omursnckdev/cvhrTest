# Test Form Management Application

A comprehensive iOS application for managing electrical test forms with a role-based approval workflow system.

## Overview

This iOS application provides a complete solution for creating, managing, and approving electrical equipment test forms. Built with SwiftUI and SwiftData, it features a robust multi-role approval system designed for construction and inspection workflows.

## Features

### 🔐 Role-Based Authentication System

The app implements a three-tier user role system with distinct permissions and workflows:

#### **Müteahhit (Contractor)**
- Creates and fills out test forms
- Saves forms as drafts for later editing
- Submits completed forms for approval
- Views all personally created forms
- Full access to form creation interface

#### **Müşavir (Consultant)**
- Reviews forms submitted by contractors
- Previews forms as PDFs before approval
- Approves or rejects submitted forms
- Approved forms automatically move to employer queue
- Cannot create new forms

#### **İşVeren (Employer)**
- Final approval authority
- Reviews consultant-approved forms
- Previews forms as PDFs before final approval
- Approved forms saved to permanent archive
- Cannot create or initially approve forms

### 📋 Test Form Management

**Supported Equipment Categories:**
- UPS (Uninterruptible Power Supply)
- Trafo (Transformers)
- Jeneratör (Generators)
- RMU (Ring Main Units)
- Panel (Electrical Panels)

**Test Levels:**
- L1 (Level 1)
- L2 (Level 2)
- L3 (Level 3)

**Form Components:**
- Equipment information fields (text, numbers, dates, pickers)
- Interactive checklists with Yes/No/N/A/Unchecked options
- Issue log with responsibility tracking and deadlines
- Digital signature support using PencilKit
- Notes section for additional comments

### 🔄 Approval Workflow

1. **Draft Stage**: Contractor creates and edits form
2. **Pending Müşavir**: Form submitted, awaiting consultant review
3. **Pending İşVeren**: Consultant approved, awaiting employer review
4. **Approved**: Fully approved and archived by category

### 📱 User Interface

**Authentication:**
- User-friendly signup with role selection
- Secure login system
- Persistent sessions

**Navigation:**
- Tab-based interface for easy access
- Role-specific main views
- Unified approved documents archive
- User profile menu with logout

**Visual Design:**
- Status badges with color coding (Gray/Orange/Blue/Green)
- Progress tracking for form completion
- Category-based organization
- PDF preview capabilities

### 📄 PDF Export

- Generate professional PDF reports from any form
- Include all form data, checklists, issues, and signatures
- Share via iOS share sheet
- Preview before sharing

## Technical Architecture

### Technologies

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent data storage
- **PDFKit**: PDF generation and viewing
- **PencilKit**: Digital signature capture
- **iOS 17+**: Latest iOS features and APIs

### Data Models

**User Model:**
- Username, password, full name
- User role (Müteahhit/Müşavir/İşVeren)
- SwiftData persistence

**FilledForm Model:**
- Template reference
- Equipment information (JSON encoded)
- Checklist responses (JSON encoded)
- Issues, notes, attendees
- Approval workflow tracking
- Creator and approver information with timestamps

**FormTemplate Model:**
- Category and level classification
- Dynamic sections configuration
- Field definitions and validation
- Loaded from JSON bundle

### Project Structure

```
TestFormApp/
├── Models/
│   ├── User.swift
│   ├── FilledForm.swift
│   ├── FormTemplate.swift
│   ├── Enums.swift
│   └── DependencyModels.swift
├── Managers/
│   ├── UserManager.swift
│   ├── FilledFormDataManager.swift
│   ├── FormTemplateManager.swift
│   └── DependencyValidator.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── SignupView.swift
│   ├── Approval/
│   │   ├── ApprovalListView.swift
│   │   ├── FormDetailView.swift
│   │   └── ApprovedDocumentsView.swift
│   ├── FormViews/
│   │   ├── DynamicFormView.swift
│   │   ├── InfoSectionView.swift
│   │   ├── ChecklistSectionView.swift
│   │   ├── IssueLogSectionView.swift
│   │   ├── AttendeesSectionView.swift
│   │   └── NotesSectionView.swift
│   ├── Navigation/
│   │   ├── CategoryListView.swift
│   │   └── TestLevelListView.swift
│   └── Components/
├── Utilities/
│   ├── PDFGenerator.swift
│   └── Extensions.swift
└── Resources/
    └── form_templates.json
```

## Recent Updates

### Version 2.0 - Role-Based Authentication & Approval System

**New Features:**
- ✅ Complete user authentication system with signup/login
- ✅ Three-tier role system (Müteahhit/Müşavir/İşVeren)
- ✅ Multi-stage approval workflow
- ✅ Role-based UI with distinct views for each role
- ✅ Approval history tracking with timestamps
- ✅ PDF preview before approval
- ✅ Category-filtered approved documents archive
- ✅ User profile management with logout
- ✅ Status badges and visual workflow indicators
- ✅ Turkish language support throughout

**Technical Improvements:**
- Extended SwiftData schema with User model
- Enhanced FilledForm model with approval properties
- Created UserManager for authentication
- Added role-based filtering methods to data manager
- Implemented tab-based navigation with role-specific views
- Added approval workflow state machine

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Installation

1. Clone the repository
2. Open `TestFormApp.xcodeproj` in Xcode
3. Build and run on iOS Simulator or device

## Usage

### First Time Setup

1. Launch the app
2. Tap "Kayıt Ol" (Sign Up)
3. Enter username, full name, and password
4. Select your role (Müteahhit/Müşavir/İşVeren)
5. Tap "Kayıt Ol" to create account

### Creating a Form (Müteahhit)

1. Log in as Müteahhit
2. Select equipment category (e.g., Trafo, RMU)
3. Select test level (L1, L2, L3)
4. Fill out form sections
5. Save as draft or submit for approval

### Approving Forms (Müşavir/İşVeren)

1. Log in as Müşavir or İşVeren
2. View pending approvals in main tab
3. Tap form to view details
4. Preview PDF if needed
5. Tap "Onayla" (Approve) to approve

### Viewing Approved Forms

1. Navigate to "Onaylı Formlar" tab
2. Filter by category if desired
3. Tap any form to view details
4. Generate and share PDF

## License

Copyright © 2025. All rights reserved.

## Support

For issues or questions, please create an issue in the GitHub repository.
