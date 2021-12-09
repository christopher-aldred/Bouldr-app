const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.onRouteWrite = functions.firestore
    .document('venues/{venueID}/areas/{areaID}/sections/{sectionID}/routes/{routeID}')
    .onWrite((change, context) => {
        var count = 0;
        const venueID = context.params.venueID;
        const areaID = context.params.areaID;
        const sectionID = context.params.sectionID;
        const routeID = context.params.routeID;

        //Loop through area (route added too) sections and re-calc route count 
        const sectionsRef = db.collection('venues').doc(venueID).collection('areas').doc(areaID).collection('sections');

        sectionsRef.get().then((snapshot) => {
            console.log("Area " + areaID + ": " + snapshot.data.length + " sections");
        });

        /*
        db.doc('venues/' + venueID + '/areas/' + areaID + '/').set({

        });
        */
    });
