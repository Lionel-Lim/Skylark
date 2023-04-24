import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skylark/models/places_model.dart';

class SearchResultGrid extends StatefulWidget {
  final List<PlacesModel> result;
  final List<CachedNetworkImage> photos;

  const SearchResultGrid(this.result, this.photos, {super.key});

  @override
  State<SearchResultGrid> createState() => _SearchResultGridState();
}

Widget buildGridView(
    List<PlacesModel> result, List<CachedNetworkImage> photos) {
  return SizedBox(
    child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 0,
              offset: const Offset(3, 6)),
        ],
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: photo,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    item.name,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
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
