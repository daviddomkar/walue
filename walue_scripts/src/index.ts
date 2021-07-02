import axios from 'axios';
import admin from 'firebase-admin';

admin.initializeApp({
  credential: admin.credential.cert(require('../../service-account.json')),
});

(async () => {
  const users = await admin.firestore().collection('users').listDocuments();

  for (const user of users) {
    const portfolioRecords = await admin.firestore().collection('users').doc(user.id).collection('portfolio').listDocuments();

    for (const portfolioRecord of portfolioRecords) {
      const buyRecords = await admin.firestore().collection('users').doc(user.id).collection('portfolio').doc(portfolioRecord.id).collection('buy_records').listDocuments();

      const newData = {} as any;

      for (const buyRecord of buyRecords) {
        const data = (await buyRecord.get()).data()!;

        newData[data['fiat_currency_symbol']] = (newData[data['fiat_currency_symbol']] ?? 0) + data.amount * data['buy_price'];
      }

      const currencySymbols = Object.keys(newData);

      for (const symbol of currencySymbols) {
        portfolioRecord.update({
          [`buy_records_data_by_fiat.${symbol}.total_amount_in_fiat_currency_when_bought`]: newData[symbol],
          [`buy_records_data_by_fiat.${symbol}.average_amount_in_fiat_currency_when_bought`]: admin.firestore.FieldValue.delete(),
        });
      }
    }
  }
})();


/*
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
*/
