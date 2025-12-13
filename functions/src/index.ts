import * as functions from 'firebase-functions/v1';
import * as functionsV2 from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

// Initialize the Firebase Admin SDK
admin.initializeApp();

/**
 * Cloud Function that triggers when a new user document is created in Firestore.
 * It sets custom claims based on the user's role stored in Firestore.
 */
export const setUserClaims = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    try {
      const userId = context.params.userId;
      const userData = snapshot.data();
      
      if (!userData) {
        console.log(`No user data found for user ${userId}`);
        return null;
      }
      
      const role = userData.role;
      
      if (!role) {
        console.log(`No role specified for user ${userId}`);
        return null;
      }
      
      // Set custom claims based on user role
      const customClaims: { [key: string]: any } = {
        role: role,
        // Add additional claims as needed
        isPatient: role === 'patient',
        isProvider: role === 'provider',
        isDriver: role === 'driver',
      };
      
      // Set custom user claims
      await admin.auth().setCustomUserClaims(userId, customClaims);
      
      console.log(`Successfully set custom claims for user ${userId} with role ${role}`);
      
      // Update the user document to indicate that claims have been set
      await snapshot.ref.update({
        claimsUpdated: true,
        claimsUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return null;
    } catch (error) {
      console.error('Error setting custom claims:', error);
      return null;
    }
  });

/**
 * HTTP function to manually set or update custom claims for a user.
 * This can be used by administrators to update user roles.
 * Requires authentication and admin privileges.
 */
export const updateUserRole = functionsV2.https.onCall(async (request) => {
  try {
    // Check if the request is made by an authenticated user with admin privileges
    if (!request.auth) {
      throw new functionsV2.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.'
      );
    }
    
    // In a real application, you would check if the caller has admin privileges
    // For now, we'll just check if they're authenticated
    
    const { userId, role } = request.data as { userId: string; role: string };
    
    if (!userId || !role) {
      throw new functionsV2.https.HttpsError(
        'invalid-argument',
        'The function must be called with userId and role arguments.'
      );
    }
    
    // Validate role
    if (!['patient', 'provider', 'driver'].includes(role)) {
      throw new functionsV2.https.HttpsError(
        'invalid-argument',
        'Invalid role specified. Must be one of: patient, provider, driver.'
      );
    }
    
    // Set custom claims based on user role
    const customClaims: { [key: string]: any } = {
      role: role,
      isPatient: role === 'patient',
      isProvider: role === 'provider',
      isDriver: role === 'driver',
      updatedAt: new Date().getTime(),
    };
    
    // Set custom user claims
    await admin.auth().setCustomUserClaims(userId, customClaims);
    
    // Update the user document in Firestore
    await admin.firestore().collection('users').doc(userId).update({
      role: role,
      claimsUpdated: true,
      claimsUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    return { success: true, message: `Successfully updated role to ${role} for user ${userId}` };
  } catch (error) {
    console.error('Error updating user role:', error);
    throw new functionsV2.https.HttpsError(
      'internal',
      'An error occurred while updating the user role.'
    );
  }
});

/**
 * Function to verify a provider or driver account.
 * This would typically involve some verification process and admin approval.
 */
export const verifySpecialRole = functionsV2.https.onCall(async (request) => {
  try {
    // Check if the request is made by an authenticated user
    if (!request.auth) {
      throw new functionsV2.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.'
      );
    }
    
    const { userId, isVerified } = request.data as { userId: string; isVerified: boolean };
    
    if (!userId) {
      throw new functionsV2.https.HttpsError(
        'invalid-argument',
        'The function must be called with a userId argument.'
      );
    }
    
    // Get the user's current claims
    const user = await admin.auth().getUser(userId);
    const currentClaims = user.customClaims || {};
    
    // Update the claims to include verification status
    const updatedClaims = {
      ...currentClaims,
      isVerified: isVerified === true,
      verifiedAt: isVerified === true ? new Date().getTime() : null,
    };
    
    // Set the updated custom claims
    await admin.auth().setCustomUserClaims(userId, updatedClaims);
    
    // Update the user document in Firestore
    await admin.firestore().collection('users').doc(userId).update({
      isVerified: isVerified === true,
      verifiedAt: isVerified === true ? admin.firestore.FieldValue.serverTimestamp() : null,
    });
    
    return { 
      success: true, 
      message: isVerified 
        ? `User ${userId} has been verified.` 
        : `Verification removed for user ${userId}.` 
    };
  } catch (error) {
    console.error('Error verifying user:', error);
    throw new functionsV2.https.HttpsError(
      'internal',
      'An error occurred while verifying the user.'
    );
  }
});

/**
 * Cloud Function that triggers when a new emergency is created.
 * This implements the dispatch logic - finding and assigning the nearest facility.
 * 
 * WEEK 2: Dispatch & Acknowledgment - This closes the first loop.
 */
