import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Spinner extends StatefulWidget {
  final Color color;
  Color? back;
  Spinner({super.key, this.color=Colors.blue, this.back});

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {
  @override
  Widget build(BuildContext context) {
    widget.back ??= Colors.grey[200];
    
    return Container(
      color: widget.back,
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(color: widget.color),
        ),
      ),
    );
  }
}