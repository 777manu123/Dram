import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedJoystick extends StatefulWidget {
  final Function()? onAddFriendPressed;
  final Future Function()? checkPendingRequests;
  final Future<bool> Function()? friendSearchBar;
  final Future<void> Function()? settingsMenu;

  const AnimatedJoystick({
    super.key,
    this.onAddFriendPressed,
    this.checkPendingRequests,
    this.friendSearchBar,
    this.settingsMenu,
  });

  @override
  State<AnimatedJoystick> createState() => _AnimatedJoystickState();
}

class _AnimatedJoystickState extends State<AnimatedJoystick>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  double rotation = 0; // rotation in radians
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<MenuItem> items;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    items = [
      MenuItem(Icons.person_add, widget.onAddFriendPressed),
      MenuItem(Icons.pending_actions, widget.checkPendingRequests),
      MenuItem(Icons.search, () async {
        if (widget.friendSearchBar != null) await widget.friendSearchBar!();
      }),
      MenuItem(Icons.settings, widget.settingsMenu),
      MenuItem(Icons.camera_alt, () => debugPrint("Camera pressed")),
    ];
  }

  int get activeIndex {
    // Compute which icon is closest to top (Y negative)
    double step = 2 * pi / items.length;
    double normalizedRotation = rotation % (2 * pi);
    int index = ((normalizedRotation / step).round()) % items.length;
    return (items.length - index) % items.length; // invert to match top
  }

  void rotate(double dx) {
    if (!expanded) return;
    setState(() => rotation += dx * 0.01);
  }

  void snapTo(int index) {
    double step = 2 * pi / items.length;
    setState(() => rotation = (items.length - index) * step);
  }

  Future<void> trigger(int index) async {
    var fn = items[index].onTap;
    if (fn != null) await fn();
  }

  void toggleMenu() {
    setState(() {
      expanded = !expanded;
      if (expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> triggerTopIcon() async {
    await trigger(activeIndex);
  }

  @override
  Widget build(BuildContext context) {
    double rMax = 100;

    return GestureDetector(
      onPanUpdate: (d) => rotate(d.delta.dx),
      child: SizedBox(
        width: 250,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < items.length; i++)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  double step = 2 * pi / items.length;
                  double angle = i * step + rotation - pi / 2; // top is 0 rad
                  double r = rMax * _animation.value;
                  double x = r * cos(angle);
                  double y = r * sin(angle);

                  bool isTop = y < 0;
                  double scale = isTop ? 1.0 : 0.7;
                  Color color = isTop ? Colors.orange : Colors.white38;

                  return Transform.translate(
                    offset: Offset(x, y),
                    child: GestureDetector(
                      onTap: () async {
                        snapTo(i);
                        await trigger(i);
                      },
                      child: Transform.scale(
                        scale: scale,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: color,
                          child: Icon(items[i].icon, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  );
                },
              ),

            GestureDetector(
              onTap: toggleMenu,
              onDoubleTap: triggerTopIcon,
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: expanded
                      ? [
                          BoxShadow(
                              color: Colors.orange.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 5)
                        ]
                      : [],
                ),
                child: const Icon(Icons.sports_esports,
                    color: Colors.white, size: 38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final Function()? onTap;
  MenuItem(this.icon, this.onTap);
}
