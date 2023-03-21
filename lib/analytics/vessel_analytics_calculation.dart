/*
class VesselAnalyticsCalculation
{
  void getVesselAnalytics(String vesselId, bool tripIsRunning) async {
    if (!tripIsRunning) {
      setState(() {
        vesselAnalytics = true;
      });
    }
    List<String> analyticsData =
    await _databaseService.getVesselAnalytics(vesselId);

    setState(() {
      totalDistance = analyticsData[0];
      avgSpeed = analyticsData[1];
      tripsCount = analyticsData[2];
      totalDuration = analyticsData[3];
      vesselAnalytics = false;
    });

    /// 1. TotalDistanceSum

    /// 2. AvgSpeed

    /// 3. TripsCount
    ///
    print('totalDistance $totalDistance');
    print('avgSpeed $avgSpeed');
    print('COUNT $tripsCount');
  }
}*/