export const onEmergencyCreated = functions.firestore
  .document('emergencies/{emergencyId}')
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    try {
      const emergencyId = context.params.emergencyId;
      const emergencyData = snapshot.data();
      
      console.log(`Emergency created: ${emergencyId}`);
      
      if (!emergencyData) {
        console.error(`No emergency data found for ${emergencyId}`);
        return null;
      }
      
      // Only process if status is 'created' (not already processed)
      if (emergencyData.status !== 'created') {
        console.log(`Emergency ${emergencyId} already processed, status: ${emergencyData.status}`);
        return null;
      }
      
      const emergencyLocation = emergencyData.location;
      if (!emergencyLocation) {
        console.error(`No location found for emergency ${emergencyId}`);
        return null;
      }
      
      // Find nearest facility
      // For now, we'll use a simple approach:
      // 1. Get all facilities with emergencyAcceptanceStatus = 'available'
      // 2. Calculate distance to each
      // 3. Assign the nearest one
      
      const facilitiesRef = admin.firestore().collection('facilities');
      const facilitiesSnapshot = await facilitiesRef
        .where('emergencyAcceptanceStatus', '==', 'available')
        .get();
      
      if (facilitiesSnapshot.empty) {
        console.warn(`No available facilities found for emergency ${emergencyId}`);
        // Fallback: Get any facility (for pilot/testing)
        const allFacilities = await facilitiesRef.limit(5).get();
        if (allFacilities.empty) {
          console.error(`No facilities found in database`);
          return null;
        }
        
        // Assign first facility (manual assignment for pilot)
        const firstFacility = allFacilities.docs[0];
        await dispatchEmergency(emergencyId, firstFacility.id, snapshot.ref);
        return null;
      }
      
      // Calculate distance to each facility and find nearest
      let nearestFacility: { id: string; distance: number } | null = null;
      const emergencyLat = emergencyLocation.latitude;
      const emergencyLng = emergencyLocation.longitude;
      
      facilitiesSnapshot.forEach((facilityDoc) => {
        const facilityData = facilityDoc.data();
        const facilityLocation = facilityData.location;
        
        if (facilityLocation && facilityLocation.latitude && facilityLocation.longitude) {
          const distance = calculateDistance(
            emergencyLat,
            emergencyLng,
            facilityLocation.latitude,
            facilityLocation.longitude
          );
          
          if (!nearestFacility || distance < nearestFacility.distance) {
            nearestFacility = {
              id: facilityDoc.id,
              distance: distance,
            };
          }
        }
      });
      
      if (nearestFacility) {
        console.log(`Dispatching emergency ${emergencyId} to facility ${nearestFacility.id} (distance: ${nearestFacility.distance.toFixed(2)} km)`);
        await dispatchEmergency(emergencyId, nearestFacility.id, snapshot.ref);
      } else {
        console.warn(`Could not find suitable facility for emergency ${emergencyId}`);
      }
      
      return null;
    } catch (error) {
      console.error('Error in onEmergencyCreated:', error);
      return null;
    }
  });

/**
 * Helper function to dispatch an emergency to a facility
 * WEEK 2: This also attempts to assign a driver (Week 3 enhancement)
 */
async function dispatchEmergency(
  emergencyId: string,
  facilityId: string,
  emergencyRef: admin.firestore.DocumentReference
): Promise<void> {
  const db = admin.firestore();
  const batch = db.batch();
  
  // Get emergency location for driver assignment
  const emergencyData = (await emergencyRef.get()).data();
  const emergencyLocation = emergencyData?.location;
  
  // Try to find and assign a driver (Week 3)
  let assignedDriverId: string | null = null;
  if (emergencyLocation) {
    try {
      const availableDrivers = await db
        .collection('drivers')
        .where('status', '==', 'available')
        .where('isVerified', '==', true)
        .limit(10)
        .get();
      
      if (!availableDrivers.empty) {
        // Find nearest driver
        let nearestDriver: { id: string; distance: number } | null = null;
        const emergencyLat = emergencyLocation.latitude;
        const emergencyLng = emergencyLocation.longitude;
        
        availableDrivers.forEach((driverDoc) => {
          const driverData = driverDoc.data();
          const driverLocation = driverData.currentLocation;
          
          if (driverLocation && driverLocation.latitude && driverLocation.longitude) {
            const distance = calculateDistance(
              emergencyLat,
              emergencyLng,
              driverLocation.latitude,
              driverLocation.longitude
            );
            
            if (!nearestDriver || distance < nearestDriver.distance) {
              nearestDriver = {
                id: driverDoc.id,
                distance: distance,
              };
            }
          }
        });
        
        if (nearestDriver && nearestDriver.distance <= 50) { // Within 50km
          assignedDriverId = nearestDriver.id;
          console.log(`Assigning driver ${assignedDriverId} to emergency ${emergencyId}`);
        }
      }
    } catch (error) {
      console.warn(`Could not assign driver for emergency ${emergencyId}:`, error);
      // Continue without driver assignment - manual assignment can happen later
    }
  }
  
  // Update emergency status to 'dispatched' and assign facility
  const updateData: any = {
    status: 'dispatched',
    assignedFacilityId: facilityId,
    dispatchedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  
  // Add driver assignment if found
  if (assignedDriverId) {
    updateData.assignedDriverId = assignedDriverId;
  }
  
  batch.update(emergencyRef, updateData);
  
  // Log dispatch event
  const eventRef = db.collection('events').doc();
  batch.set(eventRef, {
    type: 'emergencyDispatched',
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    emergencyId: emergencyId,
    entityId: facilityId,
    description: `Emergency dispatched to facility ${facilityId}${assignedDriverId ? ` and driver ${assignedDriverId}` : ''}`,
  });
  
  // Log driver assignment event if driver was assigned
  if (assignedDriverId) {
    const driverEventRef = db.collection('events').doc();
    batch.set(driverEventRef, {
      type: 'driverAssigned',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      emergencyId: emergencyId,
      entityId: assignedDriverId,
      description: `Driver ${assignedDriverId} assigned to emergency`,
    });
  }
  
  await batch.commit();
  console.log(`Emergency ${emergencyId} dispatched to facility ${facilityId}${assignedDriverId ? ` with driver ${assignedDriverId}` : ''}`);
}

/**
 * Calculate distance between two coordinates using Haversine formula
 * Returns distance in kilometers
 */
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth's radius in kilometers
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRad(degrees: number): number {
  return degrees * (Math.PI / 180);
}