import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skylark/models/places_model.dart';

class SearchResult extends StatefulWidget {
  final List<PlacesModel> result;
  final List<CachedNetworkImage> photos;

  const SearchResult(this.result, this.photos, {super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
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
  return Stack(
    alignment: AlignmentDirectional.topCenter,
    children: [
      ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 150,
              child: photo,
            ),
            Text(
              item.name,
            )
          ],
        ),
      ),
    ],
  );
}

class _SearchResultState extends State<SearchResult> {
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
