import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smooth_compass/utils/smooth_compass.dart';
import 'package:skylark/models/places_model.dart';
import 'package:skylark/screens/SearchResultGrid.dart';
import 'package:skylark/screens/SearchResultDisplay.dart';
import 'package:skylark/services/geometry.dart';
import 'package:skylark/services/maps_getLocation.dart';
import 'package:skylark/services/maps_places.dart';
import 'package:skylark/services/read_utility.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    // distanceFilter: 0,
  );
  StreamSubscription<Position>? positionStream;

  Widget _searchPlaces(result, photos, userLocation, onSearchFinished) {
    setState(() {});
    debugPrint("gridview updating...");
    return SearchResultDisplay(result, photos, userLocation, onSearchFinished);
  }

  void updateSearchFinished(bool value) {
    setState(() {
      isSearchFinished = value;
    });
  }

  Future<List<CachedNetworkImage>> _fetchImg(result) async {
    List<CachedNetworkImage> photos = [];
    for (var item in result) {
      if (item.photos.length > 0) {
        photos.add(
            await APIService().getPhoto(item.photos[0]["photo_reference"]));
      } else {
        photos.add(await APIService().getPhoto(""));
      }
    }
    return photos;
  }

  void _showModalButtonSheet(BuildContext context, List<PlacesModel> result,
      List<CachedNetworkImage> photos) {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.1,
        snap: true,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: SearchResultGrid(result, photos),
        ),
      ),
    );
  }

  void getUserLocation() async {
    await GetLocation()
        .getCurrentUserLocation()
        .then((value) => userPosition = value);
    userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
    userHeading = userPosition.heading;
  }

  void listenLocationChanges() {
    readDeviceInfo();

    Position? incomingPosition;
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      incomingPosition = position;
      if (incomingPosition == null) {
      } else {
        userPosition = incomingPosition!;
        userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
        if (isSimulator) userHeading = userPosition.heading;
        updateHeadingLine(
          latitude: userLatLng.latitude,
          longitude: userLatLng.longitude,
          heading: userHeading,
          radius: searchRadius,
        );
        updateCameraPosition(
          coordinates: userLatLng,
          radius: searchRadius,
        );
      }
    });
    setState(() {});
  }

  void updateHeadingLine({
    required double latitude,
    required double longitude,
    required double heading,
    required double radius,
  }) {
    // Reset geometry
    _lines.clear();
    polygon.clear();
    LatLng startPoint = userLatLng;
    LatLng endPoint = LatLng(
        latitude + radius * 0.00001 * cos(heading * pi / 180),
        longitude + radius * 0.00001 * sin(heading * pi / 180));
    polygon.addAll([
      startPoint,
      Geometry().rotatePoint(startPoint, endPoint, -60),
      endPoint,
      Geometry().rotatePoint(startPoint, endPoint, 60)
    ]);
    _lines.addAll([
      Polyline(
        polylineId: const PolylineId("Left"),
        color: Colors.orange,
        width: 5,
        points: [userLatLng, polygon[1]],
      ),
      Polyline(
        polylineId: const PolylineId("Direction"),
        color: Colors.red,
        width: 5,
        points: [startPoint, polygon[2]],
      ),
      Polyline(
        polylineId: const PolylineId("Right"),
        color: Colors.pink,
        width: 5,
        points: [userLatLng, polygon[3]],
      ),
    ]);
    setState(() {});
  }

  void updateCameraPosition({
    required LatLng coordinates,
    required double radius,
  }) async {
    CameraPosition cameraPosition = CameraPosition(
      target: coordinates,
      zoom: 24.4774 - (1.4089 * log(radius)),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  void readMapStyle() async {
    _mapStyle = await ReadUtility().loadAsset('assets/MapsStyle.json');
  }

  void updateSearchRadius({bool isIncresing = true}) {
    int dir = isIncresing ? 1 : -1;
    if (searchRadius <= 100 && dir == -1) {
      // Do nothing
    } else {
      searchRadius = searchRadius + dir * 100;
    }
    setState(() {});
  }

  void readDirection() {
    FlutterCompass.events?.listen((onData) {
      userHeading = onData.heading.runtimeType == double ? onData.heading! : 0;
      // print("${onData.heading}");
    }, onDone: () {
      debugPrint("Finish!");
    }, onError: (error) {
      debugPrint(error);
    });

    Compass()
        .compassUpdates(
            interval: const Duration(milliseconds: -1), azimuthFix: 0)
        .listen(
      (event) {
        // debugPrint("S Compass value is ${event.angle}");
      },
    );
  }

  void readDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    debugPrint("Is real device environment : ");
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      isSimulator = !info.isPhysicalDevice;
      debugPrint("${info.isPhysicalDevice}");
    } else if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      isSimulator = !info.isPhysicalDevice;
      debugPrint("${info.isPhysicalDevice}");
    } else {
      debugPrint("Not Supported Device.");
    }
  }

  // Map Variables
  static LatLng initLatLng =
      const LatLng(51.53870580986422, -0.0164587280985591);
  static double initHeading = 0.00;
  LatLng userLatLng = LatLng(initLatLng.latitude, initLatLng.longitude);
  double userHeading = initHeading;
  String _mapStyle = "";
  double searchRadius = 2000;
  bool isSearching = false;
  bool isSearchFinished = false;
  bool isSimulator = true;
  late List<PlacesModel> searchResult;
  late List<CachedNetworkImage> searchPhoto;
  late Position userPosition;

  // Set init map controller
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(51.53870580986422, -0.0164587280985591),
    zoom: 14.4746,
  );

