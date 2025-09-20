import 'package:flutter/material.dart';

// Dreamy Dark Theme Colors
const Color kPrimaryColor = Color(0xFF100B20); // Deep Indigo
const Color kPurpleGradientStart = Color(0xFF8B5CF6); // Purple
const Color kPurpleGradientEnd = Color(0xFF6366F1); // Indigo
const Color kBackgroundColor = Color(0xFF181A20); // Modern Dark Gray
const Color kSurfaceColor = Color(0xFF23272F); // Deep Gray
const Color kTextColor = Color(0xFFD1D5DB); // Light Gray

class Homesreen extends StatelessWidget {
  const Homesreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 95,
        leading: Icon(Icons.menu, color: kTextColor),
        backgroundColor: kPrimaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kBackgroundColor, kBackgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Balance Area
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kPurpleGradientEnd.withOpacity(0.18),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          color: kTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      AnimatedBalance(
                        balance: 1532.00,
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.65, // 65% fill
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kPurpleGradientStart, Colors.cyanAccent],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  // Nested: Dreamy Indigo & Purple + Financial Dashboard
                  Container(
                    height: 250,
                    margin: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.05),
                      boxShadow: [
                        BoxShadow(
                          color: kPurpleGradientEnd.withOpacity(0.18),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Dreamy Indigo & Purple',
                        style: TextStyle(
                          color: kTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                                       
                     Container(
                      height: 150,margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFinancialCard(
                            context,
                            'Incoming',
                            '€35k',
                            0.45,
                            Colors.cyan,
                          ),
                          _buildFinancialCard(
                            context,
                            'Outgoing',
                            '€25k',
                            0.20,
                            Colors.pinkAccent,
                          ),
                          _buildFinancialCard(
                            context,
                            'Savings',
                            '€10k',
                            0.10,
                            Colors.lightBlueAccent,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              height: 650,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [kBackgroundColor, kBackgroundColor]),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    color: kPurpleGradientEnd.withOpacity(0.5),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 120, maxHeight: 180),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: kPurpleGradientEnd.withOpacity(0.18),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double barWidth = constraints.maxWidth * 0.35;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My Spending',
                                  style: TextStyle(
                                    color: kTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'See more',
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('This Week', style: TextStyle(color: kTextColor, fontSize: 15)),
                                    SizedBox(height: 6),
                                    Container(
                                      width: barWidth,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.pinkAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.35, // 35% progress
                                          child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.pinkAccent,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text('€87.25', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                            
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('This Month', style: TextStyle(color: kTextColor, fontSize: 15)),
                                    SizedBox(height: 6),
                                    Container(
                                      width: barWidth,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.cyanAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.75, // 75% progress
                                          child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.cyanAccent,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text('€206.76', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Recent Transactions Area
                Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: kPurpleGradientEnd.withOpacity(0.18),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Transactions',
                                  style: TextStyle(
                                    color: kTextColor,
                                    fontWeight: FontWeight.bold,
                                  
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Arrange',
                                      style: TextStyle(
                                        color: Colors.cyanAccent,
                                        fontWeight: FontWeight.w600,
                                  
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent,),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Description', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, )),
                                Text('Arrange V', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, )),
                              ],
                            ),
                            SizedBox(height: 14),
                            // Transaction Card 1
                            Container(
                           
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: kSurfaceColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.pinkAccent.withOpacity(0.2),
                                    child: Icon(Icons.fastfood, color: Colors.pinkAccent, ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Domino\'s Pizza', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold,)),
                                        Text('18:45 06.01.19', style: TextStyle(color: kTextColor.withOpacity(0.7), )),
                                      ],
                                    ),
                                  ),
                                  Text('-€32.00', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold,)),
                                ],
                              ),
                            ),
                            // Transaction Card 2
                            Container(
                            
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: kSurfaceColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                                    child: Icon(Icons.home, color: Colors.cyanAccent, ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Rent', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, )),
                                        Text('16:55 05.01.19', style: TextStyle(color: kTextColor.withOpacity(0.7),)),
                                      ],
                                    ),
                                  ),
                                  Text('€1500.00', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
    );
  }

  Widget _buildFinancialCard(BuildContext context, String title, String amount, double percent, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 8),
        // If you have percent_indicator package:
        // CircularPercentIndicator(
        //   radius: 40.0,
        //   lineWidth: 8.0,
        //   percent: percent,
        //   center: Text(
        //     "${(percent * 100).toInt()}%",
        //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
        //   ),
        //   progressColor: color,
        //   backgroundColor: color.withOpacity(0.3),
        // ),
        // If you don't have percent_indicator, use a placeholder:
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 6,
                color: color,
                backgroundColor: color.withOpacity(0.3),
              ),
            ),
            Text(
              "${(percent * 100).toInt()}%",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Text(
          amount,
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// For animated total balance
class AnimatedBalance extends StatefulWidget {
  final double balance;
  final TextStyle style;
  final Duration duration;
  const AnimatedBalance({required this.balance, required this.style, this.duration = const Duration(seconds: 2), Key? key}) : super(key: key);
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
