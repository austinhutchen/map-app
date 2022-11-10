import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(40.00411, -105.25402);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);
  static const key = "AIzaSyCUnH06kwV5fUVeAi1I_iA00_bL-ZqKwTg";
  List<LatLng> polylinecoords = [];

  void getPoints() async {
    PolylinePoints polypoints = PolylinePoints();
    PolylineResult result = await polypoints.getRouteBetweenCoordinates(
      key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylinecoords.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    getPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Maps",
          style: TextStyle(color: Colors.blue, fontSize: 20),
        ),
      ),
      body: GoogleMap(
          initialCameraPosition: const CameraPosition(target: sourceLocation, zoom: 12.5),
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylinecoords,
            ),
          },
          markers: {
            const Marker(
              markerId: MarkerId("source"),
              position: sourceLocation,
            ),
            const Marker(
              markerId: MarkerId("destination"),
              position: destination,
            )
          }),
    );
  }
}
