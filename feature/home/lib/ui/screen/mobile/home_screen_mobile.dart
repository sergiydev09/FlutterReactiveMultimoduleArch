import 'package:flutter/material.dart';
import 'package:home/ui/home_state.dart';
import 'package:home/ui/home_view_model.dart';

class HomeScreenMobile extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreenMobile({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ValueListenableBuilder(
          valueListenable: viewModel.state,
          builder: (BuildContext context, HomeState value, Widget? child) {
            if (value.comics.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return ListView.builder(
                itemCount: value.comics.length,
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
                                alignment: Alignment.bottomLeft,
                                children: [
                                  Image.network(comic.imagePath, width: 200, height: 200),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: Colors.black.withOpacity(0.5),
                                    // Un fondo semitransparente para mejorar la legibilidad
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20,
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
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        comic.description ?? 'No description',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (comic.characters.isNotEmpty)
                          Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: comic.characters.length, // Asumiendo que este es el carrusel de personajes
                              itemBuilder: (context, index) {
                                final character = comic.characters[index];
                                return buildCarouselItem(character.name, character.imagePath);
                              },
                            ),
                          ),
                        if (comic.creators.isNotEmpty)
                          Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: comic.creators.length, // Asumiendo que este es el carrusel de creadores
                              itemBuilder: (context, index) {
                                final creator = comic.creators[index];
                                return buildCarouselItem(creator.name, creator.imagePath);
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      );

  Widget buildCarouselItem(String name, String imagePath) => Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      color: imagePath.isNotEmpty ? Colors.black : Colors.transparent,
      borderRadius: BorderRadius.circular(50), // Aplicando un borde redondeado
    ),
    clipBehavior: Clip.antiAlias, // Asegúrate de recortar el contenido al borde
    child: Stack(
      children: [
        // Imagen del ítem, si existe
        imagePath.isNotEmpty ? Image.network(imagePath, fit: BoxFit.cover, width: 200, height: 200) : Container(),
        // Degradado y nombre del ítem
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
            child: Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    ),
  );

}
