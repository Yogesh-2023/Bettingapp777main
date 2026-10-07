import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  final double fontSize;
  final double circleRadius;
  final double lineHeight;
  final double lineWidth;

  const AppName({
    super.key,
    this.fontSize = 16,
    this.circleRadius = 16,
    this.lineHeight = 2,
    this.lineWidth = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: circleRadius * 2,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Orange Circle behind "S"
          CircleAvatar(radius: circleRadius, backgroundColor: Color(0xffFF6f00)),

          // Sara777 Text with Overline
          Padding(
            padding: EdgeInsets.only(left: circleRadius * 0.7),
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'D',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'P',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'BOSS',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
