import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import axios from 'axios';

export const updateCryptocurrencies = functions.region('europe-west1').pubsub.schedule('every 24 hours').timeZone('Europe/Prague').onRun(async (context) => {
  const intermediateCryptoListDocumentRef = admin.firestore().collection('system').doc('crypto_intermediate');
  const cryptoListDocumentRef = admin.firestore().collection('system').doc('crypto');

  await admin.firestore().runTransaction(async (transaction) => {
    const intermediateCryptoListDocument = await transaction.get(intermediateCryptoListDocumentRef);
    const cryptoListDocument = await transaction.get(cryptoListDocumentRef);

    const intermediateCryptoList = intermediateCryptoListDocument.exists ? intermediateCryptoListDocument.data()!.currencies as string[] : [];
    const cryptoList = cryptoListDocument.exists ? cryptoListDocument.data()!.currencies as string[] : [];

    //* 1. Get top 1000 cryptos from coingecko

    // How many pages each cointaining 250 crypto records should we crawl
    const pages = 4;

    let coinGeckoCryptoList: string[] = [];

    for (let i = 0; i < pages; i++) {
      const page = (await axios.get(`https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&per_page=250&page=${i + 1}`)).data;

      coinGeckoCryptoList = [...coinGeckoCryptoList, ...page.map((data: any) => data.id)];
    }

    //* 2. Compare intermediate list with main list and add new cryptos to the main list

    // Take everything from intermediate list that is not in crypto list and is still present on coingecko
    const newCrypto = intermediateCryptoList.filter(crypto => !cryptoList.includes(crypto)).filter((crypto) => coinGeckoCryptoList.includes(crypto));

    // Append new crypto to crypto list
    const newCryptoList = [
      ...cryptoList,
      ...newCrypto,
    ];

    // Save new list to the database
    transaction.set(cryptoListDocumentRef, {
      currencies: newCryptoList,
    });

    //* 3. Save coin gecko records as the new intermediate list

    transaction.set(intermediateCryptoListDocumentRef, {
      currencies: coinGeckoCryptoList,
    });
  });
});

