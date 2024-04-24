import 'package:flutter/material.dart';

// the customized card as the session will appear to the UI
class OptionCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
