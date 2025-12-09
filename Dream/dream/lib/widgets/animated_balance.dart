import 'package:flutter/material.dart';

class AnimatedBalance extends StatefulWidget {
  final double balance;
  final TextStyle style;
  final Duration duration;
  const AnimatedBalance({required this.balance, required this.style, this.duration = const Duration(seconds: 2), super.key});
  @override
  State<AnimatedBalance> createState() => _AnimatedBalanceState();
}
class _AnimatedBalanceState extends State<AnimatedBalance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.balance).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '€${_animation.value.toStringAsFixed(2)}',
          style: widget.style,
        );
      },
    );
  }
}
