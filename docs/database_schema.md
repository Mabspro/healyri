# HeaLyri: Database Schema

This document outlines the Firestore database schema for the HeaLyri application, detailing collections, documents, fields, and relationships.

## Overview

HeaLyri uses Cloud Firestore, a NoSQL document database, to store application data. The schema is designed to support the core features of the application while allowing for scalability and future enhancements.

## Collections

### Users

Stores information about all users of the system, including patients, healthcare providers, and administrators.

**Collection**: `users`

**Document ID**: Auto-generated user ID from Firebase Authentication

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| uid | string | User ID (matches document ID) |
| email | string | User's email address |
| phoneNumber | string | User's phone number |
| displayName | string | User's full name |
| photoURL | string | URL to user's profile photo (optional) |
| role | string | User role: "patient", "provider", "admin" |
| createdAt | timestamp | When the user account was created |
| lastLogin | timestamp | When the user last logged in |
| isActive | boolean | Whether the user account is active |
| fcmTokens | map | Map of user's FCM tokens for notifications |

**Sub-collections**:

#### User Profiles

**Collection**: `users/{userId}/profile`

**Document ID**: "details"

**Fields for Patient Profile**:

| Field | Type | Description |
|-------|------|-------------|
| dateOfBirth | timestamp | Patient's date of birth |
| gender | string | Patient's gender |
| address | map | Patient's address (street, city, province, postalCode) |
| emergencyContact | map | Emergency contact information (name, relationship, phone) |
| medicalHistory | array | List of medical conditions (optional) |
| allergies | array | List of allergies (optional) |
| bloodType | string | Patient's blood type (optional) |
| insuranceInfo | map | Insurance details (provider, policyNumber) (optional) |

**Fields for Provider Profile**:

| Field | Type | Description |
|-------|------|-------------|
| title | string | Professional title (Dr., Nurse, etc.) |
| specialization | string | Medical specialization |
| licenseNumber | string | Professional license number |
| facilityIds | array | List of facilities where the provider works |
| education | array | Educational background |
| yearsOfExperience | number | Years of professional experience |
| languages | array | Languages spoken |
| availability | map | Weekly availability schedule |
| bio | string | Professional biography |
| isVolunteer | boolean | Whether the provider is a volunteer |

### Facilities

Stores information about healthcare facilities such as hospitals, clinics, and pharmacies.

**Collection**: `facilities`

**Document ID**: Auto-generated

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| name | string | Facility name |
| type | string | Facility type: "hospital", "clinic", "pharmacy" |
| address | map | Physical address (street, city, province, postalCode) |
| location | geopoint | Geographic coordinates for mapping |
| contactPhone | string | Primary contact phone number |
| contactEmail | string | Contact email address |
| website | string | Facility website (optional) |
| operatingHours | map | Operating hours by day of week |
| services | array | List of services offered |
| specialties | array | Medical specialties available |
| paymentOptions | array | Accepted payment methods |
| insuranceAccepted | array | Accepted insurance providers |
| photos | array | URLs to facility photos |
| adminUsers | array | User IDs of facility administrators |
| createdAt | timestamp | When the facility was added to the system |
| updatedAt | timestamp | When the facility was last updated |
| isVerified | boolean | Whether the facility is verified |
| averageRating | number | Average rating from reviews |
| totalReviews | number | Total number of reviews |

**Sub-collections**:

#### Facility Reviews

**Collection**: `facilities/{facilityId}/reviews`

**Document ID**: Auto-generated

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| userId | string | ID of user who left the review |
| userName | string | Name of user who left the review |
| rating | number | Rating (1-5) |
| comment | string | Review text |
| createdAt | timestamp | When the review was created |
| updatedAt | timestamp | When the review was last updated |
| isVisible | boolean | Whether the review is publicly visible |

#### Facility Availability

**Collection**: `facilities/{facilityId}/availability`

