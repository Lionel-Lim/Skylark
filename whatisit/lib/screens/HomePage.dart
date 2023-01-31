import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whatisit/services/maps_getLocation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void getUserLocation() async {
    await GetLocation()
        .getCurrentUserLocation()
        .then((value) => userPosition = value);
    userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
    userHeading = userPosition.heading;
    setState(() {});
  }

  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    // distanceFilter: 0,
  );
  StreamSubscription<Position>? positionStream;

  void listenLocationChanges() {
    Position? incomingPosition;
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      incomingPosition = position;
      if (incomingPosition == null) {
        print("Null Passed!!!!!!!!!!!");
      } else {
        setState(() {
          setState(() {});
          userPosition = incomingPosition!;
          userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
          userHeading = userPosition.heading;
          print("Repeated!!!!!!!!!!!");
          updateHeadingLine();
          updateCameraPosition();
        });
      }
    });
  }

  void updateHeadingLine() {
    _lines.add(
      Polyline(
        polylineId: const PolylineId("Direction"),
        color: Colors.red,
        width: 5,
        points: [
          userLatLng,
          LatLng(userLatLng.latitude + 0.01 * cos(userHeading * pi / 180),
              userLatLng.longitude + 0.01 * sin(userHeading * pi / 180))
        ],
      ),
    );
  }

  void updateCameraPosition() async {
    CameraPosition cameraPosition = CameraPosition(
      target: userLatLng,
      zoom: 16,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  // Map Variables
  late Position userPosition;
  static LatLng initLatLng =
      const LatLng(51.53870580986422, -0.0164587280985591);
  static double initHeading = 0.00;
  LatLng userLatLng = LatLng(initLatLng.latitude, initLatLng.longitude);
  double userHeading = initHeading;

  // Set init map controller
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(51.53870580986422, -0.0164587280985591),
    zoom: 14.4746,
  );

// on below line we have created the list of markers
  final List<Marker> _markers = <Marker>[
    const Marker(
      markerId: MarkerId('1'),
      position: LatLng(20.42796133580664, 75.885749655962),
      infoWindow: InfoWindow(
        title: 'My Position',
      ),
    ),
  ];
  final List<Polyline> _lines = <Polyline>[];

  @override
  void initState() {
    super.initState();
    getUserLocation();
    listenLocationChanges();
    print("Passed Init State");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F9D58),
        // on below line we have given title of app
        title: const Text("What is it?"),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            SafeArea(
              // on below line creating google maps
              child: GoogleMap(
                // on below line setting camera position
                initialCameraPosition: _kGoogle,
                // on below line we are setting markers on the map
                markers: Set<Marker>.of(_markers),
                // on below line specifying map type.
                mapType: MapType.normal,
                // on below line setting user location enabled.
                myLocationEnabled: true,
                // on below line setting compass enabled.
                compassEnabled: true,
                myLocationButtonEnabled: false,
                // on below line specifying controller on map complete.
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                polylines: Set<Polyline>.of(_lines),
              ),
            ),
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lat :${userLatLng.latitude}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Lon :${userLatLng.longitude}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Heading :$userHeading",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Live Reading :${positionStream!.isPaused}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // on pressing floating action button the camera will take to user current location
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.location_on_sharp),
        label: const Text("My Location"),
        onPressed: () async {
          getUserLocation();
          _markers.add(
            Marker(
                markerId: const MarkerId("user"),
                position: userLatLng,
                icon: BitmapDescriptor.defaultMarker),
          );
          updateCameraPosition();
          // _lines.add(
          //   const Polyline(polylineId: PolylineId("userDirection"),
          //   )
          // )

          // CameraPosition cameraPosition = CameraPosition(
          //   target: userLatLng,
          //   zoom: 16,
          // );

          // final GoogleMapController controller = await _controller.future;
          // controller.animateCamera(
          //   CameraUpdate.newCameraPosition(cameraPosition),
          // );
          setState(() {});
        },
      ),
    );
  }
}
