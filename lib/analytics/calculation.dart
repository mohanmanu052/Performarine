class Calculation {
  int calculateDuration(int seconds) {
    double newValue = seconds / 1000;
    return newValue.toInt();
  }

  //Example calculateDistance(1.10) // distance in meters
  // 1.10/1852 = 0.000594 in (NM)
  //Link: https://www.google.com/search?q=meter+into+nautical+mile&oq=meter+into+nautical+mile&aqs=chrome..69i57j0i5i7i15i30j0i5i13i15i30j0i390l2.10685j0j9&sourceid=chrome&ie=UTF-8
  String calculateDistance(double distance) {
    return (distance / 1852).toStringAsFixed(2);
  }

  //Example (2.7) // speed in m/s
  // 2.7 * 1.944 = 5.2488 (KT)
  // Link: https://www.google.com/search?q=meter+into+nautical+mile&oq=meter+into+nautical+mile&aqs=chrome..69i57j0i5i7i15i30j0i5i13i15i30j0i390l2.10685j0j9&sourceid=chrome&ie=UTF-8
  String calculateCurrentSpeed(double speed) {
    return (speed * 1.944).toStringAsFixed(1); // Knots
  }

  //Example calculateAvgSpeed // distance in meters - 0.09, duration in seconds - 10 min= 600(s)
  // 0.09/600 = 0.00015 (m/s)
  // 0.00015 * 1.944 = 0.0002916 (KT)
  String calculateAvgSpeed(double tripDistance, int tripDuration) {
    double value = (((tripDistance) / (tripDuration / 1000)) * 1.944); //Knots
    if (value.isNaN) {
      return '0.0';
    } else if (value.isInfinite) {
      return '0.0';
    } else {
      return value.toStringAsFixed(1);
    }
  }
}
