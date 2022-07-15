const express = require('express');
const serviceKey = require('./serviceKey.json');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const polyline = require('google-polyline');
const stripe = require('stripe')('sk_test_51LFA2lJj1tNJdnFysU0lxqedsprNpDr7ZjzcqzX1gY4xsxbmIZ7lazpSOA1e0onHYQtSAJ45Uet85GgZGcrqSacQ00Ow58v7rI');
const cors = require('cors');
const {Client, ReverseGeocodingLocationType, DirectionsResponseStatus, PlaceInputType} = require("@googlemaps/google-maps-services-js");
const app = express();
app.use(cors());
const port = 3000;

const {PassbaseClient, PassbaseConfiguration} = require("@passbase/node");
const { initializeApp, applicationDefault, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
const { extractInstanceAndPath } = require('firebase-functions/v1/database');
const { json } = require('express');
const { binaryauthorization } = require('googleapis/build/src/apis/binaryauthorization');
const { DocumentBuilder } = require('firebase-functions/v1/firestore');

const passbase = new PassbaseClient(new PassbaseConfiguration({
    apiKey: "uhtIdDNbX3lyKxN7JX86LTlZPh85BtaHMKkZweSkfgO856SFAYfdUlEdGT6MwYCqYxU9XuRFf3qEER9aJhhwFSu9PJvVCngmYsWNnnAkPXvE5EsA8bRWSrZYuRm5wz4w"
}));
const maps = new Client();

initializeApp({
    credential: cert(serviceKey)
});

const db = admin.firestore();

const GOOGLE_API_KEY = 'AIzaSyArRqDMu_RbWCN6PxHpfrZzGvN9D2wABfs';

exports.stripePayment = async (req,res) => {
    try{
        let customerId;

        const customerList = await stripe.customers.list({
            email: req.body.email,
            limit: 1
        });

        if (customerList.data.length !== 0) {
            customerId = customerList.data[0].id;
        }
        else {
            const customer = await stripe.customers.create({
                email: req.body.email
            });
            customerId = customer.data.id;
        }

        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customerId },
            { apiVersion: '2020-08-27' }
        );

        const paymentIntent = await stripe.paymentIntents.create({
            amount: parseInt(req.body.amount),
            currency: 'nzd',
            customer: customerId,
            capture_method: 'manual',
            payment_method_types: ['card']
        })

        res.status(200).send({
            paymentIntent: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            success: true,
        })
    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
}

exports.webhooks = async (req,res) => {
    console.log(req.body);
    try{
        if (req.body['event'] == "VERIFICATION_REVIEWED" || req.body['event'] == "VERIFICATION_COMPLETED") {
            console.log('cp1');
            var query = await db.collection("users").where("identityAccessKey", "==", req.body['key']).get();
            if (query.empty) {
                console.log('cp7');
                res.sendStatus(200);
                return;
            }
            console.log('cp2');
    
            var status;
    
            switch(req.body['status']) {
                case "approved":
                    status = 1;
                    break;
                case "declined":
                    status = 0;
                    break;
                case "pending":
                    status = 2;
                    break;
            }
            console.log('cp3');
    
            await db.collection("users").doc(query.docs[0].ref.id).set({"identityVerified": status},{merge: true})
            console.log('cp4', status);
            res.sendStatus(200);
            return;
        }
        console.log('cp8');
    } catch(e) {
        console.log('cp5');
        console.log(e);
        res.sendStatus(200);
        return;
    }
    console.log('cp6');
    res.send();
    return;

}

exports.searchRides = async (req, res) => {
    var riderOrigin = await maps.textSearch({params: {
        query: req.body['origin'],
        key: GOOGLE_API_KEY
    }})
    var riderDestination = await maps.textSearch({params: {
        query: req.body['destination'],
        key: GOOGLE_API_KEY
    }})
    var originRadius = req.body['originRadius'];
    var destinationRadius = req.body['destinationRadius'];

    var rides = await db.collection('rides').get();

    function _calculateDistance(lat1, lon1, lat2, lon2) {
        var p = 0.017453292519943295;
        var a = 0.5 -
            Math.cos((lat2 - lat1) * p) / 2 +
            Math.cos(lat1 * p) * Math.cos(lat2 * p) * (1 - Math.cos((lon2 - lon1) * p)) / 2;
        return 12742 * Math.asin(Math.sqrt(a));
    }

    var validRides = [];

    for (currentRide in rides.docs) {
        var coords = await db.collection(`rides/${rides.docs[currentRide].id}/coords`).get();

        var pickup = {distance: 99999, coord: undefined};
        var dropoff = {distance: 99999, coord: undefined};

        for (currentCoord in coords.docs) {

            //console.log(JSON.stringify(coords.docs[currentCoord].data()['lat']));

            //console.log(JSON.stringify(riderOrigin.data));

            //calculate distance
            var distance = _calculateDistance(
                riderOrigin.data.results[0].geometry.location['lat'],
                riderOrigin.data.results[0].geometry.location['lng'],
                coords.docs[currentCoord].data()['lat'],
                coords.docs[currentCoord].data()['lng']);

            if (pickup.distance > distance && originRadius >= distance) {
                pickup.distance = distance;
                pickup.coord = coords.docs[currentCoord];
            }

            //console.log(riderDestination.data.results[0].geometry.location);

            var distance = _calculateDistance(
                riderDestination.data.results[0].geometry.location['lat'],
                riderDestination.data.results[0].geometry.location['lng'],
                coords.docs[currentCoord].data()['lat'],
                coords.docs[currentCoord].data()['lng']);

            if (dropoff.distance > distance && destinationRadius >= distance) {
                dropoff.distance = distance;
                dropoff.coord = coords.docs[currentCoord];
            }
        }

        if (pickup.distance != 99999 && dropoff.distance != 99999) {
            var sortedCoords = [];
            for (coord in coords.docs) {
                if (Number.parseInt(coords.docs[coord].id) <= Number.parseInt(dropoff.coord.id) && Number.parseInt(coords.docs[coord].id) >= Number.parseInt(pickup.coord.id)) {
                    console.log(coords.docs[coord].id);
                    sortedCoords.push(coords.docs[coord]);
                }
            }
            //var slicedCoords = mappedCoords.slice(mappedCoords.findIndex(element => element.lat == pickup.coord.lat && element.lng == pickup.coord.lng), mappedCoords.findIndex(element => element.lat == dropoff.coord.lat && element.lng == dropoff.coord.lng) + 1);
            
            var distanceReponse = await maps.distancematrix({params: {
                origins: [pickup.coord.data()],
                destinations: [dropoff.coord.data()],
                key: GOOGLE_API_KEY
            }});

            console.log(sortedCoords.length);

            validRides.push({
                riderDistance: distanceReponse.data.rows[0].elements[0].distance.value,
                ride: rides.docs[currentRide].data(),
                rideCoords: sortedCoords.sort(),
                driver: (await db.collection('drivers').doc(rides.docs[currentRide].data().driver).get()).data(),
                driverDetails: (await db.collection('users').doc(rides.docs[currentRide].data().driver).get()).data(),
                pickup: pickup,
                dropoff: dropoff
            });
        }
    }

    //console.log(validRides);

    res.json(validRides);
}

