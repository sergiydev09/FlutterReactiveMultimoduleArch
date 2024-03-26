import 'package:flutter/material.dart';

Widget buildSection(String title, List<dynamic> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          color: Colors.black12,
          child: SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  margin: const EdgeInsets.all(8),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: item.imagePath.isNotEmpty ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      item.imagePath.isNotEmpty
                          ? Image.network(item.imagePath, fit: BoxFit.cover, width: 100, height: 100)
                          : Container(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                            ),
                          ),
                          child: Container(
                            width: 10,
                            alignment: Alignment.center,
                            child: Text(
                              item.name,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
              },
            ),
          ),
        ),
      ],
    );
