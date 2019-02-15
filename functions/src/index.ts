import { firestore } from 'firebase-admin';

const admin = require('firebase-admin');
const functions = require('firebase-functions');


admin.initializeApp();

exports.userCreationHandler = functions.auth.user().onCreate((user: any) => {
	const email = user.email;
	const uid = user.uid;

	firestore().collection('users').doc(uid).set({
		email: email
	}).then().catch();
});

exports.userDeletionHandler = functions.auth.user().onDelete((user: any) => {
	firestore().collection('users').doc(user.uid).delete().then().catch();
});
