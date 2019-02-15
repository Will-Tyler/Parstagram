const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp();

exports.userPostHanlder = functions.firestore.document('users/{userID}/posts/{postID}').onCreate((snapshot: any, context: any) => {
	const uid: string = context.params.userID;
	const postID: string = context.params.postID;
	const path = admin.firestore().collection('users').doc(uid).collection('posts').doc(postID);

	return admin.firestore().collection('users').doc(uid).update({
		feed: admin.firestore.FieldValue.arrayUnion(path)
	}).then().catch();
});

exports.userCreationHandler = functions.auth.user().onCreate((user: any) => {
	admin.firestore().collection('users').doc(user.uid).set({
		email: user.email
	}, {
		merge: true
	}).then().catch();
});

exports.userDeletionHandler = functions.auth.user().onDelete((user: any) => {
	admin.firestore().collection('users').doc(user.uid).delete().then().catch();
});
