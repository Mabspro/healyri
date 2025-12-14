/**
 * Seed Facilities Data for HeaLyri
 * 
 * Run with: node scripts/seed_facilities.js
 * 
 * Requires Firebase Admin SDK setup
 */

const admin = require('firebase-admin');
const path = require('path');

// Use the service account file from project root
const serviceAccountPath = path.join(__dirname, '..', 'healyri-af36a-firebase-adminsdk-fbsvc-ea3b7a38c5.json');

// Check if file exists
const fs = require('fs');
if (!fs.existsSync(serviceAccountPath)) {
  console.error('❌ Service account file not found at:', serviceAccountPath);
  console.error('   Please ensure the service account JSON file is in the project root.');
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Zambia facilities (Lusaka area)
const facilities = [
  {
    id: 'facility-lusaka-general',
    name: 'Lusaka General Hospital',
    type: 'hospital',
    address: '123 Independence Ave, Lusaka, Zambia',
    location: new admin.firestore.GeoPoint(-15.3875, 28.3228), // Lusaka coordinates
    contactPhone: '+260211234567',
    contactEmail: 'info@lusakageneral.gov.zm',
    services: ['Emergency', 'Surgery', 'Pediatrics', 'Maternity', 'Cardiology'],
    rating: 4.2,
    isVerified: true,
    acceptsNHIMA: true,
    operatingHours: {
      monday: '24/7',
      tuesday: '24/7',
      wednesday: '24/7',
      thursday: '24/7',
      friday: '24/7',
      saturday: '24/7',
      sunday: '24/7'
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  },
  {
    id: 'facility-uth',
    name: 'University Teaching Hospital',
    type: 'hospital',
    address: '10 Nationalist Road, Lusaka, Zambia',
    location: new admin.firestore.GeoPoint(-15.4000, 28.3300),
    contactPhone: '+260211234568',
    contactEmail: 'info@uth.gov.zm',
    services: ['Emergency', 'Surgery', 'Oncology', 'Cardiology', 'Neurology', 'Trauma'],
    rating: 4.0,
    isVerified: true,
    acceptsNHIMA: true,
    operatingHours: {
      monday: '24/7',
      tuesday: '24/7',
      wednesday: '24/7',
      thursday: '24/7',
      friday: '24/7',
      saturday: '24/7',
      sunday: '24/7'
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  },
  {
    id: 'facility-kanyama',
    name: 'Kanyama Clinic',
    type: 'clinic',
    address: '45 Kanyama Road, Lusaka, Zambia',
    location: new admin.firestore.GeoPoint(-15.4200, 28.3000),
    contactPhone: '+260211234569',
    contactEmail: 'info@kanyamaclinic.zm',
    services: ['General Medicine', 'Vaccinations', 'HIV Testing', 'Maternal Health', 'Child Health'],
    rating: 3.8,
    isVerified: true,
    acceptsNHIMA: true,
    operatingHours: {
      monday: '08:00-17:00',
      tuesday: '08:00-17:00',
      wednesday: '08:00-17:00',
      thursday: '08:00-17:00',
      friday: '08:00-17:00',
      saturday: '09:00-13:00',
      sunday: 'Closed'
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  },
  {
    id: 'facility-medplus',
    name: 'MedPlus Pharmacy',
    type: 'pharmacy',
    address: '78 Cairo Road, Lusaka, Zambia',
    location: new admin.firestore.GeoPoint(-15.4100, 28.3100),
    contactPhone: '+260211234570',
    contactEmail: 'info@medplus.zm',
    services: ['Prescription Filling', 'Health Consultations', 'Medical Supplies', 'Vaccinations'],
    rating: 4.5,
    isVerified: true,
    acceptsNHIMA: false,
    operatingHours: {
      monday: '08:00-18:00',
      tuesday: '08:00-18:00',
      wednesday: '08:00-18:00',
      thursday: '08:00-18:00',
      friday: '08:00-18:00',
      saturday: '09:00-16:00',
      sunday: '10:00-14:00'
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  },
  {
    id: 'facility-lusaka-medical',
    name: 'Lusaka Medical Center',
    type: 'hospital',
    address: '100 Great East Road, Lusaka, Zambia',
    location: new admin.firestore.GeoPoint(-15.3900, 28.3200),
    contactPhone: '+260211234571',
    contactEmail: 'info@lusakamedical.zm',
    services: ['Emergency', 'General Medicine', 'Surgery', 'Pediatrics', 'Maternity'],
    rating: 4.3,
    isVerified: true,
    acceptsNHIMA: true,
    operatingHours: {
      monday: '24/7',
      tuesday: '24/7',
      wednesday: '24/7',
      thursday: '24/7',
      friday: '24/7',
      saturday: '24/7',
      sunday: '24/7'
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  }
];

async function seedFacilities() {
  try {
    console.log('Starting facility seed...');
    
    for (const facility of facilities) {
      await db.collection('facilities').doc(facility.id).set(facility);
      console.log(`✓ Seeded facility: ${facility.name}`);
    }
    
    console.log(`\n✅ Successfully seeded ${facilities.length} facilities`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding facilities:', error);
    process.exit(1);
  }
}

seedFacilities();

