const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Helper function to generate a random date within a range
function randomDate(start, end) {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

// Helper function to generate a random ID
function generateId() {
  return Math.random().toString(36).substring(2, 15);
}

async function seedData() {
  try {
    // Create test users with different roles
    const users = [
      {
        id: 'test-patient-1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        role: 'patient',
        photoURL: 'https://randomuser.me/api/portraits/men/1.jpg',
        phone: '+1-555-0123',
        address: '123 Main St, City, State',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        emailVerified: true,
        isVerified: true
      },
      {
        id: 'test-provider-1',
        name: 'Dr. Sarah Williams',
        email: 'sarah.williams@example.com',
        role: 'provider',
        photoURL: 'https://randomuser.me/api/portraits/women/1.jpg',
        phone: '+1-555-0124',
        address: '456 Medical Center Dr, City, State',
        specialization: 'Cardiologist',
        experience: 15,
        rating: 4.8,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        emailVerified: true,
        isVerified: true
      },
      {
        id: 'test-driver-1',
        name: 'Mike Johnson',
        email: 'mike.johnson@example.com',
        role: 'driver',
        photoURL: 'https://randomuser.me/api/portraits/men/2.jpg',
        phone: '+1-555-0125',
        address: '789 Transport Ave, City, State',
        vehicleInfo: {
          type: 'SUV',
          model: 'Toyota Highlander',
          year: '2020',
          licensePlate: 'ABC123'
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        emailVerified: true,
        isVerified: true
      }
    ];

    // Create test facilities
    const facilities = [
      {
        id: 'facility-1',
        name: 'City General Hospital',
        address: '123 Hospital Ave, City, State',
        phone: '+1-555-0126',
        type: 'Hospital',
        services: ['Emergency', 'Surgery', 'Cardiology'],
        rating: 4.5,
        operatingHours: {
          monday: '24/7',
          tuesday: '24/7',
          wednesday: '24/7',
          thursday: '24/7',
          friday: '24/7',
          saturday: '24/7',
          sunday: '24/7'
        }
      },
      {
        id: 'facility-2',
        name: 'Community Medical Center',
        address: '456 Health Blvd, City, State',
        phone: '+1-555-0127',
        type: 'Clinic',
        services: ['Primary Care', 'Pediatrics', 'Dental'],
        rating: 4.3,
        operatingHours: {
          monday: '8:00-18:00',
          tuesday: '8:00-18:00',
          wednesday: '8:00-18:00',
          thursday: '8:00-18:00',
          friday: '8:00-18:00',
          saturday: '9:00-14:00',
          sunday: 'Closed'
        }
      }
    ];

    // Create test appointments
    const appointments = [
      {
        id: 'appointment-1',
        patientId: 'test-patient-1',
        providerId: 'test-provider-1',
        facilityId: 'facility-1',
        date: randomDate(new Date(), new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)),
        status: 'scheduled',
        type: 'Regular Checkup',
        notes: 'Annual cardiovascular examination',
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      }
    ];

    // Add users to Firestore
    for (const user of users) {
      await db.collection('users').doc(user.id).set(user);
      console.log(`Added user: ${user.name}`);
    }

    // Add facilities to Firestore
    for (const facility of facilities) {
      await db.collection('facilities').doc(facility.id).set(facility);
      console.log(`Added facility: ${facility.name}`);
    }

    // Add appointments to Firestore
    for (const appointment of appointments) {
      await db.collection('appointments').doc(appointment.id).set(appointment);
      console.log(`Added appointment for patient ${appointment.patientId} with provider ${appointment.providerId}`);
    }

    console.log('Data seeding completed successfully!');
  } catch (error) {
    console.error('Error seeding data:', error);
  } finally {
    // Close the connection
    admin.app().delete();
  }
}

// Run the seeding function
seedData(); 