// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class CircleLoop extends StatefulWidget {
  const CircleLoop({Key? key, required this.time}) : super(key: key);
  final int time;

  @override
  State<CircleLoop> createState() => _CircleLoopState();
}

class _CircleLoopState extends State<CircleLoop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _colorAnimation;
  late Animation<double> _size;
  late Animation _colorBorder;

  @override
  void initState() {
    super.initState();
    playAnimation();
  }

  void playAnimation() {
    _controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);

    _colorAnimation = ColorTween(begin: Colors.blue[400], end: Colors.blue[100])
        .animate(_controller);

    _size = Tween<double>(begin: 0, end: 340).animate(_controller);

    _colorBorder = ColorTween(
            begin: Colors.white.withOpacity(1),
            end: Colors.white.withOpacity(0))
        .animate(_controller);

    _controller.reset();
    _controller.forward();

    _controller.addStatusListener((status) {
      print(status);
      if (status == AnimationStatus.completed) {
        // Future.delayed(const Duration(milliseconds: 1000), () {
        _controller.forward(from: 0.0);
        // });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, child) {
          return Container(
            height: _size.value,
            width: _size.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _colorAnimation.value,
                    blurRadius: 0.0,
                    spreadRadius: 0.0),
              ],
              border: Border.all(color: _colorBorder.value),
            ),
          );
        });
  }
}
