# Hopper
 
## Intro
Hopper is a transport alternitive that is to be implemented into the Queenstown Lakes community to help reduce high congestion at peak traffic hours as well as reducing the emitions of carbon dioxide emitted by transport.

## Sources
Source for Google Maps tut [Google maps tutorial](https://medium.com/flutter-community/implement-real-time-location-updates-on-google-maps-in-flutter-235c8a09173e)

Source for Google Maps polyline and directions tut [Google Maps Polyline and Directions tutorial](https://medium.com/flutter-community/drawing-route-lines-on-google-maps-between-two-locations-in-flutter-4d351733ccbe)

======
Driver
======
//Intance variables

docref = var
uid = String
double = rating
reviews = Set<Review>
vehicle = String
litersPer100km = double
------
//Instance functions

updateDriver()
deleteDriver()
addReview(Review)
------
//Class functions

downloadDriverByUID(String
uploadDriver(String, String, double)

======
Review
======
//Intance variables

uid = String
rating = double
body = String
driver = Driver

======
Ride
======
//Intance variables

docref = late var
driver = Driver
distance = late double
origin = LatLng
destination = LatLng
coords = List<LatLng>
stops = Set<LocationData>
------
//Instance functions

------
//Class functions

downloadRideByUID(String);
uploadRide(Driver, LatLng, LatLng)