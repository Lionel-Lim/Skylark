import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:skylark/models/places_model.dart';
import 'package:skylark/services/read_utility.dart';

class APIService {
  late dynamic apiKeys;
  final keyAddress = 'assets/keys/APIKeys.json';

  List<PlacesModel> searchResult = [];
  final String searchURL =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=";
  final String photoURL = "https://maps.googleapis.com/maps/api/place/photo";

  Future<List<PlacesModel>> searchPlaces({
    required LatLng coorinates,
    required double radius,
    List<String> types = const ['establishment'],
  }) async {
    apiKeys = jsonDecode(await ReadUtility().loadAsset(keyAddress))[0];
    final url = Uri.parse(
        "$searchURL${coorinates.latitude}%2C${coorinates.longitude}&radius=$radius&type=$types&key=${apiKeys["GoogleMaps"]}");
    final response = await http.get(url);
    // print(response.statusCode);
    if (response.statusCode == 200) {
      for (var res in jsonDecode(response.body)["results"].sublist(1)) {
        // print(res["name"]);
        searchResult.add(PlacesModel.fromJson(res));
      }
      // print(searchResult);
      return searchResult;
    }
    throw Error();
  }

  Future<CachedNetworkImage> getPhoto(String photoReference) async {
    apiKeys = jsonDecode(await ReadUtility().loadAsset(keyAddress))[0];
    late final String url;
    if (photoReference == "") {
      url = "https://img.icons8.com/ios-filled/2x/no-image.png";
    } else {
      url =
          "$photoURL?maxheight=400&photo_reference=$photoReference&key=${apiKeys["GoogleMaps"]}";
    }
    final photo = CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );
    // print("Result is");
    // print(photo.httpHeaders);
    return photo;
    // final response = await http.get(url);
    // if (response.statusCode == 200) {
    //   print("result is");
    //   print(response.body);
    // }
  }
}
