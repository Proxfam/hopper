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
const { getFirestore, Timestamp, FieldValue, GeoPoint, DocumentSnapshot } = require('firebase-admin/firestore');
const { extractInstanceAndPath } = require('firebase-functions/v1/database');
const { json } = require('express');
const { binaryauthorization } = require('googleapis/build/src/apis/binaryauthorization');
const { DocumentBuilder } = require('firebase-functions/v1/firestore');
const { _onRequestWithOptions } = require('firebase-functions/v1/https');

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
        region: 'nz',
        query: req.body['origin'],
        key: GOOGLE_API_KEY
    }})

    var riderDestination = await maps.textSearch({params: {
        region: 'nz',
        query: req.body['destination'],
        key: GOOGLE_API_KEY
    }})

    var originRadius = req.body['originRadius'];
    var destinationRadius = req.body['destinationRadius'];
    var riderDepartureTime = new Date(req.body['departureTime']);
    var riderArrivalTime = new Date(req.body['arrivalTime']);

    if (req.body['departureTime'] != undefined && req.body['arrivalTime'] != undefined) {
        res.json({
            error: "Departure and arrival times cannot be specified at the same time"
        })
    }

    if (req.body['departureTime'] == undefined && req.body['arrivalTime'] == undefined) {
        res.json({
            error: "No departure or arrival time specified"
        })
    }

    var rides = await db.collection('rides').get();

    function _calculateDistance(lat1, lon1, lat2, lon2) {
        var p = 0.017453292519943295;
        var a = 0.5 -
            Math.cos((lat2 - lat1) * p) / 2 +
            Math.cos(lat1 * p) * Math.cos(lat2 * p) * (1 - Math.cos((lon2 - lon1) * p)) / 2;
        return 12742 * Math.asin(Math.sqrt(a));
    }

    var validRides = [];

    for (i in rides.docs) {

        //console.log(rides.docs[i].data()['coords'][5]['latitude']);

        //check on same day

        // console.log(new Date(rides.docs[i].data()['departureTime']).getDate() != riderDepartureTime.getDate() && req.body['departureTime'] != undefined && rides.docs[i].data()['departureTime'] != null);
        // console.log(new Date(rides.docs[i].data()['departureTime']).getDate() != riderArrivalTime.getDate() && req.body['arrivalTime'] != undefined && rides.docs[i].data()['departureTime'] != null);
        // console.log(new Date(rides.docs[i].data()['arrivalTime']).getDate() != riderDepartureTime.getDate() && req.body['departureTime'] != undefined && rides.docs[i].data()['arrivalTime'] != null);
        // console.log(new Date(rides.docs[i].data()['arrivalTime']).getDate() != riderArrivalTime.getDate() && req.body['arrivalTime'] != undefined && rides.docs[i].data()['arrivalTime'] != null);

        if ((new Date(rides.docs[i].data()['departureTime']).getDate() != riderDepartureTime.getDate() && req.body['departureTime'] != undefined && rides.docs[i].data()['departureTime'] != null) || (new Date(rides.docs[i].data()['departureTime']).getDate() != riderArrivalTime.getDate() && req.body['arrivalTime'] != undefined && rides.docs[i].data()['departureTime'] != null) || (new Date(rides.docs[i].data()['arrivalTime']).getDate() != riderDepartureTime.getDate() && req.body['departureTime'] != undefined && rides.docs[i].data()['arrivalTime'] != null) || (new Date(rides.docs[i].data()['arrivalTime']).getDate() != riderArrivalTime.getDate() && req.body['arrivalTime'] != undefined && rides.docs[i].data()['arrivalTime'] != null)) {
            console.log("left here");
            continue;
        }

        var pickup = {distance: 99999, coord: undefined, address: undefined};
        var dropoff = {distance: 99999, coord: undefined, address: undefined};

        for (x in rides.docs[i].data()['coords']) {

            //calculate distance
            var distance = _calculateDistance(
                riderOrigin.data.results[0].geometry.location['lat'],
                riderOrigin.data.results[0].geometry.location['lng'],
                rides.docs[i].data()['coords'][x]['latitude'],
                rides.docs[i].data()['coords'][x]['longitude']);

            if (pickup.distance > distance && originRadius >= distance) {
                pickup.distance = distance;
                pickup.coord = new GeoPoint(rides.docs[i].data()['coords'][x]['_latitude'], rides.docs[i].data()['coords'][x]['_longitude']);
            }

            //console.log(riderDestination.data.results[0].geometry.location);

            var distance = _calculateDistance(
                riderDestination.data.results[0].geometry.location['lat'],
                riderDestination.data.results[0].geometry.location['lng'],
                rides.docs[i].data()['coords'][x]['latitude'],
                rides.docs[i].data()['coords'][x]['longitude']);

            if (dropoff.distance > distance && destinationRadius >= distance) {
                dropoff.distance = distance;
                dropoff.coord = new GeoPoint(rides.docs[i].data()['coords'][x]['_latitude'], rides.docs[i].data()['coords'][x]['_longitude']);
            }
        }

        // rides.docs[i].data()['coords'].forEach((coord) => {
        //     console.log(coord);
        // })

        if (pickup.distance != 99999 && dropoff.distance != 99999) {

            //console.log(riderOrigin.data.results[0].formatted_address);

            //Departure/Arrival Times - START

            if (req.body['departureTime'] != undefined) {

                var riderPickupRoute = await maps.directions({params: {
                    origin: riderOrigin.data.results[0].formatted_address,
                    destination: pickup.coord,
                    key: GOOGLE_API_KEY
                }})
    
                var driverPickupRoute = await maps.directions({params: {
                    origin: rides.docs[i].data()['coords'][0],
                    destination: pickup.coord,
                    key: GOOGLE_API_KEY
                }})

                var riderDropoffRoute = await maps.directions({params: {
                    origin: riderDestination.data.results[0].formatted_address,
                    destination: dropoff.coord,
                    key: GOOGLE_API_KEY
                }})

                var driverDropoffRoute = await maps.directions({params: {
                    origin: rides.docs[i].data()['coords'][0],
                    destination: dropoff.coord,
                    key: GOOGLE_API_KEY
                }})

                // if driverDepartureTimePlusDrivingTimeMinusRiderWalkingTime is greater than riderDepartureTime, then rider can make it
                // if riderDepartureTimePlusWalkingTime is less than driverDepartureTimePlusDrivingTime, then rider will make it
                // if riderDepartureTimePlusWalkingTimePlusHour is greater than driverDepartureTimePlusDrivingTime, then rider can make it

                var riderDepartureTimePlusWalkingTime = new Date(riderDepartureTime.getTime() + (riderPickupRoute.data.routes[0].legs[0].duration.value / 60 * 60000));
                var driverDepartureTimePlusDrivingTime = new Date(new Date(rides.docs[i].data()['departureTime']).getTime() + (driverPickupRoute.data.routes[0].legs[0].duration.value / 60 * 60000));
                var riderDepartureTimePlusWalkingTimePlusHour = new Date(riderDepartureTimePlusWalkingTime.getTime() + 60 * 60 * 1000);
                var driverDepartureTimePlusDrivingTimeMinusRiderWalkingTime = new Date(driverDepartureTimePlusDrivingTime.getTime() - (riderPickupRoute.data.routes[0].legs[0].duration.value / 60 * 60000));

                var dropoffArrival = new Date(new Date(rides.docs[i].data()['departureTime']).getTime() + (driverDropoffRoute.data.routes[0].legs[0].duration.value / 60 * 60000));
                var destinationArrival = new Date(dropoffArrival.getTime() + (riderDropoffRoute.data.routes[0].legs[0].duration.value / 60 * 60000));

                var leaveBy = new Date(driverDepartureTimePlusDrivingTime.getTime() - (riderPickupRoute.data.routes[0].legs[0].duration.value / 60 * 60000)).toISOString();
                var hopOn = driverDepartureTimePlusDrivingTime.toISOString();
                var hopOff = dropoffArrival.toISOString();
                var arriveBy = destinationArrival.toISOString();

                if (driverDepartureTimePlusDrivingTimeMinusRiderWalkingTime < riderDepartureTime || riderDepartureTimePlusWalkingTime > driverDepartureTimePlusDrivingTime || riderDepartureTimePlusWalkingTimePlusHour < driverDepartureTimePlusDrivingTime) {
                    console.log("you won't make it")
                    continue;
                }

           } else if (req.body['arrivalTime'] != undefined) {

                var riderPickupRoute = await maps.directions({params: {
                    origin: riderOrigin.data.results[0].formatted_address,
                    destination: pickup.coord,
                    key: GOOGLE_API_KEY
                }})

                var driverPickupRoute = await maps.directions({params: {
                    origin: rides.docs[i].data()['coords'][0],
                    destination: pickup.coord,
                    key: GOOGLE_API_KEY
                }})

                var riderDropoffRoute = await maps.directions({params: {
                    origin: riderDestination.data.results[0].formatted_address,
                    destination: dropoff.coord,
                    key: GOOGLE_API_KEY
                }})

                var driverDropoffRoute = await maps.directions({params: {
                    origin: rides.docs[i].data()['coords'][0],
                    destination: dropoff.coord,
                    key: GOOGLE_API_KEY
                }})

                var dropoffArrival = new Date(new Date(rides.docs[i].data()['departureTime']).getTime() + (driverDropoffRoute.data.routes[0].legs[0].duration.value / 60 * 60000));
                var destinationArrival = new Date(dropoffArrival.getTime() + (riderDropoffRoute.data.routes[0].legs[0].duration.value / 60 * 60000));
                var destinationArrivalMinusHour = new Date(destinationArrival.getTime() - 60 * 60 * 1000);

                if (destinationArrival > riderArrivalTime || destinationArrivalMinusHour > destinationArrival) {
                    console.log("you won't make it")
                    continue;
                }

                var driverDepartureTimePlusDrivingTime = new Date(new Date(rides.docs[i].data()['departureTime']).getTime() + (driverPickupRoute.data.routes[0].legs[0].duration.value / 60 * 60000));

                var leaveBy = new Date(driverDepartureTimePlusDrivingTime.getTime() - (riderPickupRoute.data.routes[0].legs[0].duration.value / 60 * 60000)).toISOString();
                var hopOn = driverDepartureTimePlusDrivingTime.toISOString();
                var hopOff = dropoffArrival.toISOString();
                var arriveBy = destinationArrival.toISOString();

           }

            //Departure/Arrival Times - END

            var sortedCoords = rides.docs[i].data()['coords'].slice(rides.docs[i].data()['coords'].findIndex(coord => coord.latitude == pickup.coord.latitude && coord.longitude == pickup.coord.longitude), rides.docs[i].data()['coords'].findIndex(coord => coord.latitude == dropoff.coord.latitude && coord.longitude == dropoff.coord.longitude));

            var cost = 0;
            var inCar = false;

            for (var y in rides.docs[i].data()['passengers']) {
                new GeoPoint(rides.docs[i].data()['passengers'][y]['locations']['pickup']['coord']["_latitude"],rides.docs[i].data()['passengers'][y]['locations']['pickup']['coord']['_longitude']);
            }

            var driver = await (await db.collection('users').doc(rides.docs[i].data()['driver']).get()).data();
            var passengers = 2;
            
            for (x in rides.docs[i].data()['coords']) {

                var geopointCoord = new GeoPoint(rides.docs[i].data()['coords'][x]['_latitude'], rides.docs[i].data()['coords'][x]['_longitude']);

                if ((geopointCoord.latitude == pickup.coord.latitude && geopointCoord.longitude == pickup.coord.longitude) || inCar) {
                    inCar = true;

                    for (var y in rides.docs[i].data()['passengers']) {

                        var passengerPickup = new GeoPoint(rides.docs[i].data()['passengers'][y]['locations']['pickup']['coord']["_latitude"],rides.docs[i].data()['passengers'][y]['locations']['pickup']['coord']['_longitude']);
                        var passengerDropoff = new GeoPoint(rides.docs[i].data()['passengers'][y]['locations']['dropoff']['coord']["_latitude"],rides.docs[i].data()['passengers'][y]['locations']['dropoff']['coord']['_longitude']);

                        //add passenger if they are in the same coord segment
                        if (passengerPickup.latitude == geopointCoord.latitude && passengerPickup.longitude == geopointCoord.longitude) {
                            passengers += 1;
                        } else if (passengerDropoff.latitude == geopointCoord.latitude && passengerDropoff.longitude == geopointCoord.longitude) {
                            passengers -= 1;
                        }
                    }

                    try{
                        cost += (_calculateDistance(rides.docs[i].data()['coords'][parseInt(x)]['latitude'], rides.docs[i].data()['coords'][parseInt(x)]['longitude'], rides.docs[i].data()['coords'][parseInt(x)+1]['latitude'], rides.docs[i].data()['coords'][parseInt(x)+1]['longitude']) * ((driver['driverInfo']['litresPer100km']/100) * 3.34)) / passengers;
                    } catch (e) {
                        console.log("End of cost calc");
                    }
                }
            }

            var serviceFee = Math.round((0.6 * cost) * 100) / 100

            var driverCost = Math.round(cost * 100) / 100;

            await maps.textSearch({params: {
                query: pickup.coord.latitude + "," + pickup.coord.longitude,
                key: GOOGLE_API_KEY
            }}).then(async function (result) {
                pickup.address = result.data.results[0].formatted_address.split(',')[0];
            });
    
            await maps.textSearch({params: {
                type: 'address',
                query: dropoff.coord.latitude + "," + dropoff.coord.longitude,
                key: GOOGLE_API_KEY,
            }}).then(async function (result) {
                dropoff.address = result.data.results[0].formatted_address.split(',')[0];
            });

            validRides.push({
                locations: {
                    origin: riderOrigin.data.results[0].name,
                    destination: riderDestination.data.results[0].name,
                    pickup: pickup,
                    dropoff: dropoff
                },
                times: {
                    leaveBy: leaveBy.toString(),
                    hopOn: hopOn.toString(),
                    hopOff: hopOff.toString(),
                    arriveBy: arriveBy.toString()
                },
                payment: {
                    serviceFee: serviceFee,
                    driverCost: driverCost
                },
                rideID: rides.docs[i].id,
                ride: rides.docs[i].data(),
                sortedCoords: sortedCoords,
                driver: (await db.collection('users').doc(rides.docs[i].data().driver).get()).data(),
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

exports.createRide = async (req,res) => {
    var docRef = await db.collection("rides").add({
        'driver': req.body['driver'],
        'origin': req.body['origin'],
        'destination': req.body['destination'],
        'departureTime': req.body['departureTime'] ?? null,
        'arrivalTime': req.body['arrivalTime'] ?? null,
    })

    var coords = await maps.directions({
        params: {
            origin: req.body['origin'],
            destination: req.body['destination'],
            key: GOOGLE_API_KEY
        }
    })

    console.log(coords.data)

    let points = polyline.decode(coords.data.routes[0].overview_polyline.points);
    await db.collection(`rides`).doc(docRef.id).update({
        'coords': points.map(point => new GeoPoint(point[0],point[1])),
    }).then(() => {console.log('done')})

    res.send();
};

exports.archiveRide = async (req,res) => {
    var rideData = await (await db.collection(`rides`).doc(req.body['rideID']).get()).data();
    //await db.collection(`rides`).doc(req.body['rideID']).delete();
    await db.collection(`archivedRides`).doc(req.body['rideID']).set(rideData);
    res.send('i got you');
}

//exports.testPassbase = functions.https.onRequest(this.testPassbase);
exports.stripePayment = functions.https.onRequest(this.stripePayment);
exports.webhooks = functions.https.onRequest(this.webhooks);
exports.createRide = functions.https.onRequest(this.createRide);
exports.addRiderToRide = functions.https.onRequest(this.addRiderToRide);
exports.searchRides = functions.https.onRequest(this.searchRides);
exports.archiveRide = functions.https.onRequest(this.archiveRide);