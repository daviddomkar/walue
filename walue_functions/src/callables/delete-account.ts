import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const deleteAccount = functions.region('europe-west1').https.onCall(async (_, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  await admin.auth().deleteUser(context.auth.uid);
});
