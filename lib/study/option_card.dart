import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const OptionCard({
    Key? key,
    required this.title,
    required this.color,
    required this.onTap,
  }) : super(key: key);

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
