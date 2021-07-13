import * as admin from 'firebase-admin';

admin.initializeApp();

export * from './auth';
export * from './callables';
export * from './https';
export * from './pubsub';
