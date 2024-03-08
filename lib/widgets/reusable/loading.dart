import "package:flutter/material.dart";

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(0, 175, 51, 51),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
