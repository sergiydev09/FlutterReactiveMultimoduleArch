import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:home/ui/home_state.dart';
import 'package:home/ui/home_view_model.dart';
import 'package:home/ui/screen/mobile/views/item_section_view.dart';
import 'package:res/strings/manager/localization.dart';

class HomeScreenDesktop extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreenDesktop({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ValueListenableBuilder(
          valueListenable: viewModel.state,
          builder: (BuildContext context, HomeState value, Widget? child) {
            if (value.comics.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container(
                color: Colors.black87,
                child: AlignedGridView.count(
                  crossAxisCount: 3, // 2 columnas
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: value.comics.length, // La cantidad de ítems es la longitud de la lista de cómics
                  itemBuilder: (context, index) {
                    final comic = value.comics[index];
                    return Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.topLeft,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 38),
                                      child: Image.network(comic.imagePath, width: 100, height: 160, fit: BoxFit.cover),
                                    ),
                                    Container(
                                      width: 38,
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      color: Colors.redAccent,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comic.title,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          comic.description ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (comic.characters.isNotEmpty)
                            buildSection(context.strings.homeSectionCharacters, comic.characters),
                          if (comic.creators.isNotEmpty)
                            buildSection(context.strings.homeSectionCreators, comic.creators),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      );
}