// on below line we have created the list of markers and lines
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
  final List<LatLng> polygon = [];

  @override
  void initState() {
    super.initState();
    getUserLocation();
    listenLocationChanges();
    readMapStyle();
    readDirection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F9D58),
        // on below line we have given title of app
        title: const Text("Skylark"),
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
                  controller.setMapStyle(_mapStyle);
                  _controller.complete(controller);
                },
                polylines: Set<Polyline>.of(_lines),
              ),
            ),
            // Test Panel --------- Remove in production
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
                    "Live Reading :${!positionStream!.isPaused}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Radius :$searchRadius",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => updateSearchRadius(
                                isIncresing: true,
                              ),
                          icon: const Icon(Icons.arrow_upward)),
                      IconButton(
                          onPressed: () => updateSearchRadius(
                                isIncresing: false,
                              ),
                          icon: const Icon(Icons.arrow_downward)),
                    ],
                  )
                ],
              ),
            ),
            // Search Result Placement
            Positioned(
              bottom: 0,
              left: 0,
              // when isSearchFinished is changed, show transition animation
              child: isSearchFinished
                  ? _searchPlaces(searchResult, searchPhoto, userLatLng,
                      updateSearchFinished)
                  : Container(),
            ),
          ],
        ),
      ),
      // on pressing floating action button the camera will take to user current location
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isSearchFinished
                ? Container()
                : SizedBox(
                    width: 150,
                    child: FloatingActionButton.extended(
                      icon: const Icon(Icons.location_on_sharp),
                      label: const Text("My Location"),
                      onPressed: () async {
                        getUserLocation();
                        // _markers.add(
                        //   Marker(
                        //       markerId: const MarkerId("user"),
                        //       position: userLatLng,
                        //       icon: BitmapDescriptor.defaultMarker),
                        // );
                        updateCameraPosition(
                            coordinates: userLatLng, radius: searchRadius);
                      },
                    ),
                  ),
            isSearchFinished
                ? Container()
                : SizedBox(
                    width: 150,
                    child: FloatingActionButton.extended(
                      icon: isSearching ? null : const Icon(Icons.search_sharp),
                      label: isSearching
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Search"),

                      // label: const CircularProgressIndicator(
                      //   color: Colors.white,
                      // ),
                      onPressed: () async {
                        _markers.clear();
                        isSearching = true;

                        var polytool = PolygonTool(polygon);
                        var sw = polytool.southwest;
                        var ne = polytool.northeast;
                        var center = polytool.centroid;
                        var radius = Geometry().calculateDistance(sw, ne)! / 2;
                        try {
                          late List<PlacesModel> tempSearchResult;
                          searchResult = [];
                          tempSearchResult = await APIService()
                              .searchPlaces(coorinates: center, radius: radius)
                              .timeout(const Duration(seconds: 20));
                          // Loop searchResult, and if the place is inside the polygon, keep it in searchResult else remove it from searchResult
                          for (var place in tempSearchResult) {
                            LatLng point = LatLng(
                                place.geometry["location"]["lat"],
                                place.geometry["location"]["lng"]);
                            if (Geometry().isInside(point, polygon)) {
                              searchResult.add(place);
                            }
                          }
                          debugPrint("$searchResult");
                          searchPhoto = await _fetchImg(searchResult);
                          //
                          // Makers on the map
                          //
                          for (var place in searchResult) {
                            LatLng point = LatLng(
                                place.geometry["location"]["lat"],
                                place.geometry["location"]["lng"]);
                            _markers.add(
                              Marker(
                                markerId: MarkerId(place.placeId),
                                position: LatLng(
                                    place.geometry["location"]["lat"],
                                    place.geometry["location"]["lng"]),
                                icon: Geometry().isInside(point, polygon)
                                    ? BitmapDescriptor.defaultMarker
                                    : BitmapDescriptor.defaultMarkerWithHue(50),
                              ),
                            );
                            // _markers.add(Marker(
                            //   markerId: const MarkerId("sw"),
                            //   position: sw,
                            //   icon: BitmapDescriptor.defaultMarkerWithHue(70),
                            // ));
                            // _markers.add(Marker(
                            //   markerId: const MarkerId("ne"),
                            //   position: ne,
                            //   icon: BitmapDescriptor.defaultMarkerWithHue(70),
                            // ));
                            // _markers.add(Marker(
                            //   markerId: const MarkerId("center"),
                            //   position: center,
                            //   icon: BitmapDescriptor.defaultMarkerWithHue(100),
                            // ));
                          }
                          //
                          //
                          //
                          if (!mounted) return;
                          // _showModalButtonSheet(context, searchResult, searchPhoto);
                          isSearching = false;
                          isSearchFinished = true;
                        } on TimeoutException {
                          isSearching = false;
                          debugPrint("Timeout Error");
                        }
                        setState(() {});
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