**Document ID**: Date string in format "YYYY-MM-DD"

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| date | string | Date string (YYYY-MM-DD) |
| slots | array | Array of available time slots |
| providers | map | Map of provider IDs to their available slots |
| isHoliday | boolean | Whether the facility is closed for a holiday |
| specialHours | map | Special operating hours if different from normal |
| lastUpdated | timestamp | When the availability was last updated |

### Appointments

Stores information about appointments booked by patients.

**Collection**: `appointments`

**Document ID**: Auto-generated

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| patientId | string | ID of the patient |
| patientName | string | Name of the patient |
| facilityId | string | ID of the facility |
| facilityName | string | Name of the facility |
| providerId | string | ID of the healthcare provider (optional) |
| providerName | string | Name of the healthcare provider (optional) |
| serviceType | string | Type of service requested |
| dateTime | timestamp | Date and time of the appointment |
| duration | number | Duration in minutes |
| status | string | Status: "pending", "confirmed", "completed", "cancelled", "no-show" |
| notes | string | Additional notes or reason for visit |
| symptoms | array | List of symptoms (for triage) |
| createdAt | timestamp | When the appointment was created |
| updatedAt | timestamp | When the appointment was last updated |
| reminderSent | boolean | Whether a reminder has been sent |
| followUpNeeded | boolean | Whether follow-up is recommended |
| isVirtual | boolean | Whether it's a virtual/telehealth appointment |

**Sub-collections**:

#### Appointment Payments

**Collection**: `appointments/{appointmentId}/payments`

**Document ID**: Auto-generated or "primary"

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| amount | number | Payment amount |
| currency | string | Currency code (e.g., "ZMW") |
| status | string | Status: "pending", "paid", "refunded", "failed" |
| method | string | Payment method: "mobile_money", "cash", "credit", etc. |
| provider | string | Payment provider: "MTN", "Airtel", etc. |
| reference | string | Payment reference/transaction ID |
| receiptUrl | string | URL to digital receipt (optional) |
| createdAt | timestamp | When the payment was created |
| updatedAt | timestamp | When the payment was last updated |
| processedBy | string | User ID of staff who processed the payment (for cash) |

### Medications

Stores information about medications for the drug verification feature.

**Collection**: `medications`

**Document ID**: Medication barcode or QR code

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| name | string | Medication name |
| genericName | string | Generic/scientific name |
| manufacturer | string | Manufacturer name |
| batchNumber | string | Batch/lot number |
| expiryDate | timestamp | Expiration date |
| dosageForm | string | Form: "tablet", "capsule", "liquid", etc. |
| strength | string | Medication strength |
| usageInstructions | string | How to use the medication |
| sideEffects | array | Common side effects |
| warnings | array | Important warnings |
| storageInstructions | string | How to store the medication |
| isVerified | boolean | Whether the medication is verified as authentic |
| verificationSource | string | Source of verification |
| imageUrl | string | URL to medication image |
| createdAt | timestamp | When the record was created |
| updatedAt | timestamp | When the record was last updated |

### Telehealth

Stores information about telehealth sessions and volunteer availability.

**Collection**: `telehealth`

**Sub-collections**:

#### Volunteer Availability

**Collection**: `telehealth/volunteers/availability`

**Document ID**: User ID of volunteer

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| userId | string | User ID of volunteer |
| name | string | Name of volunteer |
| specialization | string | Medical specialization |
| weeklySchedule | map | Regular weekly availability |
| specialDates | array | Special availability dates |
| unavailableDates | array | Dates when not available |
| maxSessionsPerDay | number | Maximum sessions per day |
| sessionDuration | number | Standard session duration in minutes |
| languages | array | Languages spoken |
| isActive | boolean | Whether the volunteer is currently active |
| lastUpdated | timestamp | When the availability was last updated |

#### Telehealth Sessions

**Collection**: `telehealth/sessions/records`

