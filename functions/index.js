const express = require('express');
const serviceKey = require('./serviceKey.json');
const functions = require('firebase-functions');
const cors = require('cors');
const {Client, ReverseGeocodingLocationType, DirectionsResponseStatus} = require("@googlemaps/google-maps-services-js");
const app = express();
app.use(cors());
const port = 3000;

const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
const client = new Client();

initializeApp({
    credential: cert(serviceKey)
});

const db = getFirestore();

exports.addRiderToRide = async (req, res) => {
    var query = await db.collection('rides').get();
    var ride;
    var rideCoords;
    for(doc in query.docs) {
        if (query.docs[doc].data()['driver'] == req.query['driver']) {
            ride = query.docs[doc];
        }
    }
    var query = await db.collection(`rides/${ride['id']}/coords`).get();
    rideCoords = query.docs;
    var response = await client.directions({
        params: {
            origin: '12 alexander place, arrowtown',
            destination: '47 ferry hill drive, quail rise',
            waypoints: ['arrowtown'],
            mode: 'driving',
            transitOptions: {
                'departureTime': new Date().now
            },
            drivingOptions: {
                'departureTime': new Date().now
            },
            key: 'AIzaSyBDPS7SYYqG6VlmkDe8hXmgmr4Jc0qm4bo'
        },
    })
};

exports.addRiderToRide = functions.https.onRequest(this.addRiderToRide);