exports.addRiderToRide = async (req, res) => {
    //function to calculating distance between to coords
    function _calculateDistance(lat1, lon1, lat2, lon2) {
        var p = 0.017453292519943295;
        var a = 0.5 -
            Math.cos((lat2 - lat1) * p) / 2 +
            Math.cos(lat1 * p) * Math.cos(lat2 * p) * (1 - Math.cos((lon2 - lon1) * p)) / 2;
        return 12742 * Math.asin(Math.sqrt(a));
    }

    //declares shit
    var query = await db.collection('rides').get();
    var ride;
    var rideCoords;
    //finds the spesified driver
    for(doc in query.docs) {
        if (query.docs[doc].data()['driver'] == req.body['driver']) {
            ride = query.docs[doc];
        }
    }

    //get ride coords
    var query = await db.collection(`rides/${ride.id}/coords`).get();
    rideCoords = query.docs;

    //find coords for origin and destination
    var origin = await maps.textSearch({params: {
        query: req.body['origin'],
        key: GOOGLE_API_KEY
    }})
    var destination = await maps.textSearch({params: {
        query: req.body['destination'],
        key: GOOGLE_API_KEY
    }})

    //declares more shit
    var pickup = {distance: 99999, coord: undefined};
    var dropoff = {distance: 99999, coord: undefined};

    maxPickupDistance = 1;
    maxDropoffDistance = 20;

    //calculate distance
    for (coord in rideCoords) {
        var distance = _calculateDistance(rideCoords[coord].data().lat,rideCoords[coord].data().lng,origin.data.results[0].geometry.location.lat,origin.data.results[0].geometry.location.lng);
        if (pickup.distance > distance && maxPickupDistance >= distance) {
            pickup.distance = distance;
            pickup.coord = rideCoords[coord].data();
        }
        var distance = _calculateDistance(rideCoords[coord].data().lat,rideCoords[coord].data().lng,destination.data.results[0].geometry.location.lat,destination.data.results[0].geometry.location.lng);
        console.log(maxDropoffDistance, distance);
        if (dropoff.distance > distance && maxDropoffDistance >= distance) {
            dropoff.distance = distance;
            dropoff.coord = rideCoords[coord].data();
        }
    }

    //uploads new data to firestore
    try{
        await db.collection(`rides/${ride.id}/passengers`).doc(req.body['uid']).set({
            'origin': origin.data.results[0].geometry.location,
            'destination': destination.data.results[0].geometry.location,
            'pickup': pickup,
            'dropoff': dropoff
    })} catch (e) {
        console.log(e);
        res.status(200).send();
    }

    res.status(200).send();
};

exports.addRide = async (req,res) => {
    await db.collection("rides").doc('testerThing1').set({
        'driver': '3n6ChQAe7qe25nl5Ju0zFiv6UWg1',
        'distance': 'null',
        'origin': [
            -44.94890818301905, 168.84461612633123
        ],
        'destination': [
            -45.023243016958574, 168.73555828858196
        ],
        'stops': []
    })

    var coords = await maps.directions({
        params: {
            origin: {'lat':-44.94890818301905, 'lng':168.84461612633123},
            destination: {'lat': -45.023243016958574, 'lng': 168.73555828858196},
            key: GOOGLE_API_KEY
        }
    })

    let points = polyline.decode(coords.data.routes[0].overview_polyline.points);
    var doc = "1";
    for(point in points) {
        db.collection('rides/testerThing1/coords').doc(doc).set({
            'lat': points[point][0],
            'lng': points[point][1]
        })
        var docNum = parseInt(doc);
        doc = (docNum += 1).toString();
    }

    res.send();
};

//exports.testPassbase = functions.https.onRequest(this.testPassbase);
exports.stripePayment = functions.https.onRequest(this.stripePayment);
exports.webhooks = functions.https.onRequest(this.webhooks);
exports.addRide = functions.https.onRequest(this.addRide);
exports.addRiderToRide = functions.https.onRequest(this.addRiderToRide);
exports.searchRides = functions.https.onRequest(this.searchRides);