**Document ID**: Auto-generated

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| patientId | string | User ID of patient |
| patientName | string | Name of patient |
| volunteerId | string | User ID of volunteer provider |
| volunteerName | string | Name of volunteer provider |
| scheduledStart | timestamp | Scheduled start time |
| scheduledEnd | timestamp | Scheduled end time |
| actualStart | timestamp | Actual start time |
| actualEnd | timestamp | Actual end time |
| status | string | Status: "scheduled", "in-progress", "completed", "cancelled", "missed" |
| primaryConcern | string | Main health concern |
| notes | string | Session notes |
| followUpRecommended | boolean | Whether follow-up is recommended |
| referralMade | boolean | Whether patient was referred to local facility |
| createdAt | timestamp | When the session was created |
| updatedAt | timestamp | When the session was last updated |

### AI Triage

Stores information related to the AI triage and chatbot feature.

**Collection**: `triage`

**Document ID**: Auto-generated

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| userId | string | User ID (if authenticated) |
| sessionId | string | Session identifier |
| symptoms | array | Reported symptoms |
| responses | array | User responses to questions |
| urgencyLevel | string | Assessed urgency: "low", "medium", "high" |
| recommendedAction | string | Recommended next steps |
| createdAt | timestamp | When the triage session started |
| completedAt | timestamp | When the triage session ended |
| duration | number | Session duration in seconds |
| leadToAppointment | boolean | Whether the triage led to an appointment |
| appointmentId | string | ID of resulting appointment (if any) |

## Indexes

The following composite indexes will be needed:

1. `appointments` collection:
   - Fields: `patientId` (ASC), `dateTime` (DESC)
   - Purpose: Efficiently query a patient's appointments by date

2. `appointments` collection:
   - Fields: `facilityId` (ASC), `dateTime` (ASC), `status` (ASC)
   - Purpose: Efficiently query upcoming appointments for a facility

3. `telehealth/sessions/records` collection:
   - Fields: `volunteerId` (ASC), `scheduledStart` (ASC)
   - Purpose: Efficiently query upcoming sessions for a volunteer

4. `facilities` collection:
   - Fields: `type` (ASC), `location` (ASC)
   - Purpose: Geospatial queries for nearby facilities of a specific type

## Security Rules

