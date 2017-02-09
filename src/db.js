var config = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.FIREBASE_DATABASE_URL,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID
};

var firebaseApp = firebase.initializeApp(config);

var database = firebaseApp.database();

database.ref('/test').once('value').then(function(snapshot) {
  console.log(snapshot.val());
}).catch(console.log.bind(console));
