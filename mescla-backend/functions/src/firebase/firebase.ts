import { getApps, initializeApp } from 'firebase-admin/app';

if (!getApps().length) {
  initializeApp();
}