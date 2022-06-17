const express = require('express');
const serviceKey = require('./serviceKey.json');
const {Client, ReverseGeocodingLocationType, DirectionsResponseStatus} = require("@googlemaps/google-maps-services-js");
const app = express();
const port = 3000;

const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
const client = new Client();

initializeApp({
    credential: cert(serviceKey) 
});

const db = getFirestore();

app.get('/',async (req,res) => {
    res.send('lmao');
    var query = await db.collection('rides').get();
    var response = client.directions({
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
    }).then((value) => {
        console.log(value.data.routes[0]);
    })
})

app.listen(port, () => {
    console.log('Running');
})