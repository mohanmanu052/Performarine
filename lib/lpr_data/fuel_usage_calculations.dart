class FuelUsageCalculations{
  String? lprMessage;

    static final FuelUsageCalculations _instance = FuelUsageCalculations._internal();

  factory FuelUsageCalculations() => _instance;

  FuelUsageCalculations._internal() {
  }

  FuelUsageCalculations get instance => _instance;

Map<String,dynamic> calculateUsage(String lprMessage){
  //var lprMessage = "\$NMEA\$,14FF0668,89,98,E6,0B,F0,0F,00,00,173126920";
  //var lprMessage = "\$NMEA\$,14FF0668,89,98,EE,0B,F0,11,00,00,1731269203";
  //var lprMessage = "\$NMEA\$,14FF0668,89,98,16,0B,F0,18,00,00,1731271346";
  var tokens = lprMessage?.split(",");
  if (tokens?[0] == "\$NMEA\$") {
    var pgn = extractPGN(int.parse(tokens![1], radix: 16));
    if (pgn == 0xFF06) {
      var fuelFlow = convertFuelFlow(
          tokens.sublist(2, 10).map((e) => int.parse(e, radix: 16)).toList());
  double avgValue=    calculateAvarge(fuelFlow);
   return {'fuel_usage':fuelFlow,
   'avg_val':avgValue
   };

    }
  }
return {'fuel_usage':0.0,
   'avg_val':0.0
   };


}
double expoentialMovingAvergae(double newValue, double oldValue, double alpha) {
  return alpha * newValue + (1 - alpha) * oldValue;
}

double calculateAvarge(double fuelData){
    var average = 0.0;
    average = expoentialMovingAvergae(fuelData, average, 1 / 3);
    return average;
  }


int extractPGN(int canId) {
  // PGN is extracted from bits 8 to 25 of the 29-bit CANID
  return (canId >> 8) & 0x3FFFF;
}

double convertFuelFlow(List<int> data) {
  // Fuel flow is in the 6th and 7th bytes of the data frame
  // Return value is in liters per hour
  return (data[6] << 8 | data[5]) / 10.0;
}

}


