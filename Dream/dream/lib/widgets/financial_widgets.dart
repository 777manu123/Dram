import 'package:flutter/material.dart';

class FinancialCard extends StatelessWidget {
  final String title;
  final String amount;
  final double percent;
  final Color color;
  const FinancialCard({
    required this.title,
    required this.amount,
    required this.percent,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 8),
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
