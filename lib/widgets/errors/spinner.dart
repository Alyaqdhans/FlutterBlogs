import 'package:flutter/material.dart';

class Spinner extends StatefulWidget {
  final Color color;
  const Spinner({super.key, this.color = Colors.blue});

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(color: widget.color),
      ),
    );
  }
}