Example Firestore security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isProvider() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'provider';
    }
    
    function isPatient() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'patient';
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // User rules
    match /users/{userId} {
      allow read: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && (isOwner(userId) || isAdmin());
      allow delete: if isAdmin();
      
      match /profile/{document=**} {
        allow read: if isAuthenticated() && (isOwner(userId) || isAdmin() || 
          (isProvider() && exists(/databases/$(database)/documents/appointments/$(appointmentId)) && 
          resource.data.patientId == userId && resource.data.providerId == request.auth.uid));
        allow write: if isAuthenticated() && (isOwner(userId) || isAdmin());
      }
    }
    
    // Facility rules
    match /facilities/{facilityId} {
      allow read: if true;
      allow create: if isAdmin();
      allow update: if isAdmin() || 
        (isProvider() && resource.data.adminUsers.hasAny([request.auth.uid]));
      allow delete: if isAdmin();
      
      match /reviews/{reviewId} {
        allow read: if true;
        allow create: if isAuthenticated();
        allow update, delete: if isAuthenticated() && 
          (resource.data.userId == request.auth.uid || isAdmin());
      }
      
      match /availability/{date} {
        allow read: if true;
        allow write: if isAdmin() || 
          (isProvider() && get(/databases/$(database)/documents/facilities/$(facilityId)).data.adminUsers.hasAny([request.auth.uid]));
      }
    }
    
    // Appointment rules
    match /appointments/{appointmentId} {
      allow read: if isAuthenticated() && 
        (resource.data.patientId == request.auth.uid || 
         resource.data.providerId == request.auth.uid || 
         isAdmin() || 
         (isProvider() && resource.data.facilityId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.facilityIds));
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
        (resource.data.patientId == request.auth.uid || 
         resource.data.providerId == request.auth.uid || 
         isAdmin() || 
         (isProvider() && resource.data.facilityId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.facilityIds));
      allow delete: if isAdmin();
      
      match /payments/{paymentId} {
        allow read: if isAuthenticated() && 
          (get(/databases/$(database)/documents/appointments/$(appointmentId)).data.patientId == request.auth.uid || 
           isAdmin());
        allow create, update: if isAuthenticated() && 
          (get(/databases/$(database)/documents/appointments/$(appointmentId)).data.patientId == request.auth.uid || 
           isAdmin() || 
           (isProvider() && get(/databases/$(database)/documents/appointments/$(appointmentId)).data.facilityId in 
            get(/databases/$(database)/documents/users/$(request.auth.uid)).data.facilityIds));
        allow delete: if isAdmin();
      }
    }
    
    // Medication rules
    match /medications/{medicationId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Telehealth rules
    match /telehealth/volunteers/availability/{volunteerId} {
      allow read: if true;
      allow write: if isAuthenticated() && 
        (request.auth.uid == volunteerId || isAdmin());
    }
    
    match /telehealth/sessions/records/{sessionId} {
      allow read: if isAuthenticated() && 
        (resource.data.patientId == request.auth.uid || 
         resource.data.volunteerId == request.auth.uid || 
         isAdmin());
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
        (resource.data.patientId == request.auth.uid || 
         resource.data.volunteerId == request.auth.uid || 
         isAdmin());
      allow delete: if isAdmin();
    }
    
    // Triage rules
    match /triage/{triageId} {
      allow read: if isAuthenticated() && 
        (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if true;
      allow update: if isAuthenticated() && 
        (resource.data.userId == request.auth.uid || isAdmin());
      allow delete: if isAdmin();
    }
  }
}
```

## Data Relationships

The following diagram illustrates the key relationships between collections:

```
User (Patient) 1 --- * Appointment * --- 1 Facility
                |                |
                |                |
                v                v
            Profile         Payment
                
User (Provider) 1 --- * Facility
                |
                |
                v
        Telehealth Availability
                |
                |
                v
        Telehealth Session * --- 1 User (Patient)
```

## Data Migration Strategy

For the initial deployment and future updates:

1. **Initial Seed Data**:
   - Create admin user(s)
   - Import initial facility data from CSV/JSON
   - Create test patient accounts

2. **Version Migrations**:
   - Use Cloud Functions to handle schema migrations
   - Implement data transformation logic for field changes
   - Add new fields with default values for backward compatibility

3. **Backup Strategy**:
   - Regular Firestore exports to Cloud Storage
   - Maintain version history of schema changes
   - Document migration scripts for each major version

## Performance Considerations

1. **Document Size**:
   - Keep documents under 1MB
   - Use sub-collections for potentially large data sets
   - Consider denormalization for frequently accessed data

2. **Query Optimization**:
   - Create composite indexes for common queries
   - Limit query results when possible
   - Use pagination for large result sets

3. **Caching Strategy**:
   - Implement client-side caching for frequently accessed data
   - Use Firestore offline persistence for mobile apps
   - Consider Redis or similar for server-side caching of computed data

## Data Validation

Implement validation at multiple levels:

1. **Client-Side**:
   - Form validation in the Flutter app
   - Data type and format checking

2. **Cloud Functions**:
   - Validate data before writing to Firestore
   - Enforce business rules and constraints

3. **Security Rules**:
   - Validate data structure and required fields
   - Enforce access control based on user roles

## Conclusion

This database schema provides a foundation for the HeaLyri application, supporting all core features while allowing for future expansion. The schema is designed with scalability, security, and performance in mind, following Firestore best practices.

As the application evolves, the schema may need to be adjusted to accommodate new features or optimize performance. Any changes should be carefully planned and documented to ensure data integrity and backward compatibility.
