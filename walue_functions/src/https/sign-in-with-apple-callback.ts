import * as functions from 'firebase-functions';

export const signInWithAppleCallback = functions.region('europe-west1').https.onRequest((req, res) => {
  const redirect = `intent://callback?${new URLSearchParams(
    req.body
  ).toString()}#Intent;package=eu.kormic.walue;scheme=signinwithapple;end`;

  res.redirect(307, redirect);
});
