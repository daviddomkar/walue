import axios from 'axios';
import admin from 'firebase-admin';

admin.initializeApp({
  credential: admin.credential.cert(require('../../service-account.json')),
});

(async () => {
  const pages = 4;

  let crypto: any[] = [];

  for (let i = 0; i < pages; i++) {
    const page = (await axios.get(`https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&per_page=250&page=${i + 1}`)).data;

    crypto = [...crypto, ...page.map((data: any) => data.id)];
  }

  await admin.firestore().collection('system').doc('crypto').set({
    currencies: crypto
  });
})();