import 'package:location/location.dart';

import 'driver.dart';

class Ride {
  Driver driver;
  double distance;
  Set stops = <LocationData>{};

  Ride(this.driver, this.distance);
}
