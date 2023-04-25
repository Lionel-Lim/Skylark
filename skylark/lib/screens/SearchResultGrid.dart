import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:skylark/models/places_model.dart';

class SearchResultGrid extends StatefulWidget {
  final List<PlacesModel> result;
  final List<CachedNetworkImage> photos;

  const SearchResultGrid(this.result, this.photos, {super.key});

  @override
  State<SearchResultGrid> createState() => _SearchResultGridState();
}

TextStyle titleTextStyle() {
  return const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}

TextStyle contentTextStyle() {
  return const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );
}

Widget buildGridView(
    List<PlacesModel> result, List<CachedNetworkImage> photos) {
  return SizedBox(
    child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.9,
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: result.length,
        itemBuilder: (context, index) {
          final item = result[index];
          final photo = photos[index];
          return buildNumber(item, photo);
        }),
  );
}

Widget buildNumber(PlacesModel item, CachedNetworkImage photo) {
  int textLength = item.name.length;
  item.name.trim();
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  height: 140,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                    child: photo,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: titleTextStyle().fontSize! * 1.2,
                      width: 200,
                      child: textLength > 20
                          ? Marquee(
                              text: item.name,
                              style: titleTextStyle(),
                              blankSpace: 30,
                              startAfter: const Duration(seconds: 3),
                              pauseAfterRound: const Duration(seconds: 1),
                            )
                          : Text(
                              item.name,
                              style: titleTextStyle(),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Popularity: ${item.userRating}",
                          style: contentTextStyle(),
                        ),
                        Text(
                          "Distance: ${item.geometry["distance"].toStringAsFixed(0)}m",
                          style: contentTextStyle(),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _SearchResultGridState extends State<SearchResultGrid> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: buildGridView(widget.result, widget.photos),
          ),
        ],
      ),
    );
  }
}
