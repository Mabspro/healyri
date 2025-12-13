"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifySpecialRole = exports.updateUserRole = exports.setUserClaims = void 0;
const functions = require("firebase-functions/v1");
const functionsV2 = require("firebase-functions/v2");
const admin = require("firebase-admin");
// Initialize the Firebase Admin SDK
admin.initializeApp();
/**
 * Cloud Function that triggers when a new user document is created in Firestore.
 * It sets custom claims based on the user's role stored in Firestore.
 */
exports.setUserClaims = functions.firestore
    .document('users/{userId}')
    .onCreate(async (snapshot, context) => {
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
        const customClaims = {
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
    }
    catch (error) {
        console.error('Error setting custom claims:', error);
        return null;
    }
});
/**
 * HTTP function to manually set or update custom claims for a user.
 * This can be used by administrators to update user roles.
 * Requires authentication and admin privileges.
 */
exports.updateUserRole = functionsV2.https.onCall(async (request) => {
    try {
        // Check if the request is made by an authenticated user with admin privileges
        if (!request.auth) {
            throw new functionsV2.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
        }
        // In a real application, you would check if the caller has admin privileges
        // For now, we'll just check if they're authenticated
        const { userId, role } = request.data;
        if (!userId || !role) {
            throw new functionsV2.https.HttpsError('invalid-argument', 'The function must be called with userId and role arguments.');
        }
        // Validate role
        if (!['patient', 'provider', 'driver'].includes(role)) {
            throw new functionsV2.https.HttpsError('invalid-argument', 'Invalid role specified. Must be one of: patient, provider, driver.');
        }
        // Set custom claims based on user role
        const customClaims = {
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
    }
    catch (error) {
        console.error('Error updating user role:', error);
        throw new functionsV2.https.HttpsError('internal', 'An error occurred while updating the user role.');
    }
});
/**
 * Function to verify a provider or driver account.
 * This would typically involve some verification process and admin approval.
 */
exports.verifySpecialRole = functionsV2.https.onCall(async (request) => {
    try {
        // Check if the request is made by an authenticated user
        if (!request.auth) {
            throw new functionsV2.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
        }
        const { userId, isVerified } = request.data;
        if (!userId) {
            throw new functionsV2.https.HttpsError('invalid-argument', 'The function must be called with a userId argument.');
        }
        // Get the user's current claims
        const user = await admin.auth().getUser(userId);
        const currentClaims = user.customClaims || {};
        // Update the claims to include verification status
        const updatedClaims = Object.assign(Object.assign({}, currentClaims), { isVerified: isVerified === true, verifiedAt: isVerified === true ? new Date().getTime() : null });
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
    }
    catch (error) {
        console.error('Error verifying user:', error);
        throw new functionsV2.https.HttpsError('internal', 'An error occurred while verifying the user.');
    }
});
//# sourceMappingURL=index.js.map