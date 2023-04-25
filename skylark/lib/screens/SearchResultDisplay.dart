import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skylark/models/places_model.dart';
import 'package:skylark/screens/SearchResultGrid.dart';
import 'package:skylark/services/geometry.dart';
import 'package:skylark/services/sort.dart';

List<String> sortList = ["Distance", "Popularity"];

class SearchResultDisplay extends StatefulWidget {
  final List<PlacesModel> result;
  final List<CachedNetworkImage> photos;
  final LatLng userLocation;
  final Function(bool) onSearchFinished;

  const SearchResultDisplay(
      this.result, this.photos, this.userLocation, this.onSearchFinished,
      {super.key});

  @override
  State<SearchResultDisplay> createState() => _SearchResultDisplayState();
}

class _SearchResultDisplayState extends State<SearchResultDisplay> {
  double offset = 0;
  late double windowHeight;
  late List<PlacesModel> searchResult;
  late List<CachedNetworkImage> searchPhotos;

  void sortByDistance() {
    List<dynamic> distances = [];
    for (var place in searchResult) {
      distances.add(Geometry().haversine(
          widget.userLocation,
          LatLng(place.geometry["location"]["lat"],
              place.geometry["location"]["lng"]))["Distance"]);
      place.geometry["distance"] = distances.last;
    }

    List<PlacesModel> sortedResult =
        List.from(Sort().sortByAnotherList(searchResult, distances)[0])
            .cast<PlacesModel>();
    List<CachedNetworkImage> sortedPhoto =
        List.from(Sort().sortByAnotherList(searchPhotos, distances)[0])
            .cast<CachedNetworkImage>();
    searchResult = sortedResult;
    searchPhotos = sortedPhoto;
    debugPrint("Sorted By Distance");
  }

  void sortByPopularity() {
    List<dynamic> popularities = [];
    for (var place in searchResult) {
      popularities.add(place.userRating);
    }
    List<PlacesModel> sortedResult =
        List.from(Sort().sortByAnotherList(searchResult, popularities)[0])
            .cast<PlacesModel>();
    List<CachedNetworkImage> sortedPhoto =
        List.from(Sort().sortByAnotherList(searchPhotos, popularities)[0])
            .cast<CachedNetworkImage>();
    searchResult = sortedResult.reversed.toList();
    searchPhotos = sortedPhoto.reversed.toList();
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
    searchResult = widget.result;
    searchPhotos = widget.photos;
    sortByDistance();
    super.initState();
  }

  String sortValue = sortList.first;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double screenY(offset) {
      windowHeight = height / 2 - offset;
      if (windowHeight < height * 0.8) {
        if (windowHeight < height * 0.10) {
          debugPrint("${height * 0.10}");
          return height * 0.10;
        }
        return windowHeight;
      } else {
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
        child: SizedBox(
          // maxHeight: height * 0.2,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: width,
                child: Row(
                  children: [
                    SizedBox(
                      width: width * 0.8,
                      child: const Text(
                        " Search Result",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // exit button
                    IconButton(
                      onPressed: () {
                        widget.onSearchFinished(false);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              if (screenY(offset) > height * 0.15)
                SizedBox(
                  width: width,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButton(
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
                    ],
                  ),
                ),
              if (screenY(offset) > height * 0.15)
                Column(
                  children: [
                    SizedBox(
                      height: screenY(offset) - 30 - 40 - 40 - 8,
                      child: SearchResultGrid(searchResult, searchPhotos),
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
