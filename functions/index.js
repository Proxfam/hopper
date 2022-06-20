const express = require('express');
const serviceKey = require('./serviceKey.json');
const functions = require('firebase-functions');
const polyline = require('google-polyline');
const cors = require('cors');
const {Client, ReverseGeocodingLocationType, DirectionsResponseStatus, PlaceInputType} = require("@googlemaps/google-maps-services-js");
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

const GOOGLE_API_KEY = 'AIzaSyArRqDMu_RbWCN6PxHpfrZzGvN9D2wABfs';

exports.addRiderToRide = async (req, res) => {
    function _calculateDistance(lat1, lon1, lat2, lon2) {
        var p = 0.017453292519943295;
        var a = 0.5 -
            Math.cos((lat2 - lat1) * p) / 2 +
            Math.cos(lat1 * p) * Math.cos(lat2 * p) * (1 - Math.cos((lon2 - lon1) * p)) / 2;
        return 12742 * Math.asin(Math.sqrt(a));
    }

    var query = await db.collection('rides').get();
    var ride;
    var rideCoords;
    for(doc in query.docs) {
        if (query.docs[doc].data()['driver'] == req.query['driver']) {
            ride = query.docs[doc];
        }
    }

    console.log(ride);

    var query = await db.collection(`rides/${ride.id}/coords`).get();
    rideCoords = query.docs;

    var origin = await client.textSearch({params: {
        query: req.query['origin'],
        key: GOOGLE_API_KEY
    }})

    var destination = await client.textSearch({params: {
        query: req.query['destination'],
        key: GOOGLE_API_KEY
    }})

    var pickUp = {distance: 99999, coord: undefined};
    var dropoff = {distance: 99999, coord: undefined};

    for(coord in rideCoords) {
        let result = _calculateDistance(
            rideCoords[coord].data()['lat'],
            rideCoords[coord].data()['lng'],
            origin.data.results[0].geometry.location.lat,
            origin.data.results[0].geometry.location.lng
        );
        if (result < pickUp.distance) {
            pickUp.distance = result;
            pickUp.coord = rideCoords[coord].data();
        }
    }

    for(coord in rideCoords) {
        let result = _calculateDistance(
            rideCoords[coord].data()['lat'],
            rideCoords[coord].data()['lng'],
            destination.data.results[0].geometry.location.lat,
            destination.data.results[0].geometry.location.lng
        );
        if (result < dropoff.distance) {
            dropoff.distance = result;
            dropoff.coord = rideCoords[coord].data();
        }
    }

    console.log([pickUp,dropoff]);

    //change this to work with closest point accessable by road using road matrix or smth
    //It works but it doesn't take roads into account

    res.send('done');
};

exports.addRide = async (req,res) => {
    db.collection("rides")
      .add({
        'driver': '3n6ChQAe7qe25nl5Ju0zFiv6UWg1',
        'distance': 'null',
        'origin': [
            -44.94889431082194, 
            168.8449603099974
        ],
        'destination': [
            -45.029701185507435, 
            168.65722472525596
        ],
        'stops': []
      })
      .then(docRef => {
        client.directions({
            params: {
                origin: {'lat':-44.94889431082194, 'lng':168.8449603099974},
                destination: {'lat': -45.029701185507435, 'lng': 168.65722472525596},
                waypoints: ['lower shotover road'],
                key: GOOGLE_API_KEY
            }
        }).then(pointResult => {
            let points = polyline.decode(pointResult.data.routes[0].overview_polyline.points);
            for(point in points) {
                db.collection(`rides/${docRef.id}/coords`).add({
                    'lat': points[point][0],
                    'lng': points[point][1]
                })
            }
        });
        // await FirebaseFirestore.instance
        //   .collection('rides/${value.id}/coords')
        //   .add({'lat': element.latitude, 'lng': element.longitude});
    });
    res.send();
};

exports.addRide = functions.https.onRequest(this.addRide);
exports.addRiderToRide = functions.https.onRequest(this.addRiderToRide);