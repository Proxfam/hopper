import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'driver.dart';

class Ride {
  Driver driver;
  double distance;
  List<LatLng> coords = [];
  Set stops = <LocationData>{};

  Ride(this.driver, this.distance, this.coords);
}
