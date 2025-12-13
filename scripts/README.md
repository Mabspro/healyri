# Healyri Data Seeding Script

This script is used to seed the Firestore database with initial data for the Healyri application.

## Prerequisites

1. Node.js installed on your system
2. Firebase project set up with Firestore enabled
3. Service account key file from Firebase Console

## Setup

1. Place your Firebase service account key file in the `scripts` directory and name it `service-account.json`
2. Install dependencies:
   ```bash
   npm install
   ```

## Running the Script

To seed the database with test data, run:
```bash
npm run seed
```

## Data Structure

The script creates the following test data:

### Users
- Test patients (John Doe, Jane Smith)
- Test doctors (Dr. Robert Johnson, Dr. Sarah Williams)

### Health Records
- Blood type, height, weight
- Allergies, medications, conditions
- Associated with test patients

### Appointments
- Scheduled appointments between patients and doctors
- Various statuses (scheduled, completed, cancelled)
- Notes and timestamps

## Note

This script will overwrite any existing data in the specified collections. Use with caution in production environments. 