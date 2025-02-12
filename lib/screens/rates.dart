import 'package:flutter/material.dart';

class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Gas Rates',
        style: Theme.of(context)
            .textTheme
            .headlineLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
