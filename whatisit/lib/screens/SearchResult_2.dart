import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatisit/models/places_model.dart';
import 'package:whatisit/screens/SearchResult.dart';

class SearchPlaces extends StatefulWidget {
  final List<PlacesModel> result;
  final List<CachedNetworkImage> photos;

  const SearchPlaces(this.result, this.photos, {super.key});

  @override
  State<SearchPlaces> createState() => _SearchPlacesState();
}

class _SearchPlacesState extends State<SearchPlaces> {
  double offset = 0;
  late double windowHeight;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double screenY(offset) {
      debugPrint("Offset is : $offset");
      windowHeight = height / 2 - offset;
      debugPrint("window height is :$windowHeight");
      debugPrint("$height");
      if (windowHeight > height * 0.9) {
        offset = -0.4 * height;
        windowHeight = height * 0.9;
        return windowHeight;
      } else if (windowHeight < height * 0.1) {
        return height * 0.1;
      } else {
        return windowHeight;
      }
    }

    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          offset = offset + details.delta.dy;
        });
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: Colors.grey,
          width: width,
          height: screenY(offset),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: SearchResult(widget.result, widget.photos),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
