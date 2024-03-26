import 'package:flutter/material.dart';
import 'package:home/ui/home_state.dart';
import 'package:home/ui/home_view_model.dart';

class HomeScreenDesktop extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreenDesktop({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) => Scaffold(
      body: ValueListenableBuilder(
        valueListenable: viewModel.state,
        builder: (BuildContext context, HomeState value, Widget? child) {
          if (value.comics.isEmpty) {
            return const Text("HOME Desktop");
          } else {
            return const Text("HOME Desktop");
          }
        },
      ));
}

