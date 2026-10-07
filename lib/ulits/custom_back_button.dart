import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final Color iconColor;
  final Color borderColor;

  const CustomBackButton({
    super.key,
    this.iconColor = Colors.black,
    this.borderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,   // 🔥 Grey Border Added
            width: 1.2,
          ),
        ),
        child: Icon(
          Icons.arrow_back,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }
}
