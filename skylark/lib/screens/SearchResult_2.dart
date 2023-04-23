import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skylark/models/places_model.dart';
import 'package:skylark/screens/SearchResult.dart';
import 'package:skylark/services/geometry.dart';
import 'package:skylark/services/sort.dart';

List<String> sortList = ["Distance", "Popularity", "Height"];

class SearchPlaces extends StatefulWidget {
  List<PlacesModel> result;
  List<CachedNetworkImage> photos;
  final LatLng userLocation;

  SearchPlaces(this.result, this.photos, this.userLocation, {super.key});

  @override
  State<SearchPlaces> createState() => _SearchPlacesState();
}

class _SearchPlacesState extends State<SearchPlaces> {
  double offset = 0;
  late double windowHeight;

  void sortByDistance() {
    List<dynamic> distances = [];
    for (var place in widget.result) {
      distances.add(Geometry().haversine(
          widget.userLocation,
          LatLng(place.geometry["location"]["lat"],
              place.geometry["location"]["lng"]))["Distance"]);
    }
    List<PlacesModel> sortedResult =
        List.from(Sort().sortByAnotherList(widget.result, distances)[0])
            .cast<PlacesModel>();
    List<CachedNetworkImage> sortedPhoto =
        List.from(Sort().sortByAnotherList(widget.photos, distances)[0])
            .cast<CachedNetworkImage>();
    widget.result = sortedResult;
    widget.photos = sortedPhoto;
    debugPrint("Sorted By Distance");
  }

  void sortByPopularity() {
    List<dynamic> popularities = [];
    for (var place in widget.result) {
      popularities.add(place.userRating);
    }
    List<PlacesModel> sortedResult =
        List.from(Sort().sortByAnotherList(widget.result, popularities)[0])
            .cast<PlacesModel>();
    List<CachedNetworkImage> sortedPhoto =
        List.from(Sort().sortByAnotherList(widget.photos, popularities)[0])
            .cast<CachedNetworkImage>();
    widget.result = sortedResult.reversed.toList();
    widget.photos = sortedPhoto.reversed.toList();
    debugPrint("Sorted By Popularity");
  }

  void sortPlaces(userSelection) {
    if (userSelection == "Distance") {
      sortByDistance();
    } else if (userSelection == "Popularity") {
      sortByPopularity();
    } else {
      // Height Placeholder
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String sortValue = sortList.first;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double screenY(offset) {
      // debugPrint("Offset is : $offset");
      windowHeight = height / 2 - offset;
      // debugPrint("window height is :$windowHeight");
      if (windowHeight < height * 0.8) {
        if (windowHeight < height * 0.2) {
          return height * 0.2;
        }
        // debugPrint("Case 1 $windowHeight");
        return windowHeight;
      } else {
        // debugPrint("Case 2 $windowHeight");
        windowHeight = height * 0.8;
        return height * 0.8;
      }
    }

    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          offset = offset + details.delta.dy;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        width: width,
        height: screenY(offset),
        child: OverflowBox(
          maxHeight: double.infinity,
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              SizedBox(
                width: width,
                child: const Text(
                  " Search Result",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: DropdownButton(
                  value: sortValue,
                  onChanged: ((value) {
                    setState(() {
                      sortPlaces(value);
                      sortValue = value!;
                    });
                  }),
                  items: sortList.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: windowHeight * 0.9,
                    child: SearchResult(widget.result, widget.photos),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
