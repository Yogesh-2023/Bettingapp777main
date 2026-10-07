import 'package:flutter/material.dart';

class AppNameBold extends StatelessWidget {
  const AppNameBold({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Orange circle behind "S"
          const CircleAvatar(radius: 48, backgroundColor: Color(0xffFF6f00)),

          // "Sara777" text with overline above "ara"
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Stack(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'D',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'P',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      //    decoration: TextDecoration.overline,
                        decorationThickness: 4,
                      ),
                    ),

                    Text(
                      'BOSS',
                      style: TextStyle(
                        fontSize: 48,
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
