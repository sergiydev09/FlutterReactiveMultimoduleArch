import 'package:flutter/material.dart';

class DetailScreenDesktop extends StatefulWidget {
  const DetailScreenDesktop({super.key});

  @override
  State<DetailScreenDesktop> createState() => _DetailScreenDesktopState();
}

class _DetailScreenDesktopState extends State<DetailScreenDesktop> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: const Text("Detail"),
        ),
      );
}
