import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const deleteUserData = functions
  .region('europe-west1')
  .auth.user()
  .onDelete(async (user) => {
    await admin.firestore().runTransaction(async (transaction) => {
      const playerDoc = await transaction.get(admin.firestore().collection('users').doc(user.uid));

      if (playerDoc.exists) {
        transaction.delete(playerDoc.ref);
      }
    });
  });
