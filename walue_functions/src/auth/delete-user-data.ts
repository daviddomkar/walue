import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const deleteUserData = functions
  .region('europe-west1')
  .runWith({
    memory: '2GB',
    timeoutSeconds: 540,
  })
  .auth.user()
  .onDelete(async (user) => {
    const deleted = await admin.firestore().runTransaction(async (transaction) => {
      const userDoc = await transaction.get(admin.firestore().collection('users').doc(user.uid));

      if (userDoc.exists) {
        transaction.delete(userDoc.ref);
        return true;
      }

      return false;
    });

    if (deleted) {
      const portfolioCollectionSnapshot = await admin.firestore().collection('users').doc(user.uid).collection('portfolio').get();
      const buyRecordsCollectionsSnapshots= await Promise.all(portfolioCollectionSnapshot.docs.map((doc) => doc.ref.collection('buy_records').get()));

      const toDelete = portfolioCollectionSnapshot.docs.concat(buyRecordsCollectionsSnapshots.reduce((previous, current) => {
        return previous.concat(current.docs);
      }, [] as Array<FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>>)).map((doc) => doc.ref);

      const toDeletePartitioned = partition(toDelete, 500);

      await Promise.all(toDeletePartitioned.map((toDelete) => {
        return (async () => {
          const batch = admin.firestore().batch();
          toDelete.forEach((ref) => batch.delete(ref));
          await batch.commit();
        })();
      }));
    }
  });


const partition = <T>(array: Array<T>, n: number): Array<Array<T>> =>  {
  return array.length ? [array.splice(0, n)].concat(partition(array, n)) : [];
}
