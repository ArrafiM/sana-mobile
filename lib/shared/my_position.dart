import 'package:flutter/material.dart';

class MyPosition extends StatefulWidget {
  const MyPosition({super.key});

  @override
  State<MyPosition> createState() => _MyPositionState();
}

class _MyPositionState extends State<MyPosition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _colorAnimation;

  @override
  void initState() {
    super.initState();
    playAnimation();
  }

  void playAnimation() {
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    _colorAnimation =
        ColorTween(begin: Colors.white, end: Colors.white.withOpacity(0))
            .animate(_controller);

    _controller.repeat(reverse: true);
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
            height: 10,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colorAnimation.value,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.white, spreadRadius: 0.0, blurRadius: 5),
                ]),
          );
        });
  }
}
