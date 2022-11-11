import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
  LocationData? currentLocation;

  void getCurrentLocation() async {
    GoogleMapController googleMapController = await _controller.future;
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    location.onLocationChanged.listen((newLoc) {
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            zoom: 15.5,
        target: LatLng(newLoc.latitude!,
         newLoc.longitude!),
      )));
      currentLocation = newLoc;
      setState(() {});
    });
  }

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
    getCurrentLocation();
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
      body: currentLocation == null
          ? const Center(child: Text("Finding your position.."))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 15.5),
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylinecoords,
                ),
              },
              markers: {
                Marker(
                    markerId: const MarkerId("current"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!)),
                const Marker(
                  markerId: MarkerId("destination"),
                  position: sourceLocation,
                )
              },
              onMapCreated: (mapcontroller) {
                _controller.complete(mapcontroller);
              },
            ),
    );
  }
}
