import 'package:flutter/material.dart';

class DetailScreenMobile extends StatefulWidget {
  const DetailScreenMobile({super.key});

  @override
  State<DetailScreenMobile> createState() => _DetailScreenMobileState();
}

class _DetailScreenMobileState extends State<DetailScreenMobile> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: const Text("Detail"),
        ),
      );
}
